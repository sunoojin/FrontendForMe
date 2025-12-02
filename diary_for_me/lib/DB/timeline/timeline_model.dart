import 'package:isar/isar.dart';
import '../daily_data/daily_data_model.dart';

part 'timeline_model.g.dart';

@embedded
class Event implements Comparable<Event> {
  String id;

  DateTime? timestamp;

  String title;

  String content;

  String feeling;

  DailyData? dailydata;

  Event({
    this.id = '',
    this.timestamp, // DateTime.now()는 const가 아니라서 본문 초기화 필요
    this.title = '',
    this.content = '',
    this.feeling = '',
    this.dailydata,
  });


  Event clone() {
    return Event(
      id: this.id,
      timestamp: this.timestamp,
      title: this.title,
      content: this.content,
      feeling: this.feeling,
      dailydata: this.dailydata?.clone(),
    );
  }

  @override
  int compareTo(Event other) {
    final thisTime = timestamp ?? DateTime.now();
    final otherTime = other.timestamp ?? DateTime.now();
    return thisTime.compareTo(otherTime);
  }

  void addPicture(String picture) {
    dailydata ??= DailyData();
    dailydata!.gallery.add(picture);
  }

  void removePicture(String picture) {
    if (dailydata == null) return;

    if (dailydata!.gallery.contains(picture)) {
      dailydata!.gallery.remove(picture);
    }
  }
}

// 타임라인의 처리 상태를 나타내는 Enum
enum TimelineStatus {
  pending,    // 1. 수집 중 or 일기 생성 전 (작성 대기)
  processing, // 2. AI가 일기 생성 중 (로딩 UI 보여줄 때 유용)
  completed,  // 3. 일기 생성 완료
}

@embedded
class SelfSurvey {
  String? mood;
  String? draft;

  SelfSurvey({
    this.mood,
    this.draft
  });
}

@collection
class TimeLine {
  Id id = Isar.autoIncrement;

  // [핵심] 상태 필드 추가 (기본값: 대기 중)
  @Enumerated(EnumType.ordinal) // 정수형으로 저장되어 빠름
  TimelineStatus status = TimelineStatus.pending;

  String title;

  @Index()
  DateTime date;

  List<Event> events;

  SelfSurvey? selfsurvey;

  TimeLine({
    this.title = '',
    required this.date,
    this.events = const [],
    this.selfsurvey,
  });
}