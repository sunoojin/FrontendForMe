import 'package:diary_for_me/my_library/diary_tile.dart';
import 'package:flutter/material.dart';
import 'package:diary_for_me/common/ui_kit.dart';
import 'tag_box.dart';
import 'test_diary.dart';

List<String> tags = [
  '가족',
  '여행',
  '학교',
  '친구',
  '동아리',
  '아르바이트',
  '스포츠',
  '행복'
];

class MyLibraryPage extends StatefulWidget {
  const MyLibraryPage({super.key});

  @override
  State<MyLibraryPage> createState() => _MyLibraryPageState();
}

class _MyLibraryPageState extends State<MyLibraryPage> {
  String _selectedTag = '@a';

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> filteredDiary;

    if (_selectedTag == '@a') {
      filteredDiary = diary;
    }else{
      filteredDiary = diary.where((entry) {
        final tags = entry['tags'] as List<String>? ?? [];
        return tags.contains(_selectedTag);
      }).toList();
    }

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
                          _selectedTag = '@a';
                        });
                      },
                      behavior: HitTestBehavior.opaque,
                      child: tagBox(text: '전체', activated: _selectedTag == '@a'),
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
                    ...tags.map((tagData) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTag = tagData;
                          });
                        },
                        child: tagBox(
                          text: '#$tagData',
                          activated: _selectedTag == tagData,
                        ),
                      );
                    }),
                    SizedBox(width: 14,),
                  ],
                )
              ),
              SizedBox(height: 8,),
              // 일기 목록
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
              SafeArea(top: false, child: SizedBox(),)
            ],
          ),
        ),
      ),
    );
  }
}
