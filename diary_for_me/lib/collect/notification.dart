import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';

/// -----------------------------
/// 1) Hive 모델 정의 (수동 TypeAdapter)
/// -----------------------------

// part 'main.g.dart'; // (없어도 동작하지만, 이 예제는 수동 어댑터를 포함하므로 생략 가능)

// MyNotification: 앱에 저장할 최소 정보만 담음.
// - title, content, packageName, receivedAt
@HiveType(typeId: 0)
class MyNotification extends HiveObject {
  @HiveField(0)
  final String? title;

  @HiveField(1)
  final String? content;

  @HiveField(2)
  final String? packageName;

  @HiveField(3)
  final DateTime receivedAt;

  MyNotification({
    required this.title,
    required this.content,
    required this.packageName,
    required this.receivedAt,
  });

  @override
  String toString() {
    return '${receivedAt.toIso8601String()} | ${packageName ?? "unknown"} | ${title ?? ""} - ${content ?? ""}';
  }
}

/// 수동 TypeAdapter (자동 생성 환경이 아니라 수동으로 명시)
class MyNotificationAdapter extends TypeAdapter<MyNotification> {
  @override
  final int typeId = 0;

  @override
  MyNotification read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return MyNotification(
      title: fields[0] as String?,
      content: fields[1] as String?,
      packageName: fields[2] as String?,
      receivedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MyNotification obj) {
    writer.writeByte(4);
    writer.writeByte(0);
    writer.write(obj.title);
    writer.writeByte(1);
    writer.write(obj.content);
    writer.writeByte(2);
    writer.write(obj.packageName);
    writer.writeByte(3);
    writer.write(obj.receivedAt);
  }
}

/// -----------------------------
/// 2) NotificationCollector: 알림 수집/저장/조회 기능
/// -----------------------------
class NotificationCollector {
  static const String boxName = 'notifications_box';
  static final NotificationCollector _instance =
      NotificationCollector._internal();

  factory NotificationCollector() => _instance;

  NotificationCollector._internal();

  Box<MyNotification>? _box;
  StreamSubscription<ServiceNotificationEvent>? _subscription;

  Future<void> init() async {
    // Hive 초기화 및 박스 오픈 (main에서 호출)
    await Hive.initFlutter();
    Hive.registerAdapter(MyNotificationAdapter());
    _box = await Hive.openBox<MyNotification>(boxName);
  }

  /// 권한 요청 (사용자에게 권한 요청 화면을 띄움)
  Future<bool> requestPermission() async {
    try {
      final res = await NotificationListenerService.requestPermission();
      return res;
    } catch (e) {
      log('requestPermission error: $e');
      return false;
    }
  }

  /// 권한 확인
  Future<bool> isPermissionGranted() async {
    try {
      return await NotificationListenerService.isPermissionGranted();
    } catch (e) {
      log('isPermissionGranted error: $e');
      return false;
    }
  }

  /// 스트림을 구독해서 들어오는 알림을 Hive에 저장
  /// - start()를 호출하면 앱이 실행되어 있는 동안 들어오는 알림을 수집합니다.
  void start() {
    if (_subscription != null) return; // 이미 시작된 경우 중복구독 방지

    _subscription = NotificationListenerService.notificationsStream.listen(
      (event) {
        try {
          final wrapped = _wrapEventToMyNotification(event);
          if (_box != null && wrapped != null) {
            _box!.add(wrapped);
          }
          log('Saved notification: $wrapped');
        } catch (e, st) {
          log('Error saving notification: $e\n$st');
        }
      },
      onError: (e, st) {
        log('notificationsStream error: $e\n$st');
      },
    );
  }

  /// 스트림 중지
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  /// ServiceNotificationEvent에서 필요한 필드만 추출하여 MyNotification으로 변환
  MyNotification? _wrapEventToMyNotification(ServiceNotificationEvent event) {
    try {
      final title = event.title;
      final content = event.content;
      final packageName = event.packageName;
      final receivedAt = DateTime.now(); // 핵심: 수신 시각을 직접 찍어 저장

      return MyNotification(
        title: title,
        content: content,
        packageName: packageName,
        receivedAt: receivedAt,
      );
    } catch (e) {
      log('wrapEvent error: $e');
      return null;
    }
  }

  /// 특정 날짜(targetDate)의 알림만 반환 (String 리스트)
  /// - targetDate의 00:00:00 ~ 23:59:59.999 범위의 알림을 반환
  Future<List<String>> getNotificationsForDate(DateTime targetDate) async {
    if (_box == null) {
      log('Box not opened yet.');
      return [];
    }
    final start = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      0,
      0,
      0,
    );
    final end = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      23,
      59,
      59,
      999,
    );

    final List<String> out = [];
    for (final item in _box!.values) {
      final dt = item.receivedAt;
      if (!dt.isBefore(start) && !dt.isAfter(end)) {
        out.add(
          '${item.receivedAt.toIso8601String()} | ${item.packageName ?? "unknown"} | ${item.title ?? ""} - ${item.content ?? ""}',
        );
      }
    }
    return out;
  }

  /// 테스트/디버그: 박스 전체 초기화(삭제)
  Future<void> clearAll() async {
    await _box?.clear();
  }

  /// 테스트/디버그: 현재 박스에 저장된 전체 개수
  int totalSavedCount() {
    return _box?.length ?? 0;
  }
}

/// -----------------------------
/// 3) UI: 권한 요청, 수집 시작/중지, 날짜 선택 후 해당 날짜 알림 보기
/// -----------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 및 collector 초기화
  final collector = NotificationCollector();
  await collector.init();

  runApp(MyApp(collector: collector));
}

class MyApp extends StatefulWidget {
  final NotificationCollector collector;
  const MyApp({super.key, required this.collector});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _listening = false;
  DateTime _selectedDate = DateTime.now();
  List<String> _results = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // 앱 시작 시 자동으로 리스너 시작하지 않으려면 주석처리하세요.
    // widget.collector.start();
    // _listening = true;
  }

  Future<void> _requestPermission() async {
    final ok = await widget.collector.requestPermission();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Permission requested: $ok')));
  }

  Future<void> _checkPermission() async {
    final ok = await widget.collector.isPermissionGranted();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Permission granted: $ok')));
  }

  void _startListening() {
    widget.collector.start();
    setState(() {
      _listening = true;
    });
  }

  Future<void> _stopListening() async {
    await widget.collector.stop();
    setState(() {
      _listening = false;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _fetchForSelectedDate() async {
    setState(() {
      _loading = true;
      _results = [];
    });
    final list = await widget.collector.getNotificationsForDate(_selectedDate);
    setState(() {
      _results = list;
      _loading = false;
    });
  }

  Future<void> _clearAll() async {
    await widget.collector.clearAll();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.collector.totalSavedCount();
    return MaterialApp(
      title: 'Notification Collector',
      home: Scaffold(
        appBar: AppBar(title: const Text('Notification Collector (Hive)')),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: _requestPermission,
                      child: const Text('Request Permission'),
                    ),
                    ElevatedButton(
                      onPressed: _checkPermission,
                      child: const Text('Check Permission'),
                    ),
                    ElevatedButton(
                      onPressed: _listening ? null : _startListening,
                      child: Text(
                        _listening ? 'Listening...' : 'Start Listening',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _listening ? _stopListening : null,
                      child: const Text('Stop Listening'),
                    ),
                    ElevatedButton(
                      onPressed: _clearAll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Clear Stored'),
                    ),
                    Text('Saved: $total'),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Text(
                      'Selected date: ${_selectedDate.toLocal().toIso8601String().split('T').first}',
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _pickDate,
                      child: const Text('Pick Date'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _fetchForSelectedDate,
                      child: const Text('Get for Date'),
                    ),
                  ],
                ),
              ),
              if (_loading) const LinearProgressIndicator(),
              const Divider(),
              Expanded(
                child: _results.isEmpty
                    ? const Center(
                        child: Text('No notifications for selected date.'),
                      )
                    : ListView.separated(
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          return ListTile(title: Text(_results[index]));
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
