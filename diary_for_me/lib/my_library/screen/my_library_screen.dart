import 'package:diary_for_me/my_library/widgets/diary_empty.dart';
import 'package:diary_for_me/my_library/widgets/diary_tile.dart';
import 'package:flutter/material.dart';
import 'package:diary_for_me/common/ui_kit.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import '../../diary/service/diary_model.dart';
import '../../diary/service/tag_model.dart';
import '../widgets/tag_box.dart';

class MyLibraryScreen extends StatefulWidget {
  const MyLibraryScreen({super.key});

  @override
  State<MyLibraryScreen> createState() => _MyLibraryScreenState();
}

class _MyLibraryScreenState extends State<MyLibraryScreen> {
  String? _selectedTag;

  final diaryBox = Hive.box<Diary>('diaryBox');
  final tagsBox = Hive.box<Tag>('tagsBox');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: blurryAppBar(color: Colors.white),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeArea(bottom: false, child: SizedBox(),),
              // 페이지 제목
              contents(
                children: [
                  Text(
                    '나의 서고',
                    style: pageTitle(),
                  ),
                  SizedBox(height: 8,),
                  Text(
                    '저장된 일기들을 이곳에서 볼 수 있어요.',
                    style: cardDetail(),
                  ),
                ]
              ),
              SizedBox(height: 8,),
              // 태그 선택창
              SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(width: 20,),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTag = null;
                        });
                      },
                      behavior: HitTestBehavior.opaque,
                      child: tagBox(text: '전체', activated: _selectedTag == null),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTag = '@f';
                        });
                      },
                      behavior: HitTestBehavior.opaque,
                      child: tagBox(text: '즐겨찾기', activated: _selectedTag == '@f'),
                    ),
                    ValueListenableBuilder(
                      valueListenable: tagsBox.listenable(),
                      builder: (context, box, _) {
                        final tags = box.values.toList();

                        if (tags.isEmpty) {
                          return const SizedBox();
                        }

                        return Row(
                          children: [
                            ...tags.map((tag) {
                              if (tag.name == '@f') return SizedBox();
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedTag = tag.name;
                                  });
                                },
                                child: tagBox(
                                  text: '#${tag.name}',
                                  activated: _selectedTag == tag.name,
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
                    SizedBox(width: 14,),
                  ],
                )
              ),
              SizedBox(height: 8,),
              // 일기 목록
              ValueListenableBuilder(
                valueListenable: diaryBox.listenable(),
                builder: (context, Box<Diary> box, _) {
                  // 목록 로딩
                  List<Diary> diaries = box.values.toList();

                  if (diaries.isEmpty) {
                    return DiaryEmpty();
                  }

                  // 태그 필터링
                  if (_selectedTag != null) {
                    diaries = diaries
                        .where((diary) => diary.tag.contains(_selectedTag))
                        .toList();
                  }

                  if (diaries.isEmpty) {
                    return TagEmpty();
                  }

                  // 날짜별 정렬
                  diaries.sort();

                  return ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: diaries.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Row(
                        children: [
                          Expanded(
                            child: DiaryTile(
                              diary: diaries[index],
                            ),
                          ),
                          ContainerButton(
                            height: 40,
                            width: 40,
                            child: Center(
                              child: Icon(
                                Icons.bookmark,
                                size: 26,
                                color: diaries[index].tag.contains('@f') ? themeColor : Colors.grey.shade300,
                              ),
                            ),
                            // 즐겨찾기 로직(임시)
                            onTap: () {
                              diaries[index].updateTag('@f');
                            },
                          ),
                          SizedBox(width: 10,)
                        ],
                      );
                    },
                  );
                },
              ),
              /*
              ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                itemCount: filteredDiary.length,
                itemBuilder: (BuildContext context, int index) {
                  return Row(
                    children: [
                      Expanded(
                        child: DiaryTile(
                          title: filteredDiary[index]['title'],
                          details: filteredDiary[index]['details'],
                          date: filteredDiary[index]['date'],
                          tags: filteredDiary[index]['tags'],
                        ),
                      ),
                      ContainerButton(
                        height: 40,
                        width: 40,
                        child: Center(
                          child: Icon(
                            Icons.bookmark,
                            size: 26,
                            color: filteredDiary[index]['tags'].contains('@f') ? themeColor : Colors.grey.shade300,
                          ),
                        ),
                        // 즐겨찾기 로직(임시)
                        onTap: () {
                          setState(() {// 1. 현재 항목을 가져옵니다.
                            final entry = filteredDiary[index];

                            final List<String> newTags = List<String>.from(entry['tags'] ?? <String>[]);

                            if (newTags.contains('@f')) {
                              newTags.remove('@f');
                            } else {
                              newTags.add('@f');
                            }

                            entry['tags'] = newTags;
                          });
                        },
                      ),
                      SizedBox(width: 10,)
                    ],
                  );
                },
              ),
               */
              SafeArea(top: false, child: SizedBox(),)
            ],
          ),
        ),
      ),
    );
  }
}
