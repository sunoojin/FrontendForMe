import 'package:hive/hive.dart';

import 'tag_model.dart';

// 1. 생성될 g.dart 파일을 part로 지정
part 'diary_model.g.dart';
// 중요!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// part 파일은 깃허브에 업로드 안됨 (git.ignore에 들어가있음)
// 대신에 아래 명령어 터미널에서 실행하면 part 파일이 자동으로 생성될거임.
// flutter pub run build_runner build


@HiveType(typeId: 0) // 2. 고유한 타입 ID 지정
class Diary extends HiveObject { // 3. HiveObject 상속 (권장)

  @HiveField(0) // 4. 각 필드에 고유 인덱스 부여
  String id;

  @HiveField(1)
  List<dynamic> timeline;

  @HiveField(2)
  String title;

  @HiveField(3)
  Map<String, dynamic> content;

  @HiveField(4)
  List<String> tag;

  // 생성자
  Diary({
    required this.id,
    required this.timeline,
    required this.title,
    required this.content,
    required this.tag,
  });

  Box<Tag> _getTagsBox() {
    return Hive.box<Tag>('tagsBox');
  }

  // 태그 수정
  void updateTag(String item) {
    final tagsBox = _getTagsBox();

    Tag? tagObject = tagsBox.get(item);

    if(tag.contains(item)) {
      tag.remove(item);

      if (tagObject != null) {
        tagObject.count -= 1;

        if (tagObject.count <= 0) {
          tagObject.delete(); // (또는 tagsBox.delete(item))
        } else {
          tagObject.save();
        }
      }
    } else {
      tag.add(item);

      if (tagObject == null) {
        tagsBox.put(item, Tag(name: item, count: 1));
      } else {
        tagObject.count += 1;
        tagObject.save();
      }
    }

    save();
  }

  // 비교 함수
  @override
  int compareTo(Diary other) {
    return other.id.compareTo(this.id);
  }
}