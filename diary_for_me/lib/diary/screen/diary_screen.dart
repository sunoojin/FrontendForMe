import 'dart:ui';

import 'package:diary_for_me/DB/diary/diary_model.dart';
import 'package:diary_for_me/common/ui_kit.dart';
import 'package:diary_for_me/DB/db_manager.dart'; // DB 매니저
import 'package:diary_for_me/my_library/widgets/tag_box.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart'; // Isar 패키지
import 'package:smooth_corner/smooth_corner.dart';

class DiaryScreen extends StatefulWidget {
  final int diaryId; // [변경] String -> int

  const DiaryScreen({super.key, required this.diaryId});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  // 1. DB 인스턴스 Future를 저장할 변수 (리빌드 방지용)
  late Future<Isar> _dbFuture;

  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    // 2. initState에서 한 번만 Future를 할당합니다.
    // 이렇게 해야 음악 버튼을 눌러도 DB 연결을 다시 시도하지 않습니다.
    _dbFuture = DB().instance;
  }

  // [참고] 태그 추가 로직 예시
  // Future<void> _addTag(Isar isar, Diary diary) async {
  //   /*
  //   await isar.writeTxn(() async {
  //     // 리스트는 수정 가능한 새 리스트로 복사해서 넣어야 안전함
  //     diary.tag = [...?diary.tag, '새 태그'];
  //     await isar.diaries.put(diary);
  //   });
  //   */
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Isar>(
      future: _dbFuture, // 3. 저장해둔 변수 사용
      builder: (context, dbSnapshot) {
        if (!dbSnapshot.hasData) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isar = dbSnapshot.data!;

        // 4. StreamBuilder: 데이터 변경 실시간 감지
        return StreamBuilder<Diary?>(
          stream: isar.diarys.watchObject(
            widget.diaryId,
            fireImmediately: true,
          ),
          builder: (context, snapshot) {
            // 데이터가 없거나 로딩 중일 때
            if (!snapshot.hasData || snapshot.data == null) {
              return const Scaffold(
                backgroundColor: Colors.white,
                body: Center(child: Text("삭제된 일기이거나 불러올 수 없습니다.")),
              );
            }

            final diary = snapshot.data!;

            // 5. 타임라인 날짜 가져오기 (IsarLink)
            // .value가 null이면 현재 시간으로 대체 (안전 장치)
            final date = diary.timeline.value?.date ?? DateTime.now();

            return Scaffold(
              extendBodyBehindAppBar: true,
              appBar: blurryAppBar(
                color: Colors.white,
                title: Text(
                  // 날짜 포맷
                  DateFormat('yyyy.MM.dd(E)').format(date),
                  style: appbarTitle(),
                ),
                centerTitle: true,
                actions: [
                  ContainerButton(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(child: Text('편집', style: appbarButton())),
                    ),
                    onTap: () {
                      // 편집 화면으로 이동 (diaryId 전달)
                    },
                  ),
                  const SizedBox(width: 4),
                ],
              ),
              backgroundColor: Colors.white,
              body: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SafeArea(bottom: false, child: SizedBox()),

                      // === 이미지 섹션 ===
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
                              color: Colors.green, // 나중에 diary 이미지로 교체 필요
                            ),
                            alignment: Alignment.bottomRight,
                            padding: const EdgeInsets.all(18),
                            child: SmoothClipRRect(
                              borderRadius: BorderRadius.circular(23),
                              smoothness: 0.6,
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 14,
                                  sigmaY: 14,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isPlaying = !_isPlaying;
                                    });
                                  },
                                  child: Container(
                                    color: Colors.black.withAlpha(32),
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: Icon(
                                            Icons.music_note,
                                            color: Colors.white,
                                            size: 23,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            color: Colors.black.withAlpha(64),
                                          ),
                                          alignment: Alignment.center,
                                          child: Icon(
                                            _isPlaying
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            size: 24,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // === 제목 및 내용 섹션 ===
                      contents(
                        children: [
                          Text(diary.title, style: pageTitle()),
                          const SizedBox(height: 16),
                          Text(
                            diary.content?.text ?? '', // Null 안전 처리
                            style: diaryDetail(),
                          ),
                        ],
                      ),

                      // === 태그 섹션 ===
                      Row(
                        children: [
                          const SizedBox(width: 20),
                          Text('태그 :', style: contentSubTitle()),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  // Null 안전 처리 및 리스트 맵핑
                                  ...diary.tag.map((tagData) {
                                    return tagBox(
                                      text: '#$tagData',
                                      activated: false,
                                    );
                                  }),

                                  // 태그 추가 버튼
                                  GestureDetector(
                                    onTap: () {
                                      // _addTag(isar, diary);
                                    },
                                    child: tagBox(text: '+ 새 태그'),
                                  ),
                                  const SizedBox(width: 14),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // === 하단 여백 및 공유 ===
                      const SizedBox(height: 8),
                      contents(
                        children: [
                          const SizedBox(height: 32),
                          borderHorizontal(),
                          const SizedBox(height: 32),
                        ],
                      ),

                      contents(
                        children: [
                          Center(
                            child: Text(
                              '공유하기',
                              style: diaryDetail(
                                color: textTertiary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            height: 100,
                            decoration: ShapeDecoration(
                              shape: SmoothRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                                smoothness: 0.6,
                              ),
                              color: themePageColor,
                            ),
                          ),
                        ],
                      ),
                      const SafeArea(top: false, child: SizedBox()),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
