import 'dart:developer';

import 'package:diary_for_me/new_diary/screen/select_mood_screen.dart';
import 'package:diary_for_me/timeline/service/event_model.dart';
import 'package:diary_for_me/timeline/widget/add_event_button.dart';
import 'package:diary_for_me/timeline/widget/time_line_card.dart';
import 'package:flutter/material.dart';
import 'package:diary_for_me/common/ui_kit.dart';
import 'package:flutter/cupertino.dart';

import 'package:diary_for_me/timeline/widget/event_card.dart';
import 'package:diary_for_me/timeline/screen/edit_event_screen.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:smooth_corner/smooth_corner.dart';

import '../service/timeline_model.dart';

class EventListScreen extends StatelessWidget {
  final String timelineKey;
  const EventListScreen({super.key, required this.timelineKey});

  @override
  Widget build(BuildContext context) {
    final timelineBox = Hive.box<TimeLine>('timelineBox');
    // 임시 데이터
    /*
    final events = [
      {"time": "12:00", "title": "필동함박에서 점심식사", "description": "후배와 점심식사"},
      {
        "time": "16:00",
        "title": "카페에서 커피 마시면서 공부하기",
        "description": "블루포트에서 혼공",
      },
      {"time": "18:00", "title": "동아리 연습에 참여하기", "description": "축제 무대 연습"},
    ];

     */

    return Scaffold(
      appBar: blurryAppBar(color: Colors.white,
        actions: [
          Text('1', style: appbarButton(color: textPrimary)),
          Text('/3', style: appbarButton(color: textTertiary)),
          SizedBox(width: 20),
        ]
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Text(
              "하루 돌아보기",
              style: pageTitle(),
            ),
            const SizedBox(height: 8),
            Text(
              "수집된 정보들을 바탕으로 생성된 타임라인이에요.\n"
              "실제 있었던 일과 다르다면 수정해 주세요.",
              style: cardDetail()
            ),
            const SizedBox(height: 16),

            // 이벤트 목록
            /*
            Expanded(
              child: SmoothClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: events.length + 1,
                  itemBuilder: (context, index) {
                    if (index == events.length) return AddEventButton();
                    final e = events[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: EventCard(
                        time: e["time"]!,
                        title: e["title"]!,
                        description: e["description"]!,
                        onEdit: () {
                          ActivityEditSheet.show(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${e["title"]} 수정 클릭")),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
             */
            Expanded(
              child: SmoothClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: ValueListenableBuilder(
                  valueListenable: timelineBox.listenable(),
                  builder: (context, Box<TimeLine> box, _) {
                    final TimeLine? timeline = box.get(timelineKey);

                    if(timeline == null) return Text('타임라인 에러');

                    final events = timeline.events;

                    return ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: events.length + 1,
                      itemBuilder: (context, index) {
                        if (index == events.length) return AddEventButton();
                        final e = events[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: EventCard(
                            event: e,
                            onEdit: () {
                              ActivityEditSheet.show(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("${e.title} 수정 클릭")),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 다음 버튼
            ContainerButton(
              borderRadius: BorderRadius.circular(24),
              height: 68,
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => SelectMoodScreen(),
                  ),
                );
              },
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('다음으로', style: mainButton(color: textPrimary)),
                    Icon(Icons.navigate_next, size: 24, color: textPrimary),
                  ],
                ),
              ),
            ),

            SafeArea(top: false,child: SizedBox(),)
          ],
        ),
      ),
    );
  }
}
