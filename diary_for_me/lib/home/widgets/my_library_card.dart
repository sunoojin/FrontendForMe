import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import '../../common/ui_kit.dart';
import '../../diary/service/diary_model.dart';
import '../../my_library/screen/my_library_screen.dart';
import '../../my_library/widgets/diary_tile.dart';

class MyLibraryCard extends StatelessWidget {
  const MyLibraryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final diaryBox = Hive.box<Diary>('diaryBox');

    return contentsCard(
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
        ValueListenableBuilder(
          valueListenable: diaryBox.listenable(),
          builder: (context, Box<Diary> box, _) {
            final diaries = box.values.toList();

            if(diaries.isEmpty) {
              return SizedBox();
            }

            diaries.sort((a, b) => a.compareTo(b));
            return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: NeverScrollableScrollPhysics(),
              itemCount: min(diaries.length, 2),
              itemBuilder: (BuildContext context, int index) {
                return DiaryTile(
                  diary: diaries[index],
                );
              },
            );
          },
        ),
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
    );
  }
}
