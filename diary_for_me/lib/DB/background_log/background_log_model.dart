import 'package:isar/isar.dart';

part 'background_log_model.g.dart';

@collection
class LocationLog {
  Id id = Isar.autoIncrement; // 자동 증가 ID

  @Index() // 시간 검색을 위해 인덱스 추가
  DateTime timestamp;

  double? lat;
  double? lng;

  LocationLog({
    required this.timestamp,
    this.lat,
    this.lng,
  });
}

@collection
class AppNotificationLog {
  Id id = Isar.autoIncrement;

  @Index()
  DateTime timestamp;

  String? appname;
  String? text;

  AppNotificationLog({
    required this.timestamp,
    this.appname,
    this.text
  });
}