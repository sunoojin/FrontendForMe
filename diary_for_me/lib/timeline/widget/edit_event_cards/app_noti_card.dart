import 'package:diary_for_me/db_models/event/event_model.dart';
import 'package:flutter/material.dart';
import 'section_card.dart';
import 'package:diary_for_me/common/ui_kit.dart';

class AppNotiCard extends StatelessWidget {
  final Event event;
  const AppNotiCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: '앱 알림에서 찾은 내용',
      children: [
        event.dailydata.appnoti.isEmpty ?
        contents(
          children: [
            ...event.dailydata.appnoti.map((notification) {
              return Text(
                notification.text,
                style: TextStyle(
                  color: textPrimary,
                  height: 1.8,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.0,
                ),
              );
            })
          ],
        ) :
        contents(
          children: [
            Text(
              '관련 알림이 없어요',
              style: TextStyle(
                color: textTertiary,
                height: 1.8,
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
              ),
            ),
          ]
        )
      ],
    );
  }
}
