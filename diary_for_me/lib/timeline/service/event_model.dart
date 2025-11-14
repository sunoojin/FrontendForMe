import 'package:hive/hive.dart';

part 'event_model.g.dart';

@HiveType(typeId: 2) // typeId는 앱 내의 다른 HiveType과 겹치지 않아야 합니다.
class Event extends HiveObject {

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
  Map<String, List<String>> dailydata;

  Event({
    required this.id,
    required this.timestamp,
    required this.title,
    required this.content,
    required this.feeling,
    required this.dailydata,
  });
}