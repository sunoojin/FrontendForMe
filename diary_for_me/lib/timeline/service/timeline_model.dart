import 'package:hive/hive.dart';
import 'event_model.dart';

part 'timeline_model.g.dart';

@HiveType(typeId: 3) // Event 클래스와 다른 고유한 typeId 사용
class TimeLine extends HiveObject {

  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  List<Event> events; // Hive 클래스가 다른 Hive 클래스를 참조할 수 있습니다.

  @HiveField(4)
  Map<String, String> selfsurvey;

  TimeLine({
    required this.id,
    required this.title,
    required this.date,
    required this.events,
    required this.selfsurvey,
  });
}