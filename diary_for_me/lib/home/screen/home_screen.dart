import 'package:diary_for_me/setting/screen/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:diary_for_me/common/ui_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diary_for_me/my_library/screen/my_library_screen.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/today_widget.dart';
import 'package:diary_for_me/timeline/screen/timeline_list_screen.dart';
import 'package:diary_for_me/tutorial/screen/profile_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _name;
  String? _birth;
  String? _gender;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? '사용자';
      _birth = prefs.getString('date') ?? '미입력';
      _gender = prefs.getString('gender') ?? '미입력';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: blurryAppBar(
        title: Text('apptitle'),
        color: themePageColor,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black.withAlpha(96)),
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => SettingScreen()),
              );
            },
          ),
          SizedBox(width: 4),
        ],
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
              SafeArea(bottom: false, child: SizedBox()),
              // 타이틀
              Text(
                '${_name ?? '기본'}님을 위한 실록',
                // PageTitle
                style: pageTitle(),
              ),
              SizedBox(height: 16),
              // 오늘의 일기
              TodayWidget(),
              // 나의 서고
              contentsCard(
                children: [
                  contents(
                    children: [
                      Text('나의 서고', style: cardTitle()),
                      SizedBox(height: 8),
                      Text('저장된 일기들을 이곳에서 볼 수 있어요', style: cardDetail()),
                    ],
                  ),
                  // DiaryTile(),
                  // DiaryTile(),
                  contents(children: [borderHorizontal()]),
                  bottomButton(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('모두 보기', style: cardDetail(color: textTertiary)),
                        Icon(
                          Icons.arrow_forward,
                          size: 19,
                          color: textTertiary,
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const MyLibraryScreen(),
                        ),
                      );
                    },
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
                          Text('내 타임라인 ', style: cardTitle()),
                          Text('0개', style: cardTitle(color: mainColor)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '사관이 모은 기록들을 바탕으로 생성된 타임라인이에요. '
                        '저장된 타임라인으로 일기를 작성할 수 있어요.',
                        style: cardDetail(),
                      ),
                      SizedBox(height: 16),
                      borderHorizontal(),
                    ],
                  ),
                  bottomButton(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('타임라인 보기', style: cardDetail(color: textTertiary)),
                        Icon(
                          Icons.arrow_forward,
                          size: 19,
                          color: textTertiary,
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const TimelineListScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              // 하단 안전영역
              SafeArea(top: false, child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }
}
