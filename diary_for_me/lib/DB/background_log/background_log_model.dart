// import 'package:diary_for_me/DB/daily_data/daily_data_model.dart';
import 'package:isar/isar.dart';

part 'background_log_model.g.dart';

@collection
class LocationLog {
  Id id = Isar.autoIncrement; // 자동 증가 ID

  @Index() // 시간 검색을 위해 인덱스 추가
  DateTime timestamp;

  double? lat;
  double? lng;

  LocationLog({required this.timestamp, this.lat, this.lng});
}

@collection
class AppNotificationLog {
  Id id = Isar.autoIncrement;

  @Index()
  DateTime timestamp;

  String? appname;
  String? text;

  AppNotificationLog({required this.timestamp, this.appname, this.text});
}

enum AppServiceState {
  collecting, // 수집 중 (06:00 ~ 21:00)
  processing, // 분석 중 (21:00 ~ 처리 완료)
  waiting, // 휴식 중 (처리 완료 ~ 06:00)
}

@collection
class ServiceStatus {
  Id id = 0; // 항상 0번 ID만 사용 (덮어쓰기 위해)

  @enumerated // Enum을 DB에 저장하기 위한 어노테이션
  AppServiceState state;

  ServiceStatus({required this.state});
}
