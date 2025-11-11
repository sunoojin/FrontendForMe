import 'dart:ui';

import 'package:diary_for_me/common/ui_kit.dart';
import 'package:diary_for_me/home/screen/home_screen.dart';
import 'package:diary_for_me/my_library/widgets/tag_box.dart';
import 'package:diary_for_me/my_library/test_diary.dart';
import 'package:diary_for_me/new_diary/screen/finish_generation_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smooth_corner/smooth_corner.dart';

class WriteDraftScreen extends StatefulWidget {
  const WriteDraftScreen({super.key});

  @override
  State<WriteDraftScreen> createState() => _WriteDraftScreenState();
}

class _WriteDraftScreenState extends State<WriteDraftScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();

    super.dispose();
  }

  void _generateDiary() {
    Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute(builder: (context) => HomePage()),
      (Route<dynamic> route) => false,
    );
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => FinishGenerationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: textPrimary, size: 28.0),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
        actions: [
          Text('3', style: appbarButton(color: textPrimary)),
          Text('/3', style: appbarButton(color: textTertiary)),
          SizedBox(width: 20),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('일기 초안을 작성해 볼까요?', style: pageTitle()),
            SizedBox(height: 8),
            Text('오늘의 하루를 적어보세요', style: cardDetail()),
            SizedBox(height: 16),
            // 입력 필드
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: ShapeDecoration(
                    shape: SmoothRectangleBorder(
                      side: BorderSide(color: themeDeepColor, width: 1.0),
                      borderRadius: BorderRadius.circular(32),
                      smoothness: 0.6,
                    ),
                    color: themePageColor,
                  ),
                  child: TextField(
                    controller: _controller,
                    onChanged: (text) {
                      setState(() {});
                    },

                    cursorColor: themeColor,
                    minLines: 3,
                    maxLines: null,
                    style: diaryDetail(fontWeight: FontWeight.w400),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(20),
                      hintText: '내용을 입력해주세요.',
                      hintStyle: diaryDetail(color: textTertiary),
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child:
                  _controller.text.isEmpty
                      ? Text(
                        textAlign: TextAlign.center,
                        '일기 초안이 없어도 AI가 일기를 생성할 수 있지만,\n결과가 정확하지 않을 수 있어요.',
                        style: contentDetail(),
                      )
                      : SizedBox.shrink(),
            ),
            SizedBox(height: 16),
            // 버튼
            _controller.text.isEmpty
                ? ContainerButton(
                  key: ValueKey('empty'),
                  borderRadius: BorderRadius.circular(24),
                  color: themeColor.withAlpha(24),
                  height: 68,
                  onTap: _generateDiary,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '건너뛰고 일기 생성하기',
                          style: mainButton(color: themeColor),
                        ),
                        Icon(Icons.navigate_next, size: 24, color: themeColor),
                      ],
                    ),
                  ),
                )
                : ContainerButton(
                  key: ValueKey('fill'),
                  borderRadius: BorderRadius.circular(24),
                  color: themeColor.withAlpha(255),
                  height: 68,
                  shadows: [
                    BoxShadow(
                      color: themeColor.withAlpha(128),
                      spreadRadius: -20,
                      blurRadius: 30,
                      offset: Offset(0, 30),
                    ),
                  ],
                  onTap: _generateDiary,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('일기 생성하기', style: mainButton()),
                        Icon(
                          Icons.navigate_next,
                          size: 24,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
            // 안전영역
            SafeArea(child: SizedBox()),
          ],
        ),
      ),
    );
  }
}
