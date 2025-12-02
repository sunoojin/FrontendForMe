import 'dart:async';
import 'dart:ui';

import 'package:diary_for_me/DB/service_status_manager.dart';
import 'package:diary_for_me/DB/timeline/timeline_model.dart';
import 'package:diary_for_me/api_service/get_timeline_api.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';
import 'package:isar/isar.dart'; // [필수] Isar 패키지

// [필수] DB 매니저 및 모델 import
import '../DB/db_manager.dart';
import '../DB/background_log/background_log_model.dart';
import 'location_collector.dart';

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
        AndroidFlutterLocalNotificationsPlugin
      >()
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
  print('백그라운드 서비스 시작됨');

  DartPluginRegistrant.ensureInitialized();

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
            ongoing: true, // 지울 수 없음
            autoCancel: false, // 터치해도 안 사라짐
            showWhen: true,
          ),
        ),
      );

      // [안전장치] 네이티브 서비스 정보도 같이 업데이트 (일부 기기 호환성 위해)
      service.setForegroundNotificationInfo(title: '나의 일기장', content: content);
    }
  }

  // 첫 알림 즉시 표시
  await showNotification('서비스가 시작되는 중입니다');

  // [DB 연결]
  final isar = await DB().instance;
  final statusManager = ServiceStatusManager();

  // 상태 변경 함수
  Future<AppServiceState> updatedState() async {
    final now = DateTime.now();

    if (now.hour >= 6 && now.hour < 21) {
      statusManager.updateServiceStatus(AppServiceState.collecting);
      return AppServiceState.collecting;
    } else {
      DateTime targetDate = (now.hour >= 21)
          ? DateTime(now.year, now.month, now.day)
          : DateTime(
              now.year,
              now.month,
              now.day,
            ).subtract(const Duration(days: 1));
      final latestTimeLine = await isar.timeLines
          .where()
          .sortByDateDesc()
          .findFirst();

      if (latestTimeLine != null) {
        if (latestTimeLine.date.year == targetDate.year &&
            latestTimeLine.date.month == targetDate.month &&
            latestTimeLine.date.day == targetDate.day) {
          statusManager.updateServiceStatus(AppServiceState.waiting);
          return AppServiceState.waiting;
        }
      } else {
        statusManager.updateServiceStatus(AppServiceState.processing);
        return AppServiceState.processing;
      }
    }

    return AppServiceState.waiting;
  }

  AppServiceState currentState = await updatedState();

  bool isAnalysisRunning = false;

  switch (currentState) {
    case AppServiceState.collecting:
      await showNotification('정보를 수집중이에요');
      break;
    case AppServiceState.processing:
      await showNotification('타임라인을 생성중이에요');
      break;
    case AppServiceState.waiting:
      await showNotification('기록이 끝났어요');
      break;
  }

  // 1분마다 반복
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    print('백그라운드 서비스 실행됨');

    AppServiceState targetState = await updatedState();

    if (currentState != targetState && !isAnalysisRunning) {
      currentState = targetState;
      switch (currentState) {
        case AppServiceState.collecting:
          await showNotification('정보를 수집중이에요');
          break;
        case AppServiceState.processing:
          await showNotification('타임라인을 생성중이에요');
          break;
        case AppServiceState.waiting:
          await showNotification('기록이 끝났어요');
          break;
      }
    }

    switch (currentState) {
      case AppServiceState.collecting:
        // 정보 수집 함수
        await saveLocation();
        break;

      case AppServiceState.processing:
        if (!isAnalysisRunning) {
          isAnalysisRunning = true;

          // 타임라인 요청 함수
          bool success = await generateTimeline();

          isAnalysisRunning = false;

          if (success) {
            // 성공했으면 바로 대기 모드로 전환
            currentState = AppServiceState.waiting;
            await showNotification('타임라인 생성 성공');
          }
        }
        break;

      case AppServiceState.waiting:
        // 대기 중에는 아무것도 안 함
        break;
    }
  });
}
