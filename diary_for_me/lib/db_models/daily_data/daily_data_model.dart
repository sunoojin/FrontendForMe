import 'package:hive/hive.dart';

part 'daily_data_model.g.dart';

@HiveType(typeId: 0)
class Notification extends HiveObject{
  @HiveField(0)
  String appname;

  @HiveField(1)
  String text;

  @HiveField(2)
  DateTime timestamp;

  Notification({required this.appname, required this.text, required this.timestamp});

  factory Notification.empty() {
    return Notification(
      appname: '',
      text: '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(0), // 1970년 1월 1일
    );
  }

  Notification copyWith({
    String? appname,
    String? text,
    DateTime? timestamp,
  }) {
    return Notification(
      appname: appname ?? this.appname,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp.copyWith(),
    );
  }
}

@HiveType(typeId: 1)
class Location extends HiveObject {
  @HiveField(0)
  double lat;

  @HiveField(1)
  double lng;

  Location({required this. lat, required this.lng});

  factory Location.empty() {
    return Location(lat: 0.0, lng: 0.0);
  }

  Location copyWith({double? lat, double? lng}) {
    return Location(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }
}

@HiveType(typeId: 3)
class DailyData extends HiveObject {

  @HiveField(0)
  List<String> gallery;

  @HiveField(1)
  List<Location> location;

  @HiveField(2)
  List<Notification> appnoti;


  DailyData({
    required this.gallery,
    required this.location,
    required this.appnoti
  });

  factory DailyData.empty() {
    return DailyData(gallery: [], location: [Location.empty()], appnoti: [Notification.empty()]);
  }

  DailyData copyWith({
    List<String>? gallery,
    List<Location>? location,
    List<Notification>? appnoti,
  }) {
    return DailyData(
      // List.from을 사용해야 참조가 끊기고 새로운 리스트가 생성됩니다 (안전)
      gallery: gallery ?? List.from(this.gallery),
      location: location ?? this.location.map((e) => e.copyWith()).toList(),
      appnoti: appnoti ?? this.appnoti.map((e) => e.copyWith()).toList(), // 필요하다면 appnoti.copyWith() 사용
    );
  }
}