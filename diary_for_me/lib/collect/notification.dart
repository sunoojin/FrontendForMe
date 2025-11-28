import 'dart:isolate';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_notification_listener_plus/flutter_notification_listener_plus.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'package:diary_for_me/db_models/daily_data/daily_data_model.dart';

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

///////////////////////////////////// 얘전 코드

// import 'package:diary_for_me/collect/DB.dart';
// /// 백그라운드 엔트리 포인트로 사용
// @pragma('vm:entry-point')
// void _callback(NotificationEvent evt) {
//   try {
//     // 1) 시간 붙이기 (ISO + epoch 밀리초)
//     final DateTime now = DateTime.now();
//     final Map<String, dynamic> record = {
//       'timestamp': now.toIso8601String(),
//       'millis': now.millisecondsSinceEpoch,
//       'event': eventToMapSafe(evt),
//     };

//     // 2) 우선 시도: 만약 프로젝트에 db.save가 있으면 그걸 호출
//     try {
//       db.save(record);
//     } catch (dbErr) {
//       // DB가 없거나 에러가 나면 파일에 폴백
//       _appendRecordToFileSync(record);
//     }

//     // 3) UI 스레드(메인 isolate)로 이벤트 전송 (있다면)
//     final SendPort? send = IsolateNameServer.lookupPortByName('_listener_');
//     if (send != null) send.send(record);
//   } catch (e, st) {
//     debugPrint('error: $e\n$st');
//   }
// }

// /// NotificationEvent를 Map으로 변환
// Map<String, dynamic> eventToMapSafe(NotificationEvent evt) {
//   try {
//     final dynamic e = evt as dynamic;

//     return {
//       'package': e.packageName ?? e.pkg ?? 'unknown',
//       'title': e.title ?? '',
//       'text': e.text ?? e.content ?? '',
//       'timestamp': DateTime.now().toIso8601String(),
//     };
//   } catch (_) {
//     return {'raw': evt.toString()};
//   }
// }

// /// 파일 백업 저장(JSONL)
// void _appendRecordToFileSync(Map<String, dynamic> record) {
//   try {
//     final Directory tmpDir = Directory.systemTemp;
//     final File f = File('${tmpDir.path}/notification_log.jsonl');

//     final RandomAccessFile raf = f.existsSync()
//         ? f.openSync(mode: FileMode.append)
//         : f.openSync(mode: FileMode.write);

//     raf.writeStringSync('${jsonEncode(record)}\n');
//     raf.closeSync();
//   } catch (e) {
//     debugPrint('[파일 저장 실패] $e');
//   }
// }

////////////////////////////////////// 실행 예시 main()
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // 알림 리스너 플러그인 초기화
//   await NotificationsListener.initialize(
//     callbackHandle: _callback, // 백그라운드 엔트리포인트 연결
//   );
//   runApp(MyApp());
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   List<Map<String, dynamic>> _logs = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadLogs();
//   }

//   void _loadLogs() {
//     final raw = db.load(); // List<Map<String,dynamic>>
//     final List<Map<String, dynamic>> normalized = raw.map((r) {
//       final event = (r['event'] ?? {}) as Map<String, dynamic>;
//       return {
//         'package': event['package'] ?? r['package'],
//         'title': event['title'] ?? '',
//         'text': event['text'] ?? '',
//         'timestamp': event['timestamp'] ?? r['timestamp'],
//         'millis': r['millis'],
//         // 원본 보존하고 싶으면 아래 같이 포함
//         'raw': r,
//       };
//     }).toList();

//     setState(() {
//       _logs = normalized;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text("알림 기록"),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.refresh),
//               onPressed: _loadLogs, // 버튼 눌리면 새로고침
//             ),
//           ],
//         ),
//         body: _logs.isEmpty
//             ? const Center(child: Text("기록이 없습니다"))
//             : ListView.builder(
//                 itemCount: _logs.length,
//                 itemBuilder: (context, index) {
//                   final record = _logs[index];
//                   return ListTile(
//                     title: Text(record['title'] ?? ''),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("앱: ${record['package']}"),
//                         Text("내용: ${record['text']}"),
//                         Text("시간: ${record['timestamp']}"),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//       ),
//     );
//   }
// }
