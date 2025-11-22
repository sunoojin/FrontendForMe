import 'package:diary_for_me/timeline/service/timeline_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:diary_for_me/common/ui_kit.dart';

import 'package:diary_for_me/timeline/widget/info_box.dart';
import 'package:diary_for_me/timeline/widget/generate_button.dart';
import 'package:intl/intl.dart';
import 'package:smooth_corner/smooth_corner.dart';

import '../screen/event_list_screen.dart';

class TimeLineCard extends StatelessWidget {
  final TimeLine timeline;

  const TimeLineCard({
    super.key,
    required this.timeline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        shape: SmoothRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          smoothness: 0.6,
          side: BorderSide(
            color: themeDeepColor,
            width: 1.0
          )
        ),
      ),
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('yyyy 년 MM/dd (E)').format(timeline.date),
                style: cardTitle(),
              ),
              SizedBox(height: 16,),
              Row(
                children: [
                  Text(
                    '수집된 정보 ',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: textPrimary,
                      fontWeight: FontWeight.w400,
                      height: 1.2
                    ),
                  ),
                  Text(
                    '${timeline.date.second}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: textPrimary,
                      fontWeight: FontWeight.w700,
                      height: 1.2
                    ),
                  ),
                  Text(
                    '개',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: textTertiary,
                      fontWeight: FontWeight.w700,
                      height: 1.2
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '생성된 활동 ',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: textPrimary,
                      fontWeight: FontWeight.w400,
                      height: 1.2
                    ),
                  ),
                  Text(
                    '${timeline.events.length}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: textPrimary,
                      fontWeight: FontWeight.w700,
                      height: 1.2
                    ),
                  ),
                  Text(
                    '개',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: textTertiary,
                      fontWeight: FontWeight.w700,
                      height: 1.2
                    ),
                  ),
                ],
              ),
            ],
          ),
          IntrinsicWidth(
            child: ContainerButton(
              color: themeColor.withAlpha(24),
              padding: EdgeInsets.all(10),
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => EventListScreen(timelineKey: timeline.key,)),
                );
              },
              child: Text(
                '일기 생성하기',
                style: TextStyle(
                  fontSize: 16.0,
                  color: themeColor,
                  fontWeight: FontWeight.w500,
                  height: 1.2
                ),
              ),
            ),
          )
        ],
      ),
    );
    /*
    return contentsCard(
      children: [
        contents(
          children: [
            Text(
              DateFormat('yyyy 년 MM/dd (E)').format(timeline.date),
              style: cardTitle(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InfoBox(title: "생성된 활동", value: '${timeline.events.length}'),
                InfoBox(title: "수집된 정보", value: '${timeline.date.second}'),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "실록이 도착했어요!",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              "사관이 정보 수집을 끝냈어요. 이제 일기를 작성해보세요.",
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            // PurpleButton(text: "일기 생성하기", date: date),
            GenerateButton(timelineKey: timeline.key,),
          ],
        ),
      ],
    );

     */
  }
}

