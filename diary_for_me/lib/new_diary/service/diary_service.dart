import 'package:diary_for_me/db_models/diary/diary_content_model.dart';
import 'package:hive/hive.dart';
import 'package:diary_for_me/db_models/diary/diary_model.dart';
import 'package:diary_for_me/db_models/timeline/timeline_model.dart';

class DiaryService {
  final Box<Diary> diaryBox;
  final Box<TimeLine> timelineBox;

  DiaryService(this.diaryBox, this.timelineBox);

  Future<String?> generateNewDiary({
    required String timelineKey,
    required String title,
    required String text,
  }) async {
    final TimeLine? selectedTimeline = timelineBox.get(timelineKey);

    if (selectedTimeline == null) {
      // 키 오류
      return null;
    }

    try {
      final newDiary = Diary(
        id: selectedTimeline.date.toIso8601String(),
        timeline: selectedTimeline,
        title: title,
        content: DiaryContent(text: text, image: [], music: []),
        tag: [],
      );

      await diaryBox.put(newDiary.id, newDiary);

      await selectedTimeline.delete();

      return newDiary.id;
    } catch (e) {
      return null;
    }
  }
}
