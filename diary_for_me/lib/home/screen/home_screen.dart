import 'package:flutter/material.dart';
import 'package:diary_for_me/common/ui_kit.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:diary_for_me/my_library/screen/my_library_screen.dart';
import 'package:diary_for_me/my_library/widgets/diary_tile.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/today_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar:blurryAppBar(
        title: Text('apptitle'),
        color: themePageColor,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black.withAlpha(96), ),
            onPressed: () {},
          ),
          SizedBox(width: 4,),
        ]
      ),
      backgroundColor: themePageColor,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 안전영역 설정
              SafeArea(
                bottom: false,
                child: SizedBox()
              ),
              // 타이틀
              Text(
                '아코님을 위한 실록',
                // PageTitle
                style: pageTitle()
              ),
              SizedBox(height: 16,),
              // 오늘의 일기
              TodayWidget(),
              // 나의 서고
              contentsCard(
                children: [
                  contents(
                    children: [
                      Text(
                        '나의 서고',
                        style: cardTitle()
                      ),
                      SizedBox(height: 8,),
                      Text(
                        '저장된 일기들을 이곳에서 볼 수 있어요',
                        style: cardDetail()
                      ),
                    ]
                  ),
                  // DiaryTile(),
                  // DiaryTile(),
                  contents(
                    children: [
                      borderHorizontal()
                    ]
                  ),
                  bottomButton(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '모두 보기',
                          style: cardDetail(color: textTertiary),
                        ),
                        Icon(Icons.arrow_forward, size: 19, color: textTertiary,)
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) => const MyLibraryScreen())
                      );
                    }
                  ),
                ],
              ),
              // 저장된 타임라인
              contentsCard(
                children: [
                  contents(
                    children: [
                      Row(
                        children: [
                          Text(
                            '내 타임라인 ',
                            style: cardTitle()
                          ),
                          Text(
                            '0개',
                            style: cardTitle(color: themeColor)
                          ),
                        ],
                      ),
                      SizedBox(height: 8,),
                      Text(
                        '사관이 모은 기록들을 바탕으로 생성된 타임라인이에요. '
                            '저장된 타임라인으로 일기를 작성할 수 있어요.',
                        style: cardDetail()
                      ),
                      SizedBox(height: 16,),
                      borderHorizontal()
                    ]
                  ),
                  bottomButton(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '타임라인 보기',
                          style: cardDetail(color: textTertiary),
                        ),
                        Icon(Icons.arrow_forward, size: 19, color: textTertiary,)
                      ],
                    ),
                    onTap: () {}
                  ),
                ],
              ),
              // 하단 안전영역
              SafeArea(
                top: false,
                child: SizedBox(height: 80,)
              )
            ],
          )
        ),
      ),
    );
  }
}
