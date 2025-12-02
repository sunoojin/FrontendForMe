import 'dart:io';

import 'package:diary_for_me/DB/background_log/background_log_model.dart';
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
    await apiService.uploadDailyLog(dailyData);

    return true; // 성공

  } catch (e) {
    print("타임라인 생성 및 전송 실패: $e");
    return false;
  }
}

Future<Map<String, dynamic>> collectedDailyData (DateTime targetDate) async {
  final start = DateTime(targetDate.year, targetDate.month, targetDate.day, 0, 0, 0);
  final end = DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59, 59);

  try {
    // ---------------------------------------------------------
    // 1. Isar DB에서 위치 및 알림 로그 가져오기
    // ---------------------------------------------------------
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
