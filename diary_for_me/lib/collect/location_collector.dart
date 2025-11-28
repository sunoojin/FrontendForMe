import 'dart:async';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../db_models/daily_data/daily_data_model.dart';

const notificationChannelId = 'my_foreground';

const notificationId = 888;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId, // id
    'MY FOREGROUND SERVICE', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: notificationChannelId, // this must match with notification channel you created above.
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


  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /*
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        flutterLocalNotificationsPlugin.show(
          notificationId,
          'COOL SERVICE',
          'Awesome ${DateTime.now()}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              notificationChannelId,
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
              autoCancel: false
            ),
          ),
        );
      }
    }
  });

   */

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('stopService').listen((event) {
      service.stopSelf();
    });
  }

  // 알림을 띄우는 헬퍼 함수
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
              ongoing: true,      // 고정 알림
              autoCancel: false,
              showWhen: true,
            ),
          ),
        );
      }
    }
  }

  // 초기 알림 표시
  await showNotification('위치 기록 대기 중... (매시 00분, 30분)');

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(LocationAdapter());
  }

  // Box 열기
  final locationBox = await Hive.openBox<Location>('locationBox');

  // 3. 1분마다 검사하는 타이머 시작
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    final now = DateTime.now();

    // ==========================================================
    // [테스트용] 현재 박스에 저장된 내용 전체 출력 로그
    // ==========================================================
    print("\n-------- 📂 [Hive] LocationBox 데이터 확인 (총 ${locationBox.length}개) --------");

    if (locationBox.isEmpty) {
      print("데이터가 없습니다 (Empty)");
    } else {
      // 박스에 있는 모든 데이터를 순회하며 출력
      // 주의: 데이터가 수천 개면 로그창이 도배되어 렉이 걸릴 수 있습니다.
      for (int i = 0; i < locationBox.length; i++) {
        final Location? data = locationBox.getAt(i);
        if (data != null) {
          // 보기 좋게 포맷팅: [인덱스] 시간 | 위도, 경도
          String timeStr = DateFormat('MM-dd HH:mm').format(data.timestamp);
          print("[$i] 🕒 $timeStr | 📍 ${data.lat.toStringAsFixed(4)}, ${data.lng.toStringAsFixed(4)}");
        }
      }
    }
    print("----------------------------------------------------------------------\n");
    // ==========================================================

    // 수집 시간이 아닌 경우
    if (now.hour < 6 || now.hour >= 21) {
      // 범위 밖이라면 기록하지 않음 (알림만 업데이트하여 상태 표시)
      if (now.minute == 0) { // 정각에만 로그 갱신 (배터리 절약)
        await showNotification('수면 시간에는 위치를 기록하지 않습니다. 🌙');
      }
      return;
    }

    // ★ 핵심 로직: 00분 혹은 30분인지 체크
    bool isTimeSlot = (now.minute >= 0 && now.minute <= 5) ||
        (now.minute >= 30 && now.minute <= 35);

    if (isTimeSlot) {

      // 같은 분(minute)에 이미 수집했다면 건너뜀 (중복 방지)
      if (locationBox.isNotEmpty) {
        final lastData = locationBox.values.last;
        final difference = now.difference(lastData.timestamp);

        // 중복 기록 방지
        if (difference.inMinutes < 20) {
          // (로그는 너무 자주 찍히지 않게 주석 처리 하셔도 됩니다)
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

        final newLocation = Location(
            lat: position.latitude,
            lng: position.longitude,
            timestamp: now
        );

        await locationBox.add(newLocation); // ★ Hive에 진짜 저장!

        print("위치 저장 완료: 위도 ${position.latitude}, 경도 ${position.longitude}");

        // 3) 알림 갱신 및 마지막 수집 시간 업데이트
        String timeString = DateFormat('HH:mm').format(now);
        await showNotification('$timeString 에 위치가 기록되었습니다.');


      } catch (e) {
        print("위치 수집 실패: $e");
        // 실패 시에도 알림으로 알려줄 수 있음
        await showNotification('위치 수집 실패: 권한이나 GPS를 확인해주세요.');
      }
    } else {
      // 00분이나 30분이 아닐 때 (디버깅용 로그, 나중에 주석 처리 가능)
      print("대기 중... 현재 ${now.minute}분 (목표: 00, 30분)");
    }
  });
}