import 'dart:isolate';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_notification_listener_plus/flutter_notification_listener_plus.dart';
// import 'package:notification_listener_service/notification_event.dart';

import 'package:diary_for_me/collect/DB.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 알림 리스너 플러그인 초기화
  await NotificationsListener.initialize(
    callbackHandle: _callback, // 백그라운드 엔트리포인트 연결
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Map<String, dynamic>> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  void _loadLogs() {
    final raw = db.load(); // List<Map<String,dynamic>>
    final List<Map<String, dynamic>> normalized = raw.map((r) {
      final event = (r['event'] ?? {}) as Map<String, dynamic>;
      return {
        'package': event['package'] ?? r['package'],
        'title': event['title'] ?? '',
        'text': event['text'] ?? '',
        'timestamp': event['timestamp'] ?? r['timestamp'],
        'millis': r['millis'],
        // 원본 보존하고 싶으면 아래 같이 포함
        'raw': r,
      };
    }).toList();

    setState(() {
      _logs = normalized;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("알림 기록"),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadLogs, // 버튼 눌리면 새로고침
            ),
          ],
        ),
        body: _logs.isEmpty
            ? const Center(child: Text("기록이 없습니다"))
            : ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final record = _logs[index];
                  return ListTile(
                    title: Text(record['title'] ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("앱: ${record['package']}"),
                        Text("내용: ${record['text']}"),
                        Text("시간: ${record['timestamp']}"),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

/// 백그라운드 엔트리 포인트로 사용
@pragma('vm:entry-point')
void _callback(NotificationEvent evt) {
  try {
    // 1) 시간 붙이기 (ISO + epoch 밀리초)
    final DateTime now = DateTime.now();
    final Map<String, dynamic> record = {
      'timestamp': now.toIso8601String(),
      'millis': now.millisecondsSinceEpoch,
      'event': eventToMapSafe(evt),
    };

    // 2) 우선 시도: 만약 프로젝트에 db.save가 있으면 그걸 호출
    try {
      db.save(record);
    } catch (dbErr) {
      // DB가 없거나 에러가 나면 파일에 폴백
      _appendRecordToFileSync(record);
    }

    // 3) UI 스레드(메인 isolate)로 이벤트 전송 (있다면)
    final SendPort? send = IsolateNameServer.lookupPortByName('_listener_');
    if (send != null) send.send(record);
  } catch (e, st) {
    debugPrint('error: $e\n$st');
  }
}

/// NotificationEvent를 Map으로 변환
Map<String, dynamic> eventToMapSafe(NotificationEvent evt) {
  try {
    final dynamic e = evt as dynamic;

    return {
      'package': e.packageName ?? e.pkg ?? 'unknown',
      'title': e.title ?? '',
      'text': e.text ?? e.content ?? '',
      'timestamp': DateTime.now().toIso8601String(),
    };
  } catch (_) {
    return {'raw': evt.toString()};
  }
}

/// 파일 백업 저장(JSONL)
void _appendRecordToFileSync(Map<String, dynamic> record) {
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
