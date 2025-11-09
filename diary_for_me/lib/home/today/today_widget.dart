import 'package:diary_for_me/new_diary/select_mood_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_corner/smooth_corner.dart';
import '../../common/ui_kit.dart';
import 'dart:async';

class TodayWidget extends StatefulWidget {
  const TodayWidget({super.key});

  @override
  State<TodayWidget> createState() => _TodayWidgetState();
}

class _TodayWidgetState extends State<TodayWidget> {
  late Timer _timer;
  late double _progress;
  late bool _isReady;

  final int _targetSec = 12 * 3600;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _updateTime();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    final int nowSec = now.hour * 3600 + now.minute * 60 + now.second;

    if (mounted) {
      setState(() {
        // _progress = nowSec / _targetSec;
        _progress = now.second / 30.0;
        _isReady = _progress >= 1;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (_isReady == false) {
      return contentsCard(
        children: [
          contents(
            children: [
              // 제목(오늘)
              Text(
                '오늘',
                style: cardTitle()
              ),
              SizedBox(height: 16,),
              // 이미지 영역
              Container(
                width: double.infinity,
                height: 160,
                color: themeDeepColor,
              ),
              SizedBox(height: 16,),
              // 상태
              Text(
                '사관이 정보를 수집중이에요',
                style: contentTitle()
              ),
              SizedBox(height: 8),
              // 진행 바
              Container(
                clipBehavior: Clip.antiAlias,
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: themeColor
                ),
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: themeDeepColor,
                  color: themeColor,
                ),
              ),
              SizedBox(height: 8),
              // 정보
              Text(
                '정보 수집이 끝나면 오늘의 실록을 만들 수 있어요.'
                //    ' 준비가 완료되면 알림을 보내드려요'
                ,
                style: contentDetail()
              ),
            ]
          ),
        ],
      );
    }
    else {
      return contentsCard(
        children: [
          contents(
            children: [
              // 제목(오늘)
              Text(
                '오늘',
                style: cardTitle()
                ),
              SizedBox(height: 16,),
              // 이미지 영역
              Container(
                width: double.infinity,
                height: 160,
                color: themeDeepColor,
                ),
              SizedBox(height: 16,),
              // 상태
              Text(
                '오늘의 실록을 만들 준비를 마쳤어요.',
                style: contentTitle()
                ),
              SizedBox(height: 8),
              // 정보
              Text(
                '사관이 정보 수집을 끝냈어요. 이제 일기를 생성해 보세요.',
                style: contentDetail(),
              ),
              SizedBox(height: 16,),
              // 일기 생성 버튼
              ContainerButton(
                borderRadius: BorderRadius.circular(20),
                color: themeColor,
                height: 56,
                shadows: [
                  BoxShadow(
                    color: themeColor.withAlpha(128),
                    spreadRadius: -12,
                    blurRadius: 18,
                    offset: Offset(0, 18)
                  )
                ],
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => const SelectMoodPage())
                  );
                },
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '일기 생성하기',
                        style: mainButton(),
                      ),
                      Icon(Icons.navigate_next,
                        size: 24,
                        color: Colors.white,
                      ),
                    ],
                  ),
                )
              )
            ]
          ),
        ]
      );
    }
  }
}


