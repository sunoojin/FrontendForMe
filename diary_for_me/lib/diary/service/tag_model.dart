import 'package:hive/hive.dart';

part 'tag_model.g.dart'; // 1. g.dart 파일 지정

@HiveType(typeId: 1)
class Tag extends HiveObject {

  @HiveField(0)
  String name;

  @HiveField(1)
  int count;

  Tag({required this.name, this.count = 0});
}