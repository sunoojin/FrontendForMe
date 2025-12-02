// import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_notification_listener_plus/flutter_notification_listener_plus.dart';
// import 'package:isar/isar.dart';

// [필수] DB 매니저 및 모델 import (경로 확인해주세요)
import 'package:diary_for_me/DB/db_manager.dart';
import 'package:diary_for_me/DB/background_log/background_log_model.dart';

// 백그라운드 엔트리 포인트
@pragma('vm:entry-point')
Future<void> backgroundCallback(NotificationEvent evt) async {
  print('[BG] callback: ${evt.packageName}');
  // 1. Dart 환경 초기화 (백그라운드에서 필수)
  DartPluginRegistrant.ensureInitialized();

  try {
    // Isar db 인스턴스 열기
    final isar = await DB().instance;

    // 3. 데이터 변환 (Event -> Log Model)
    final log = _eventToLog(evt);

    // 4. DB 저장
    await isar.writeTxn(() async {
      await isar.appNotificationLogs.put(log);
    });
    debugPrint('[BG] Saved to Isar: ${log.text}');

    /*
    // 메인으로 isolated 전송(불필요)
    final SendPort? send = IsolateNameServer.lookupPortByName('_listener_');
    if (send != null) {
      send.send({
        'appname': log.appname,
        'text': log.text,
        'timestamp': log.timestamp.toIso8601String(),
      });
    }
     */
  } catch (e, st) {
    print('error in background callback: $e\n$st');
  }
}

/// NotificationEvent -> AppNotificationLog 모델 변환
AppNotificationLog _eventToLog(NotificationEvent evt) {
  try {
    final dynamic e = evt; // 타입 캐스팅 편의를 위해

    final String pkg = (e.packageName ?? 'unknown').toString();
    final String title = (e.title ?? '').toString();
    final String body = (e.text ?? e.content ?? '').toString();

    // 제목과 내용을 합쳐서 저장 (기존 로직 유지)
    final String text = title.isNotEmpty
        ? (body.isNotEmpty ? '$title: $body' : title)
        : body;

    return AppNotificationLog(
      timestamp: DateTime.now(),
      appname: pkg,
      text: text,
      // isSynced는 기본값 false
    );
  } catch (_) {
    // 파싱 실패 시 원본 문자열이라도 저장
    return AppNotificationLog(
      timestamp: DateTime.now(),
      appname: 'unknown',
      text: evt.toString(),
    );
  }
}
