import 'package:hive/hive.dart';

part 'part/diary_content_model.g.dart';

@HiveType(typeId: 4)
class DiaryContent extends HiveObject {

  @HiveField(0) // 각 필드에 고유 인덱스 부여
  String text;

  @HiveField(1)
  List<String> image;

  @HiveField(2)
  List<String> music;

  DiaryContent({
    required this.text,
    required this.image,
    required this.music
  });
}