import 'package:flutter/material.dart';
import 'package:diary_for_me/common/ui_kit.dart';
import 'package:diary_for_me/timeline/widget/time_line_card.dart';

class TimelineListScreen extends StatelessWidget {
  const TimelineListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // 상단 뒤로가기 버튼
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, size: 30),
              ),

              const SizedBox(height: 24),

              // 제목
              const Text(
                "나의 타임라인",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                "사관이 기록한 타임라인이에요\n모인 타임라인으로 일기를 생성할 수 있어요.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              // 오늘
              contentsCard(
                children: [
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "사관이 정보를 수집중이에요.",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "정보 수집이 끝나면 오늘의 식록을 받아보실 수 있습니다.\n준비가 완료되면 알림을 보내드려요.",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: 0.5,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade200,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                ],
              ),

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
            ],
          ),
        ),
      ),
    );
  }
}
