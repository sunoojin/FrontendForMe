import 'package:diary_for_me/home/widgets/today_widget.dart';
import 'package:flutter/material.dart';
import 'package:diary_for_me/common/ui_kit.dart';
import 'package:diary_for_me/timeline/widget/time_line_card.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import '../service/timeline_model.dart';

class TimelineListScreen extends StatelessWidget {
  const TimelineListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timelineBox = Hive.box<TimeLine>('timelineBox');

    return Scaffold(
      appBar: blurryAppBar(color: Colors.white),
      backgroundColor: themePageColor,
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(bottom: false, child: SizedBox()),
            // 제목
            Text(
              "나의 타임라인",
              style: pageTitle(),
            ),
            const SizedBox(height: 8),
            Text(
              "사관이 기록한 타임라인이에요\n모인 타임라인으로 일기를 생성할 수 있어요.",
              style: cardDetail()
            ),

            const SizedBox(height: 16),

            // 오늘
            TodayWidget(),

            // 이전
            ValueListenableBuilder(
              valueListenable: timelineBox.listenable(),
              builder: (context, Box<TimeLine> box, _) {
                final timelines = box.values.toList();

                if(timelines.isEmpty) {
                  return SizedBox();
                }

                return ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: timelines.length,
                  itemBuilder: (BuildContext context, int index) {
                    return TimeLineCard(timeline: timelines[index]);
                  },
                );
              },
            )

            /*
            // 어제
            timelineCard(
              dateText: "12/8 (화)",
              activityCount: 13,
              infoCount: 135,
              date: DateTime.now().subtract(Duration(days: 1)), // 어제
            ),

            // 그저께
            timelineCard(
              dateText: "12/7 (월)",
              activityCount: 123,
              infoCount: 6,
              date: DateTime.now().subtract(Duration(days: 2)), // 그제
            ),

             */
          ],
        ),
      ),
    );
  }
}
