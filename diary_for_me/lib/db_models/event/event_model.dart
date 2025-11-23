import 'dart:math';

import 'package:hive/hive.dart';
import '../daily_data/daily_data_model.dart';

part 'event_model.g.dart';

@HiveType(typeId: 20) // typeId는 앱 내의 다른 HiveType과 겹치지 않아야 합니다.
class Event extends HiveObject implements Comparable<Event>{

  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime timestamp;

  @HiveField(2)
  String title;

  @HiveField(3)
  String content;

  @HiveField(4)
  String feeling;

  @HiveField(5)
  DailyData dailydata;

  Event({
    required this.id,
    required this.timestamp,
    required this.title,
    required this.content,
    required this.feeling,
    required this.dailydata,
  });

  factory Event.empty() {
    return Event(
      id: '',
      timestamp: DateTime.now(),
      title: '',
      content: '',
      feeling: '',
      dailydata: DailyData.empty()
    );
  }

  Event copyWith({
    String? id,
    DateTime? timestamp,
    String? title,
    String? content,
    String? feeling,
    DailyData? dailydata
  }) {
    return Event(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      title: title ?? this.title,
      content: content ?? this.content,
      feeling: feeling ?? this.feeling,
      dailydata: dailydata ?? this.dailydata.copyWith()
    );
  }

  @override
  int compareTo(Event other) {
    // TODO: implement compareTo
    return this.timestamp.compareTo(other.timestamp);
  }

  void addPicture(String picture) {
    // 1. 리스트에 추가
    dailydata.gallery.add(picture);

    /*
    // 이미 박스에 들어있는 객체라면 save()를 호출해 변경사항을 확정 짓는 것이 좋습니다.
    if (isInBox) {
      save();
    }

     */
  }

  void removePicture(String picture) {
    if (dailydata.gallery.contains(picture)) {
      dailydata.gallery.remove(picture);
    } else {
      return;
    }

    /*
    if (isInBox) {
      save();
    }

     */
  }
}