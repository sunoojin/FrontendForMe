import 'package:diary_for_me/my_library/diary_tile.dart';
import 'package:flutter/material.dart';
import 'package:diary_for_me/common/ui_kit.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'tag_box.dart';

class MyLibraryPage extends StatefulWidget {
  const MyLibraryPage({super.key});

  @override
  State<MyLibraryPage> createState() => _MyLibraryPageState();
}

class _MyLibraryPageState extends State<MyLibraryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: blurryAppBar(children: [], color: Colors.white),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 페이지 제목
              contents(
                children: [
                  SafeArea(bottom: false, child: SizedBox(),),
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
              // 태그
              SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(width: 20,),
                    tagBox(text: '전체', activated: true),
                    tagBox(text: '즐겨찾기', activated: false),
                    tagBox(text: '#가족', activated: false),
                    tagBox(text: '#여행', activated: false),
                    tagBox(text: '#가족', activated: false),
                    tagBox(text: '#여행', activated: false),
                    tagBox(text: '#가족', activated: false),
                    tagBox(text: '#여행', activated: false),
                    SizedBox(width: 14,),
                  ],
                )
              ),
              SizedBox(height: 8,),
              DiaryTile(),
              DiaryTile(),
              DiaryTile(),
              DiaryTile(),
              DiaryTile(),
              DiaryTile(),
              DiaryTile(),
              SafeArea(child: SizedBox(), top: false,)
            ],
          ),
        ),
      ),
    );
  }
}
