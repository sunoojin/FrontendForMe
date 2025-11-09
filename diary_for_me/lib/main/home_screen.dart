import 'package:flutter/material.dart';
import 'package:diary_for_me/common/ui_kit.dart';
import 'package:smooth_corner/smooth_corner.dart';

import 'package:shared_preferences/shared_preferences.dart';
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
    debugPrint('불러온 이름: $_name');
    debugPrint('불러온 생년월일: $_birth');
    debugPrint('불러온 성별: $_gender');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: blurryAppBar(
        children: [
          Text('앱 타이틀'),
          Expanded(child: SizedBox()),
          ContainerButton(
            width: 36,
            height: 36,
            child: Center(
              child: Icon(
                Icons.settings,
                color: Color(0xff111111).withAlpha(120),
                size: 32,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
              _loadUserInfo();
            },
          ),
        ],
        color: themePageColor,
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
              contentsCard(
                children: [
                  contents(
                    children: [
                      Text('오늘', style: cardTitle()),
                      SizedBox(height: 16),
                      // 이미지 영역
                      Container(
                        width: double.infinity,
                        height: 160,
                        color: themeDeepColor,
                      ),
                      SizedBox(height: 16),
                      Text('사관이 정보를 수집중이에요', style: contentTitle()),
                      SizedBox(height: 8),
                      Container(
                        clipBehavior: Clip.antiAlias,
                        height: 10,
                        decoration: ShapeDecoration(
                          shape: SmoothRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            smoothness: 0.6,
                          ),
                        ),
                        child: LinearProgressIndicator(
                          value: 0.4,
                          backgroundColor: themeDeepColor,
                          color: mainColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '정보 수집이 끝나면 오늘의 실록을 만들 수 있어요. 준비가 완료되면 알림을 보내드려요',
                        style: contentDetail(),
                      ),
                    ],
                  ),
                ],
              ),
              // 나의 서고
              contentsCard(
                children: [
                  contents(
                    children: [
                      Text('나의 서고', style: cardTitle()),
                      SizedBox(height: 8),
                      Text('저장된 일기들을 이곳에서 볼 수 있어요', style: cardDetail()),
                      SizedBox(height: 16),
                      borderhorizontal(),
                    ],
                  ),
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
                    onTap: () {},
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
                      borderhorizontal(),
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
                    onTap: () {},
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
