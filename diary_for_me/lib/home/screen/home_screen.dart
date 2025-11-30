import 'package:diary_for_me/home/widgets/my_library_card.dart';
import 'package:diary_for_me/setting/screen/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:diary_for_me/common/ui_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';

// [1] Isar 관련 패키지 Import
import 'package:isar/isar.dart';
import 'package:diary_for_me/DB/db_manager.dart';
import 'package:diary_for_me/DB/timeline/timeline_model.dart';

import '../service/greeting.dart';
import '../widgets/today_widget.dart';
import 'package:diary_for_me/timeline/screen/timeline_list_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String? _name;
  String? _birth;
  String? _gender;
  String _currentGreeting = '';

  // [2] DB 인스턴스를 저장할 변수
  late Future<Isar> _dbFuture;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _updateGreeting();
    _loadUserInfo();

    // [3] 앱 시작 시 DB 연결 준비 (한 번만 실행)
    _dbFuture = DB().instance;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateGreeting();
    }
  }

  void _updateGreeting() {
    setState(() {
      _currentGreeting = getRandomGreeting();
    });
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
    // Hive 관련 코드 삭제됨

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: blurryAppBar(
        title: Image.asset(
          'lib/common/resource/logo.png',
          width: 130,
          height: 40,
          fit: BoxFit.contain,
        ),
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
          const SizedBox(width: 4),
        ],
      ),
      backgroundColor: themePageColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SafeArea(bottom: false, child: SizedBox()),
              const SizedBox(height: 28),
              // 타이틀
              Text(
                '${_name ?? '사용자'}님',
                style: pageTitle(),
              ),
              Text(
                _currentGreeting,
                style: pageTitle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 28),
              const SizedBox(height: 16),
              // 오늘의 일기
              const TodayWidget(),
              // 나의 서고
              const MyLibraryCard(),

              // [4] 저장된 타임라인 (Isar 적용)
              FutureBuilder<Isar>(
                future: _dbFuture, // initState에서 준비한 DB 사용
                builder: (context, dbSnapshot) {
                  // DB 로딩 중일 때 처리 (필요시 로딩 위젯 표시)
                  if (!dbSnapshot.hasData) {
                    return const SizedBox(height: 100);
                  }

                  final isar = dbSnapshot.data!;

                  // [5] StreamBuilder로 타임라인 개수 변화 감지
                  return StreamBuilder<int>(
                    // 전체 리스트를 구독하되, 개수(length)만 추출하여 스트림으로 받음
                    stream: isar.timeLines.where().watch(fireImmediately: true).map((list) => list.length),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;

                      return contentsCard(
                        children: [
                          contents(
                            children: [
                              Row(
                                children: [
                                  Text('내 타임라인 ', style: cardTitle()),
                                  Text(
                                    '${count}개', // 실시간 개수 반영
                                    style: cardTitle(color: mainColor),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '사관이 모은 기록들을 바탕으로 생성된 타임라인이에요. '
                                    '저장된 타임라인으로 일기를 작성할 수 있어요.',
                                style: cardDetail(),
                              ),
                              const SizedBox(height: 16),
                              borderHorizontal(),
                            ],
                          ),
                          bottomButton(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '타임라인 보기',
                                  style: cardDetail(color: textTertiary),
                                ),
                                const Icon(
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
                      );
                    },
                  );
                },
              ),
              const SafeArea(top: false, child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }
}