import 'package:diary_for_me/DB/background_log/background_log_model.dart';
import 'package:diary_for_me/DB/db_manager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

Future<void> saveLocation() async {
  print('#################### 위치 저장 시도 ####################');
  final now = DateTime.now();

  // 1. 시간 체크 (00~05분, 30~35분)
  bool isTimeSlot = (now.minute >= 0 && now.minute <= 5) ||
      (now.minute >= 30 && now.minute <= 35);

  if (!isTimeSlot) return; // 수집 시간이 아니면 종료

  try {
    final isar = await DB().instance;

    final count = await isar.locationLogs.count();

    print('$count 개의 위치가 수집됨');

    // 2. 중복 수집 방지 (20분 내 기록 확인)
    final lastLog = await isar.locationLogs.where().sortByTimestampDesc().findFirst();
    if (lastLog != null && now.difference(lastLog.timestamp).inMinutes < 20) {
      return; // 이미 기록됨
    }

    // 3. 권한 체크
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }
    }

    // 4. 위치 가져오기
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );

    // 5. [핵심] DB 저장 (여기서 바로 저장합니다)
    final newLog = LocationLog(
      timestamp: now,
      lat: position.latitude,
      lng: position.longitude,
    );

    await isar.writeTxn(() async {
      await isar.locationLogs.put(newLog);
    });

    print("✅ [LocationTask] 위치 저장 완료: ${DateFormat('HH:mm').format(now)}");

  } catch (e) {
    print("❌ [LocationTask] 에러 발생: $e");
  }
}