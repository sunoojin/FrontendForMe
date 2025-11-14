import 'package:diary_for_me/diary/service/diary_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:diary_for_me/common/ui_kit.dart';
import 'package:hive/hive.dart';
import 'package:smooth_corner/smooth_corner.dart';

import '../../diary/screen/diary_screen.dart';

class FinishGenerationScreen extends StatefulWidget {
  final String diaryKey;

  const FinishGenerationScreen({super.key, required this.diaryKey});

  @override
  State<FinishGenerationScreen> createState() => _FinishGenerationScreenState();
}

class _FinishGenerationScreenState extends State<FinishGenerationScreen> {
  late final Diary diary;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    diary = Hive.box<Diary>('diaryBox').get(widget.diaryKey)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.checkmark_alt_circle_fill, color: themeColor, size: 76,),
            SizedBox(height: 16,),
            Text('일기 생성을 완료했어요', style: pageTitle(fontWeight: FontWeight.w500),),
            Expanded(child: SizedBox()),
            Container(
              padding: EdgeInsets.all(20),
              decoration: ShapeDecoration(
                shape: SmoothRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                  smoothness: 0.6
                ),
                color: themePageColor
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 160,
                    decoration: ShapeDecoration(
                      shape: SmoothRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        smoothness: 0.6
                      ),
                      color: themeDeepColor
                    ),
                  ),
                  SizedBox(height: 16,),
                  Text(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: contentTitle(),
                    diary.title,
                  ),
                  SizedBox(height: 8,),
                  Text(
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: contentDetail(fontSize: 12),
                    diary.content['text']
                  )
                ],
              ),
            ),
            SizedBox(height: 16,),
            Row(
              children: [
                Expanded(
                  child: ContainerButton(
                    side: BorderSide(
                      color: themeDeepColor,
                      width: 1.0
                    ),
                    height: 68,
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '홈으로',
                            style: mainButton(color: textTertiary),
                          ),
                          Icon(
                            Icons.navigate_before,
                            size: 24,
                            color: textTertiary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12,),
                Expanded(
                  child: ContainerButton(
                    color: themeColor.withAlpha(24),
                    height: 68,
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        CupertinoPageRoute(builder: (context) => DiaryScreen(diaryKey: widget.diaryKey,))
                      );
                    },
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '바로 읽기',
                            style: mainButton(color: themeColor),
                          ),
                          Icon(
                            Icons.navigate_next,
                            size: 24,
                            color: themeColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SafeArea(top: false, child: SizedBox(),)
          ],
        ),
      ),
    );
  }
}
