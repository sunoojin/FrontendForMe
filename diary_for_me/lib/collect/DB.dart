import 'dart:convert';
import 'dart:io';

/// Notification 백그라운드 콜백에서도 항상 동작하는 파일 기반 DB.
/// JSONL(한 줄 한 JSON) 형태로 저장됨.
class NotificationDB {
  final File file;

  NotificationDB._(this.file);

  /// 싱글턴 인스턴스
  static final NotificationDB instance = NotificationDB._(
    File('${Directory.systemTemp.path}/notification_log.jsonl'),
  );

  /// 외부에서 편하게 접근하기 위한 단축명
  static NotificationDB get db => instance;

  /// record(Map or any JSON 가능한 값)를 한 줄로 저장 (append)
  void save(dynamic record) {
    try {
      final String line = '${jsonEncode(record)}\n';

      final raf = file.existsSync()
          ? file.openSync(mode: FileMode.append)
          : file.openSync(mode: FileMode.write);

      raf.writeStringSync(line);
      raf.closeSync();
    } catch (e) {
      print('[NotificationDB] save error: $e');
    }
  }

  /// 전체 로그를 List<Map> 형태로 읽기
  List<Map<String, dynamic>> load() {
    try {
      if (!file.existsSync()) return [];

      final lines = file.readAsLinesSync();
      return lines.where((line) => line.trim().isNotEmpty).map((line) {
        try {
          final jsonObj = jsonDecode(line);
          return jsonObj as Map<String, dynamic>;
        } catch (_) {
          return <String, dynamic>{'raw': line};
        }
      }).toList();
    } catch (e) {
      print('[NotificationDB] load error: $e');
      return [];
    }
  }

  /// 파일 초기화
  void clear() {
    try {
      if (file.existsSync()) {
        file.writeAsStringSync('');
      }
    } catch (e) {
      print('[NotificationDB] clear error: $e');
    }
  }
}

/// 전역에서 db로 접근 가능하게
final db = NotificationDB.db;
