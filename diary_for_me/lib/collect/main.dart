import 'dart:async';
// import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:path/path.dart' as p;

const platform = MethodChannel('com.example.yourapp/notifications');
const String boxName = 'notifications_box';

// 모델 (간단)
class MyNotification {
  final String? title;
  final String? text;
  final String? packageName;
  final DateTime receivedAt; // 실제로 postTime이 있으면 그 시간 사용, 없으면 DateTime.now()

  MyNotification({
    required this.title,
    required this.text,
    required this.packageName,
    required this.receivedAt,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'text': text,
    'packageName': packageName,
    'receivedAt': receivedAt.millisecondsSinceEpoch,
  };

  static MyNotification fromMap(Map<dynamic, dynamic> m) => MyNotification(
    title: m['title'] as String?,
    text: m['text'] as String?,
    packageName: m['packageName'] as String?,
    receivedAt: DateTime.fromMillisecondsSinceEpoch(m['receivedAt'] as int),
  );

  @override
  String toString() =>
      '${receivedAt.toIso8601String()} | ${packageName ?? ""} | ${title ?? ""} - ${text ?? ""}';
}

// ----------------------------
// 백그라운드 콜백: 반드시 톱레벨이며 entry-point로 표시
// ----------------------------
@pragma('vm:entry-point')
Future<void> alarmBackgroundCallback() async {
  // NOTE: 이 함수는 앱 포그라운드/백그라운드 상관없이 주기적으로 호출될 수 있음.
  // 1) MethodChannel로 앱 파일 경로 얻어 Hive 초기화
  try {
    final String appFilesDir = await platform.invokeMethod('getAppFilesDir');
    // Hive init with the path (not Hive.initFlutter)
    Hive.init(appFilesDir);
    // open a simple box storing Map<String,dynamic>
    final box = await Hive.openBox('notifications_box');

    // 2) getActiveNotifications via method channel
    final dynamic res = await platform.invokeMethod('getActiveNotifications');
    if (res is List<dynamic>) {
      for (final item in res) {
        // item from native is Map<String, Object>
        final Map<dynamic, dynamic> map = Map<dynamic, dynamic>.from(item);
        final String? title = map['title'] as String?;
        final String? text = map['text'] as String?;
        final String? pkg = map['packageName'] as String?;
        final dynamic postTime = map['postTime'];

        DateTime receivedAt;
        if (postTime is int) {
          receivedAt = DateTime.fromMillisecondsSinceEpoch(postTime);
        } else if (postTime is double) {
          receivedAt = DateTime.fromMillisecondsSinceEpoch(postTime.toInt());
        } else {
          receivedAt = DateTime.now();
        }

        final notif = MyNotification(
          title: title,
          text: text,
          packageName: pkg,
          receivedAt: receivedAt,
        );

        // 중복 저장 방지: 간단하게 같은 package+title+text+receivedAt 조합이 없으면 저장
        final exists = box.values.any((v) {
          try {
            final m = Map<dynamic, dynamic>.from(v as Map);
            return (m['title'] == notif.title) &&
                (m['text'] == notif.text) &&
                (m['packageName'] == notif.packageName) &&
                (m['receivedAt'] == notif.receivedAt.millisecondsSinceEpoch);
          } catch (_) {
            return false;
          }
        });
        if (!exists) {
          await box.add(notif.toMap());
          log('Background saved: $notif');
        }
      }
    }
    await box.close();
  } catch (e, st) {
    log('alarmBackgroundCallback error: $e\n$st');
  }
}

// ----------------------------
// 앱 런타임 코드: 스케줄링 + UI + 날짜별 조회
// ----------------------------
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 반드시 android_alarm_manager_plus 초기화
  await AndroidAlarmManager.initialize();

  // 초기화: Hive (foreground)
  await Hive.initFlutter();
  await Hive.openBox('notifications_box');

  runApp(const MyApp());

  // 스케줄: 15분마다 실행(원하면 간격 조정)
  // id는 정수로 관리
  await AndroidAlarmManager.periodic(
    const Duration(minutes: 15),
    0, // alarm id
    alarmBackgroundCallback,
    wakeup: true,
    exact: false,
    rescheduleOnReboot: true,
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DateTime _selected = DateTime.now();
  List<String> _items = [];

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _selected = d);
  }

  Future<void> _fetchForDate() async {
    final box = await Hive.openBox('notifications_box');
    final start = DateTime(_selected.year, _selected.month, _selected.day);
    final end = DateTime(
      _selected.year,
      _selected.month,
      _selected.day,
      23,
      59,
      59,
      999,
    );

    final List<String> out = [];
    for (final v in box.values) {
      try {
        final Map m = Map.from(v as Map);
        final DateTime dt = DateTime.fromMillisecondsSinceEpoch(
          m['receivedAt'] as int,
        );
        if (!dt.isBefore(start) && !dt.isAfter(end)) {
          final title = m['title'] ?? '';
          final text = m['text'] ?? '';
          final pkg = m['packageName'] ?? '';
          out.add('${dt.toIso8601String()} | $pkg | $title - $text');
        }
      } catch (_) {}
    }
    setState(() => _items = out);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BG Notification Collector',
      home: Scaffold(
        appBar: AppBar(title: const Text('BG Notification Collector')),
        body: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text('Pick Date'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _fetchForDate,
                  child: const Text('Get for Date'),
                ),
              ],
            ),
            Expanded(
              child: _items.isEmpty
                  ? const Center(child: Text('No notifications'))
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (_, i) => ListTile(title: Text(_items[i])),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
