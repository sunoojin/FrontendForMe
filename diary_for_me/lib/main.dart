import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 로컬 저장소
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_notification_listener_plus/flutter_notification_listener_plus.dart';

import 'package:diary_for_me/collect/notification.dart';
import 'package:diary_for_me/db_models/daily_data/daily_data_model.dart';
import 'package:diary_for_me/db_models/diary/diary_content_model.dart';
import 'package:diary_for_me/db_models/event/event_model.dart';
import 'package:diary_for_me/db_models/timeline/timeline_model.dart';

import 'db_models/diary/diary_model.dart';
import 'home/screen/home_screen.dart';
import 'tutorial/screen/first_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);

  // SharedPreferences 인스턴스 가져오기
  final prefs = await SharedPreferences.getInstance();

  // 사용자 정보 입력 여부 확인 (true면 이미 입력 완료)
  final bool hasUserInfo = prefs.getBool('hasUserInfo') ?? false;

  // Hive db 코드
  // Hive 초기화
  await Hive.initFlutter();
  // 어댑터 호출
  // 데일리 데이터
  Hive.registerAdapter(AppNotificationAdapter()); // Notification
  Hive.registerAdapter(LocationAdapter()); // LocationData
  Hive.registerAdapter(DailyDataAdapter()); // DailyData
  // 일기
  Hive.registerAdapter(DiaryContentAdapter()); // DiaryContent
  Hive.registerAdapter(DiaryAdapter()); // Diary
  // 이벤트
  Hive.registerAdapter(EventAdapter()); // Event
  // 타임라인
  Hive.registerAdapter(TimeLineAdapter()); // Timeline

  // open
  await Hive.openBox<Tag>('tagsBox');
  await Hive.openBox<Diary>('diaryBox');
  await Hive.openBox<TimeLine>('timelineBox');

  await dotenv.load(fileName: ".env");

  // 2. 키 가져오기
  String clientId = dotenv.env['NAVER_CLIENT_ID'] ?? '';

  // 3. SDK 초기화에 사용
  await FlutterNaverMap().init(
    clientId: clientId,
    onAuthFailed: (ex) {
      switch (ex) {
        case NQuotaExceededException(:final message):
          debugPrint("사용량 초과 (message: $message)");
          break;
        case NUnauthorizedClientException() ||
            NClientUnspecifiedException() ||
            NAnotherAuthFailedException():
          debugPrint("인증 실패: $ex");
          break;
      }
    },
  );

  await NotificationsListener.initialize(); // 1) 플러그인 초기화
  await NotificationsListener.registerEventHandle(
    // 2) 콜백 등록
    backgroundCallback, //  static / 최상위 함수
  );

  await initializeService();

  runApp(MyApp(hasUserInfo: hasUserInfo));
}

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
  // minutes: 1
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

    // isTimeSlot
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

class MyApp extends StatelessWidget {
  final bool hasUserInfo;
  const MyApp({super.key, required this.hasUserInfo});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diary for me',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: hasUserInfo ? const HomePage() : const FirstScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
