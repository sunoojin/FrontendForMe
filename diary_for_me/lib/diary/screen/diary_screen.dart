import 'dart:ui';


import 'package:diary_for_me/common/ui_kit.dart';
import 'package:diary_for_me/my_library/widgets/tag_box.dart';
import 'package:diary_for_me/my_library/test_diary.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smooth_corner/smooth_corner.dart';

class DiaryScreen extends StatefulWidget {
  final String title;
  final String details;
  final List<String> tags;
  final DateTime date;

  const DiaryScreen({
    super.key,
    required this.title,
    required this.details,
    required this.tags,
    required this.date
  });

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  bool _isplaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: blurryAppBar(
        color: Colors.white,
        title: Text(DateFormat('yyyy.MM.dd(E)').format(widget.date), style: appbarTitle(),),
        centerTitle: true,
        actions: [
          ContainerButton(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text('편집', style: appbarButton()),
              ),
            ),
            onTap: () {},
          ),
          SizedBox(width: 4,)
        ]
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeArea(bottom: false, child: SizedBox(),),
              // 이미지
              contents(
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: ShapeDecoration(
                      shape: SmoothRectangleBorder(
                        smoothness: 0.6,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      color: Colors.green,
                    ),
                    alignment: Alignment.bottomRight,
                    padding: EdgeInsets.all(18),
                    child: SmoothClipRRect(
                      borderRadius: BorderRadius.circular(23),
                      smoothness: 0.6,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isplaying = !_isplaying;
                            });
                          },
                          child: Container(
                            color: Colors.black.withAlpha(32),
                            padding: EdgeInsets.all(8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: Icon(Icons.music_note,
                                    color: Colors.white, size: 23,
                                  )
                                ),
                                SizedBox(width: 8),
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.black.withAlpha(64)
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    _isplaying ? Icons.pause : Icons.play_arrow,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]
              ),

              // 내용
              contents(
                children: [
                  Text(
                    widget.title,
                    style: pageTitle(),
                  ),
                  SizedBox(height: 16,),
                  Text(
                    widget.details,
                    style: diaryDetail(),
                  )
                ]
              ),
              // SizedBox(height: 8,),
              // 태그
              Row(
                children: [
                  SizedBox(width: 20),
                  Text('태그 :', style: contentSubTitle(),),
                  SizedBox(width: 8,),
                  // 태그 목록 및 추가
                  Expanded(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ...widget.tags.map((tagData) {
                            if (tagData == '@f') return SizedBox();
                            return tagBox(
                                text: '#$tagData',
                                activated: false
                            );
                          }),
                          // 태그 추가 버튼
                          GestureDetector(
                            child: tagBox(text: '+ 새 태그'),
                          ),
                          SizedBox(width: 14,)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8,),
              contents(
                children:[
                  SizedBox(height: 32,),
                  borderHorizontal(),
                  SizedBox(height: 32,)
                ]
              ),
              // 공유하기
              contents(
                children: [
                  Center(
                    child: Text('공유하기', style: diaryDetail(
                      color: textTertiary,
                      fontWeight: FontWeight.w700
                    ),),
                  ),
                  SizedBox(height: 8,),
                  Container(
                    width: double.infinity,
                    height: 100,
                    decoration: ShapeDecoration(
                      shape: SmoothRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                        smoothness: 0.6
                      ),
                      color: themePageColor
                    ),
                  )
                ]
              ),
              SafeArea(top: false, child: SizedBox(),)
            ],
          ),
        ),
      ),
    );
  }
}
