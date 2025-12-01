import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_notification_listener_plus/flutter_notification_listener_plus.dart';
import 'package:isar/isar.dart';

// [필수] DB 매니저 및 모델 import (경로 확인해주세요)
import 'package:diary_for_me/DB/db_manager.dart';
import 'package:diary_for_me/DB/background_log/background_log_model.dart';

/*
// _callback이랑 같은 함수
@pragma('vm:entry-point')
Future<void> backgroundCallback(NotificationEvent evt) async {
  debugPrint('[BG] callback: ${evt.packageName}');
  try {
    final DateTime now = DateTime.now();
    final AppNotification noti = eventToNotification(evt, now);

    try {
      // Hive 준비 (초기화 + 어댑터 등록 + 박스 오픈)
      await ensureHiveReady();

      // 날짜별 key (예: "2025-11-28")
      final String key = dateKey(now);

      // 박스 열기 (generic 타입은 DailyData)
      Box<DailyData> box;
      if (Hive.isBoxOpen('dailyDataBox')) {
        box = Hive.box<DailyData>('dailyDataBox');
      } else {
        box = await Hive.openBox<DailyData>('dailyDataBox');
      }

      // 오늘의 DailyData 가져오기 또는 새로 생성
      DailyData today = box.get(key) ?? DailyData.empty();
      debugPrint(
        '[BG] loaded DailyData for $key | gallery=${today.gallery.length}, loc=${today.location.length}, noti=${today.appnoti.length}',
      );

      // 안전히 복사하여 appnoti 리스트에 추가
      final List<AppNotification> newAppNoti = List.from(today.appnoti);
      newAppNoti.add(noti);

      final DailyData updated = today.copyWith(appnoti: newAppNoti);

      // 저장 (put으로 key에 덮어쓰기)
      await box.put(key, updated);
      debugPrint('[BG] 저장 성공 $key | noti=${updated.appnoti.length}');
    } catch (hiveErr) {
      // Hive 실패시 파일 폴백
      final Map<String, dynamic> record = {
        'timestamp': now.toIso8601String(),
        'millis': now.millisecondsSinceEpoch,
        'event': {
          'package': noti.appname,
          'text': noti.text,
          'timestamp': noti.timestamp.toIso8601String(),
        },
        'error': hiveErr.toString(),
      };
      appendRecordToFileSync(record);
    }

    // 메인 isolate로 전송 (있다면)
    final SendPort? send = IsolateNameServer.lookupPortByName('_listener_');
    if (send != null) {
      send.send({
        'appname': noti.appname,
        'text': noti.text,
        'timestamp': noti.timestamp.toIso8601String(),
      });
    }
  } catch (e, st) {
    debugPrint('error in background callback: $e\n$st');
  }
}

/// NotificationEvent -> Notification 모델로 변환
AppNotification eventToNotification(NotificationEvent evt, DateTime now) {
  try {
    final dynamic e = evt as dynamic;
    final String pkg = (e.packageName ?? e.pkg ?? 'unknown').toString();
    final String title = (e.title ?? '').toString();
    final String body = (e.text ?? e.content ?? '').toString();
    final String text = title.isNotEmpty
        ? (title + (body.isNotEmpty ? ': $body' : ''))
        : body;

    return AppNotification(appname: pkg, text: text, timestamp: now);
  } catch (_) {
    return AppNotification(
      appname: 'unknown',
      text: evt.toString(),
      timestamp: now,
    );
  }
}

/// 날짜 키 생성: yyyy-MM-dd
String dateKey(DateTime dt) {
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Hive 초기화 및 어댑터 등록 보장 함수 (백그라운드 isolate 안전성 고려)
Future<void> ensureHiveReady() async {
  // 이미 박스가 열려있으면 보통 준비된 상태
  if (Hive.isBoxOpen('dailyDataBox')) return;

  // 1) 초기화 (앱 도큐먼트 경로 사용; 실패 시 systemTemp 사용)
  try {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocDir.path);
  } catch (e) {
    try {
      Hive.init(Directory.systemTemp.path);
    } catch (_) {
      // 초기화 자체가 실패하면 이후 Hive 호출이 예외를 던짐
    }
  }

  // 2) 어댑터 등록 (중복 등록 방지)
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(AppNotificationAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(LocationAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(DailyDataAdapter());
  }

  // 3) dailyDataBox 열어두기 (필요 시)
  if (!Hive.isBoxOpen('dailyDataBox')) {
    await Hive.openBox<DailyData>('dailyDataBox');
  }
}

/// 파일 백업 저장(JSONL)
void appendRecordToFileSync(Map<String, dynamic> record) {
  try {
    final Directory tmpDir = Directory.systemTemp;
    final File f = File('${tmpDir.path}/notification_log.jsonl');

    final RandomAccessFile raf = f.existsSync()
        ? f.openSync(mode: FileMode.append)
        : f.openSync(mode: FileMode.write);

    raf.writeStringSync('${jsonEncode(record)}\n');
    raf.closeSync();
  } catch (e) {
    debugPrint('[파일 저장 실패] $e');
  }
}

 */