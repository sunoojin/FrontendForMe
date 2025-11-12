import 'package:flutter/material.dart';
import 'package:diary_for_me/common/ui_kit.dart';

import 'package:diary_for_me/timeline/widget/info_box.dart';
import 'package:diary_for_me/timeline/widget/generate_button.dart';

/// ✅ 재사용 가능한 타임라인 카드 위젯
Widget timelineCard({
  required String dateText, // 날짜
  required int activityCount, // 생성된 활동 개수
  required int infoCount, // 수집된 정보 개수
  required DateTime date,
}) {
  return contentsCard(
    children: [
      Text(
        dateText,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InfoBox(title: "생성된 활동", value: "$activityCount개"),
          InfoBox(title: "수집된 정보", value: "$infoCount개"),
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
      PurpleButton(text: "일기 생성하기", date: date),
    ],
  );
}
