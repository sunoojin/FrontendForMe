import 'dart:io';

import 'package:diary_for_me/DB/background_log/background_log_model.dart';
import 'package:diary_for_me/DB/daily_data/daily_data_model.dart';
import 'package:diary_for_me/DB/db_manager.dart';
import 'package:diary_for_me/DB/timeline/timeline_model.dart';
import 'package:diary_for_me/collect/image.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_service.dart';

Future<bool> generateTimeline() async {
  DateTime now = DateTime.now();
  DateTime targetDate = (now.hour >= 21)
      ? DateTime(now.year, now.month, now.day)
      : DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));

  try {
    print("timeline generating...");

    // 2. 데이터 집계 (DB + 갤러리)
    final Map<String, dynamic> dailyData = await collectedDailyData(targetDate);

    // 데이터가 비어있지 않은지 간단 체크
    if (dailyData.isEmpty) {
      print("수집된 데이터가 없습니다.");
      return false;
    }

    // 3. API 전송 (이미지 포함 Multipart 전송)
    final apiService = DailyLogApiService();
    final Map<String, dynamic>? responseMap = await apiService.uploadDailyLog(dailyData);

    if (responseMap != null) {
      await _saveTimelineToDB(responseMap, targetDate);
      return true;
    } else {
      print("서버 응답이 비어있거나 실패했습니다.");
      return false;
    }

  } catch (e) {
    print("타임라인 생성 및 전송 실패: $e");
    return false;
  }
}

Future<Map<String, dynamic>> collectedDailyData (DateTime targetDate) async {
  final start = DateTime(targetDate.year, targetDate.month, targetDate.day, 0, 0, 0);
  final end = DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59, 59);

  try {
    final isar = await DB().instance;

    // 알림 로그 불러오기
    final locationLogs = await isar.locationLogs
        .filter()
        .timestampBetween(start, end)
        .sortByTimestamp() // 시간순 정렬
        .findAll();

    // 알림 로그 불러오기
    final notificationLogs = await isar.appNotificationLogs
        .filter()
        .timestampBetween(start, end)
        .sortByTimestamp()
        .findAll();

    // 사진 수집
    List<String> imagePaths = await collectImages(targetDate);

    List<String> base64Images = [];

    for (String path in imagePaths) {
      File file = File(path);
      if (await file.exists()) {
        // 파일을 바이트로 읽음
        List<int> imageBytes = await file.readAsBytes();
        // 바이트를 Base64 문자열로 인코딩
        String base64String = base64Encode(imageBytes);

        // (선택) 용량을 줄이려면 앞부분에 MIME 타입 명시 가능
        // base64Images.add("data:image/jpeg;base64,$base64String");

        // 여기선 순수 데이터만 넣습니다.
        base64Images.add(base64String);
      }
    }

    /// 데이터 가공
    // 위치 데이터 변환
    final locationsJson = locationLogs.map((log) => {
      'lat': log.lat,
      'lng': log.lng,
      'timestamp': log.timestamp.toIso8601String(),
      "place_name": null,
    }).toList();

    // 알림 데이터 변환
    final notificationsJson = notificationLogs.map((log) => {
      'appname': log.appname,
      'text': log.text,
      'timestamp': log.timestamp.toIso8601String(),
    }).toList();

    //
    final Map<String, dynamic> result = {
      'target_date': DateFormat('yyyy-MM-dd').format(targetDate),
      'data': {
        'locations': locationsJson,
        'notifications': notificationsJson,
        'images': imagePaths, // 이미지 경로 리스트 (String List)
      }
    };

    return result;

  } catch (e) {
    print('❌ 데이터 집계 중 에러 발생: $e');
    return {};
  }
}

/// 서버 JSON을 Isar 모델로 변환하여 저장하는 함수
Future<void> _saveTimelineToDB(Map<String, dynamic> json, DateTime targetDate) async {
  final isar = await DB().instance;

  // (1) Events 파싱
  List<Event> parsedEvents = [];
  if (json['events'] != null) {
    for (var evtJson in json['events']) {
      parsedEvents.add(_parseEvent(evtJson));
    }
  }

  // (2) SelfSurvey 파싱 (null 처리)
  SelfSurvey? parsedSurvey;
  if (json['selfsurvey'] != null) {
    parsedSurvey = SelfSurvey(
      mood: json['selfsurvey']['mood'] ?? '',
      draft: json['selfsurvey']['draft'] ?? '',
    );
  }

  await isar.writeTxn(() async {
    // 기존 데이터 확인 (중복 방지)
    final existing = await isar.timeLines
        .filter()
        .dateEqualTo(targetDate)
        .findFirst();

    if (existing != null) {
      // 이미 존재하면 업데이트
      existing.title = json['title'] ?? '';
      existing.status = TimelineStatus.completed; // 완료 상태로 변경
      existing.events = parsedEvents;
      existing.selfsurvey = parsedSurvey;

      await isar.timeLines.put(existing);
      print("🔄 기존 타임라인 업데이트 완료");
    } else {
      // 없으면 새로 생성
      final newTimeline = TimeLine(
        date: targetDate,
        title: json['title'] ?? '',
        events: parsedEvents,
        selfsurvey: parsedSurvey,
      );
      // 초기 상태 설정
      newTimeline.status = TimelineStatus.completed;

      await isar.timeLines.put(newTimeline);
      print("✅ 새 타임라인 저장 완료");
    }
  });
}

/// JSON Event 객체 -> Isar Event 모델 변환 헬퍼
Event _parseEvent(Map<String, dynamic> json) {
  // DailyData 파싱
  DailyData? dailyDataModel;

  if (json['dailydata'] != null) {
    final ddJson = json['dailydata'];

    // Gallery: 서버는 객체 리스트지만, 로컬 모델은 List<String>
    // 따라서 "url" 필드만 뽑아냅니다.
    List<String> galleryUrls = [];
    if (ddJson['gallery'] != null) {
      for (var imgItem in ddJson['gallery']) {
        if (imgItem is Map && imgItem.containsKey('url')) {
          galleryUrls.add(imgItem['url']);
        }
      }
    }

    // Location
    List<Location> locations = [];
    if (ddJson['location'] != null) {
      for (var loc in ddJson['location']) {
        locations.add(Location(
          lat: loc['lat'],
          lng: loc['lng'],
          timestamp: loc['timestamp'] != null ? DateTime.parse(loc['timestamp']) : null,
        ));
      }
    }

    // AppNotification
    List<AppNotification> notis = [];
    if (ddJson['appnoti'] != null) {
      for (var noti in ddJson['appnoti']) {
        notis.add(AppNotification(
          appname: noti['appname'],
          text: noti['text'],
          timestamp: noti['timestamp'] != null ? DateTime.parse(noti['timestamp']) : null,
        ));
      }
    }

    dailyDataModel = DailyData(
      gallery: galleryUrls,
      location: locations,
      appnoti: notis,
    );
  }

  return Event(
    id: json['id'] ?? '',
    timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
    title: json['title'] ?? '',
    content: json['content'] ?? '',
    feeling: json['feeling'] ?? '', // feeling은 null일 수 있음
    dailydata: dailyDataModel,
  );
}
