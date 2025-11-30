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
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('stopService').listen((event) {
      service.stopSelf();
    });
  }

  // 알림 헬퍼 함수
  Future<void> showNotification(String content) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        flutterLocalNotificationsPlugin.show(
          notificationId,
          '나의 일기장',
          content,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              notificationChannelId,
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
              autoCancel: false,
              showWhen: true,
            ),
          ),
        );
      }
    }
  }

  await showNotification('위치 기록 대기 중... (매시 00분, 30분)');

  // [변경] Isar DB 인스턴스 가져오기 (싱글톤)
  // 백그라운드에서도 DB().instance만 부르면 알아서 연결됩니다.
  final isar = await DB().instance;

  // 타이머 시작 (1분마다)
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    final now = DateTime.now();

    // ==========================================================
    // [테스트용] 현재 Isar LocationLog 데이터 확인 로그
    // ==========================================================
    // count()는 매우 빠릅니다.
    final count = await isar.locationLogs.count();
    print("\n-------- 📂 [Isar] LocationLog 데이터 확인 (총 ${count}개) --------");

    if (count == 0) {
      print("데이터가 없습니다 (Empty)");
    } else {
      // 최근 10개만 조회하여 출력 (전체 출력은 성능 저하)
      final recentLogs = await isar.locationLogs
          .where()
          .sortByTimestampDesc()
          .limit(10)
          .findAll();

      for (var log in recentLogs) {
        String timeStr = DateFormat('MM-dd HH:mm').format(log.timestamp);
        print(
            "🕒 $timeStr | 📍 ${log.lat?.toStringAsFixed(4)}, ${log.lng?.toStringAsFixed(4)}");
      }
    }
    print("----------------------------------------------------------------------\n");
    // ==========================================================

    // 수면 시간 체크 (06:00 ~ 21:00 외에는 기록 안 함)
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
      // [변경] 중복 기록 방지 (Isar 쿼리)
      // 가장 최근 기록 1개만 가져옵니다.
      final lastLog = await isar.locationLogs
          .where()
          .sortByTimestampDesc()
          .findFirst();

      if (lastLog != null) {
        final difference = now.difference(lastLog.timestamp);
        if (difference.inMinutes < 20) {
          // print("⏳ 이미 기록됨. (마지막 기록: ${difference.inMinutes}분 전)");
          return;
        }
      }

      print(">>> [위치 수집 조건 충족] 현재 시간: $now");

      try {
        // 1) 위치 가져오기
        Position position = await Geolocator.getCurrentPosition(
            locationSettings: AndroidSettings(
              accuracy: LocationAccuracy.high,
            )
        );

        // [변경] Isar 모델 생성 및 저장
        final newLog = LocationLog(
          timestamp: now,
          lat: position.latitude,
          lng: position.longitude,
          // isSynced: false (기본값)
        );

        // [핵심] 트랜잭션으로 안전하게 저장
        await isar.writeTxn(() async {
          await isar.locationLogs.put(newLog);
        });

        print("위치 저장 완료: 위도 ${position.latitude}, 경도 ${position.longitude}");

        // 3) 알림 갱신
        String timeString = DateFormat('HH:mm').format(now);
        await showNotification('$timeString 에 위치가 기록되었습니다.');

      } catch (e) {
        print("위치 수집 실패: $e");
        await showNotification('위치 수집 실패: 권한이나 GPS를 확인해주세요.');
      }
    } else {
      // print("대기 중... 현재 ${now.minute}분 (목표: 00, 30분)");
    }
  });
}