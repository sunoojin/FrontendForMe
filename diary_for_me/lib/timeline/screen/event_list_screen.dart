import 'package:flutter/material.dart';
import 'package:diary_for_me/common/ui_kit.dart';
import 'package:diary_for_me/timeline/widget/event_card.dart';
import 'package:diary_for_me/timeline/screen/edit_event_screen.dart';

class EventListScreen extends StatelessWidget {
  const EventListScreen({super.key, required date});

  @override
  Widget build(BuildContext context) {
    // 임시 데이터
    final events = [
      {"time": "12:00", "title": "필동함박에서 점심식사", "description": "후배와 점심식사"},
      {
        "time": "16:00",
        "title": "카페에서 커피 마시면서 공부하기",
        "description": "블루포트에서 혼공",
      },
      {"time": "18:00", "title": "동아리 연습에 참여하기", "description": "축제 무대 연습"},
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 바
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 30),
                  ),
                  Row(
                    children: [
                      const Text(
                        '1',
                        style: TextStyle(fontSize: 24, color: textPrimary),
                      ),
                      const Text(
                        '/3',
                        style: TextStyle(fontSize: 24, color: textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 제목
              const Text(
                "하루 돌아보기",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                "수집된 정보들을 바탕으로 생성된 타임라인이에요.\n"
                "실제 있었던 일과 다르다면 수정해 주세요.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // 이벤트 목록
              Expanded(
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final e = events[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
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

              const SizedBox(height: 8),

              // 활동 추가 버튼
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, color: Colors.black54, size: 18),
                  label: const Text(
                    "활동 추가",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    shadowColor: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 다음 버튼
              Center(
                child: TextButton.icon(
                  onPressed: () {}, // 감정 입력 화면으로 이동
                  icon: const Text(
                    "다음으로",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  label: const Icon(
                    Icons.arrow_right_alt,
                    color: Colors.black,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
