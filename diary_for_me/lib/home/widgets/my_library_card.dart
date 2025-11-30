import 'dart:math';

import 'package:diary_for_me/DB/db_manager.dart'; // [필수] DB 매니저
import 'package:diary_for_me/DB/diary/diary_model.dart'; // [필수] Diary 모델 (isar.diarys 접근용)
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart'; // [필수] Isar 패키지

import '../../common/ui_kit.dart';
import '../../my_library/screen/my_library_screen.dart';
import '../../my_library/widgets/diary_tile.dart';

class MyLibraryCard extends StatelessWidget {
  const MyLibraryCard({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. DB 인스턴스 확보 (FutureBuilder)
    return FutureBuilder(
      future: DB().instance,
      builder: (context, dbSnapshot) {
        // DB 로딩 중일 때 (UI 깜빡임 방지용 빈 카드 or 로딩)
        if (!dbSnapshot.hasData) {
          return contentsCard(children: [
            const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
          ]);
        }

        final isar = dbSnapshot.data as Isar;

        // 2. 다이어리 데이터 감시 (StreamBuilder)
        return StreamBuilder<List<Diary>>(
          // 전체 일기를 가져와서 감시합니다.
          // (일기 데이터가 수만 건이 넘지 않는 개인 앱 수준에서는 전체 로드 후 메모리 정렬이 정확합니다)
          stream: isar.diarys.where().watch(fireImmediately: true),
          builder: (context, snapshot) {
            final allDiaries = snapshot.data ?? [];

            return contentsCard(
              children: [
                // 타이틀 영역
                contents(
                  children: [
                    Text('나의 서고', style: cardTitle()),
                    const SizedBox(height: 8),
                    Text('저장된 일기들을 이곳에서 볼 수 있어요', style: cardDetail()),
                  ],
                ),

                // 리스트 영역
                if (allDiaries.isEmpty)
                  const SizedBox(
                    height: 50,
                    child: Center(child: Text("아직 작성된 일기가 없어요")),
                  )
                else
                  Builder(builder: (context) {
                    // 3. 정렬 로직 (최신 날짜 순)
                    // IsarLink(.timeline)를 통해 날짜를 비교합니다.
                    // .value가 null인 경우(거의 없겠지만)를 대비해 DateTime(0) 처리
                    allDiaries.sort((a, b) {
                      final dateA = a.timeline.value?.date ?? DateTime(0);
                      final dateB = b.timeline.value?.date ?? DateTime(0);
                      return dateB.compareTo(dateA); // 내림차순 (최신순)
                    });

                    // 4. 최대 2개만 자르기
                    final recentDiaries = allDiaries.take(2).toList();

                    return ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentDiaries.length,
                      itemBuilder: (BuildContext context, int index) {
                        return DiaryTile(diary: recentDiaries[index]);
                      },
                    );
                  }),

                // 구분선
                contents(children: [borderHorizontal()]),

                // 하단 버튼
                bottomButton(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('모두 보기', style: cardDetail(color: textTertiary)),
                      const Icon(Icons.arrow_forward, size: 19, color: textTertiary),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => const MyLibraryScreen()),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}