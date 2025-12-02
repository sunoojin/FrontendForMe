import 'dart:async';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart'; // [필수] Isar 패키지

// [필수] DB 매니저 및 모델 import
import '../DB/db_manager.dart';
import '../DB/background_log/background_log_model.dart';

const notificationChannelId = 'my_foreground';
const notificationId = 888;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId,
    'MY FOREGROUND SERVICE',
    description: 'This channel is used for important notifications.',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: notificationChannelId,
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: notificationId,
    ),
    iosConfiguration: IosConfiguration(),
  );
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  // 1. 플러그인 초기화
  DartPluginRegistrant.ensureInitialized();

  // 2. [가장 중요] 서비스 시작 즉시 네이티브 쪽에 알림 정보 등록 (앱 꺼짐 방지)
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    // ★ 이 코드가 안드로이드 시스템에게 "나 정상적으로 켜졌어"라고 알려주는 역할입니다.
    await service.setForegroundNotificationInfo(
      title: 'MY FOREGROUND SERVICE',
      content: '서비스 초기화 중...',
    );
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // 3. 알림 헬퍼 함수 (조건문 제거함)
  Future<void> showNotification(String content) async {
    if (service is AndroidServiceInstance) {
      // ★ 제거함: if (await service.isForegroundService())
      // 이유: 서비스 시작 초기에는 이 값이 false일 수 있어 알림이 씹히고 앱이 죽음.

      // FLNP로 알림 갱신
      await flutterLocalNotificationsPlugin.show(
        notificationId,
        '나의 일기장',
        content,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            notificationChannelId,
            'MY FOREGROUND SERVICE',
            icon: 'ic_bg_service_small',
            ongoing: true,            // 지울 수 없음
            autoCancel: false,        // 터치해도 안 사라짐
            showWhen: true,
          ),
        ),
      );

      // [안전장치] 네이티브 서비스 정보도 같이 업데이트 (일부 기기 호환성 위해)
      service.setForegroundNotificationInfo(
        title: '나의 일기장',
        content: content,
      );
    }
  }

  // 첫 알림 즉시 표시
  await showNotification('위치 기록 대기 중... (매시 00분, 30분)');

  // [DB 연결]
  final isar = await DB().instance;

  // 매 1분마다 실행됨
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    final now = DateTime.now();

    // === [로그 확인용 로직 유지] ===
    final count = await isar.locationLogs.count();
    print("\n-------- 📂 [Isar] LocationLog 데이터 확인 (총 ${count}개) --------");
    if (count > 0) {
      final recentLogs = await isar.locationLogs.where().sortByTimestampDesc().limit(1).findAll();
      print("🕒 최신 기록: ${DateFormat('MM-dd HH:mm').format(recentLogs[0].timestamp)}");
    }
    print("----------------------------------------------------------------------\n");

    // 수면 시간 체크
    if (now.hour < 6 || now.hour >= 21) {
      if (now.minute == 0) {
        await showNotification('수면 시간에는 위치를 기록하지 않습니다. 🌙');
      }
      return;
    }

    // 00분, 30분 체크
    bool isTimeSlot = (now.minute >= 0 && now.minute <= 5) ||
        (now.minute >= 30 && now.minute <= 35);

    if (isTimeSlot) {
      final lastLog = await isar.locationLogs.where().sortByTimestampDesc().findFirst();

      if (lastLog != null) {
        final difference = now.difference(lastLog.timestamp);
        if (difference.inMinutes < 20) {
          return;
        }
      }

      print(">>> [위치 수집 시작]");

      try {
        Position position = await Geolocator.getCurrentPosition(
            locationSettings: AndroidSettings(
              accuracy: LocationAccuracy.high,
              // 타임아웃 설정 (GPS가 안 잡히면 무한 대기하는 것 방지)
              timeLimit: const Duration(seconds: 10),
            )
        );

        final newLog = LocationLog(
          timestamp: now,
          lat: position.latitude,
          lng: position.longitude,
        );

        await isar.writeTxn(() async {
          await isar.locationLogs.put(newLog);
        });

        String timeString = DateFormat('HH:mm').format(now);
        await showNotification('$timeString 에 위치가 기록되었습니다.');

      } catch (e) {
        print("위치 수집 실패: $e");
        await showNotification('위치 정보를 가져올 수 없습니다.');
      }
    }
  });
}