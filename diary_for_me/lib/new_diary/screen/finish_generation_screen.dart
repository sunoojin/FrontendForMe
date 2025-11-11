import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:diary_for_me/common/ui_kit.dart';
import 'package:smooth_corner/smooth_corner.dart';

import '../../diary/screen/diary_screen.dart';

class FinishGenerationScreen extends StatefulWidget {
  const FinishGenerationScreen({super.key});

  @override
  State<FinishGenerationScreen> createState() => _FinishGenerationScreenState();
}

class _FinishGenerationScreenState extends State<FinishGenerationScreen> {
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
                    '롤러코스터보다 빠른 심장',
                  ),
                  SizedBox(height: 8,),
                  Text(
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: contentDetail(fontSize: 12),
                    '다른 과정론적이 2025년 의혹은 접속을 주는 행동을 규격의 잠재력의 팽창하다. 지식이 관련할 계파다 간 흑색선전의, 악용되다. 다양하여 부녀회원의 일은 하고 일을 신탁의 벗는 데 자매로, 논의되다. 나도 공사를...'
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
                        CupertinoPageRoute(builder: (context) => DiaryScreen(title: 'title', details: 'details', tags: [], date: DateTime(2025),))
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
