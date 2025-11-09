import 'dart:ffi';
import 'dart:ui';
import 'package:diary_for_me/common/ui_kit.dart';
import 'package:diary_for_me/my_library/tag_box.dart';
import 'package:diary_for_me/my_library/test_diary.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:flutter/cupertino.dart';

List<Map<String, dynamic>> emotions = [
  {
    'img' : '😢',
    'text' : '슬픔',
    'color' : Colors.blueAccent.withAlpha(65)
  },
  {
    'img' : '😢',
    'text' : '화남',
    'color' : Colors.redAccent.withAlpha(65)
  },
  {
    'img' : '😢',
    'text' : '보통',
    'color' : Colors.grey.withAlpha(65)
  },
  {
    'img' : '😢',
    'text' : '기쁨',
    'color' : Colors.green.withAlpha(65)
  },
  {
    'img' : '😢',
    'text' : '즐거움',
    'color' : Colors.orangeAccent.withAlpha(65)
  },
];

class SelectMoodPage extends StatefulWidget {
  const SelectMoodPage({super.key});

  @override
  State<SelectMoodPage> createState() => _SelectMoodPageState();
}

class _SelectMoodPageState extends State<SelectMoodPage> {
  PageController _controller = PageController(initialPage: 2,);
  int _currentIndex = 2;
  
  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    
    super.dispose();
  }

  void _goToPage(int index) {
    _controller.animateToPage(
      index,
      duration: Duration(milliseconds: 600),
      curve: Curves.fastOutSlowIn
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
          size: 28.0
        ),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
        actions: [
          Text(
            '2',
            style: appbarButton(color: Colors.white),
          ),
          Text(
            '/3',
            style: appbarButton(color: Colors.white.withAlpha(128)),
          ),
          SizedBox(width: 20,)
        ],
      ),
      backgroundColor: Colors.black,
      body: AnimatedContainer(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              emotions[_currentIndex]['color']
            ]
          )
        ),
        height: double.infinity,
        width: double.infinity,
        duration: const Duration(milliseconds: 700),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SafeArea(bottom: false, child: SizedBox.shrink()),
            SizedBox(height: 16,),
            Text('오늘 하루는 어땠나요?',
              style: pageTitle(color: Colors.white),
            ),
            SizedBox(height: 8,),
            Text('오늘 하루동안 느꼈던 감정을 선택해주세요.',
              style: cardDetail(color: Colors.white.withAlpha(128)),
            ),
            // 감정 이모티콘
            Expanded(
              child: PageView(
                physics: BouncingScrollPhysics(),
                controller: _controller,
                onPageChanged: (int index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: ['😢', '😡', '😑', '😊', '🤣'].map((e) => Center(
                  child: Text(
                    e,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 225.0
                    ),
                  ),
                )).toList(),
              ),
            ),
            SizedBox(height: 16,),
            // 감정 선택창
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(width: 20,),
                  ...emotions.asMap().entries.map((e) {
                    int index = e.key;
                    var item = e.value;
                    bool isSelected = _currentIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                        });
                        _goToPage(index);
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 4),
                        width: 86,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          color: isSelected ? Colors.white : Colors.transparent
                        ),
                        child: Center(
                          child: Text(
                            item['text'],
                            style: TextStyle(
                              color: isSelected ? textPrimary : Colors.white.withAlpha(128),
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  SizedBox(width: 16,),
                ],
              ),
            ),
            SizedBox(height: 16,),
            // 다음 페이지
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ContainerButton(
                borderRadius: BorderRadius.circular(24),
                height: 68,
                onTap: () {},
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '다음으로',
                        style: mainButton(),
                      ),
                      Icon(
                        Icons.navigate_next,
                        size: 24,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16,),
            SafeArea(top: false, child: SizedBox.shrink())
          ],
        ),
      ),
    );
  }
}
