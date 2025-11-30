import 'package:isar/isar.dart';

part 'daily_data_model.g.dart';

@embedded
class AppNotification {
  String? appname;
  String? text;

  DateTime? timestamp;

  AppNotification({
    this.appname,
    this.text,
    this.timestamp
  });

  AppNotification clone() {
    return AppNotification(
      appname: this.appname,
      text: this.text,
      timestamp: this.timestamp
    );
  }
}

@embedded
class Location {
  double? lat;

  double? lng;

  DateTime? timestamp;

  Location({
    this.lat,
    this.lng,
    this.timestamp
  });

  Location clone() {
    return Location(
      lat: this.lat,
      lng: this.lng,
      timestamp: this.timestamp
    );
  }
}

@embedded
class DailyData {
  List<String> gallery;

  List<Location> location;

  List<AppNotification> appnoti;

  DailyData({
    this.gallery = const [],
    this.location = const [],
    this.appnoti = const []
  });

  DailyData clone() {
    return DailyData(
      // 1. String은 불변(Immutable)이므로 List.from으로도 충분합니다.
      gallery: List<String>.from(this.gallery),

      // 2. 객체 리스트는 하나씩 꺼내서(.map) clone()을 돌려줘야 합니다.
      location: this.location.map((e) => e.clone()).toList(),

      // 3. 마찬가지로 하나씩 복제합니다.
      appnoti: this.appnoti.map((e) => e.clone()).toList(),
    );
  }
}