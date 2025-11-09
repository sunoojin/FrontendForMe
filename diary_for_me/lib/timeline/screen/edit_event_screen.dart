import 'package:flutter/material.dart';

class ActivityEditSheet {
  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ActivityEditContent(),
    );
  }
}

class _ActivityEditContent extends StatefulWidget {
  const _ActivityEditContent({super.key});

  @override
  State<_ActivityEditContent> createState() => _ActivityEditContentState();
}

class _ActivityEditContentState extends State<_ActivityEditContent> {
  String selectedHour = "12시";
  String selectedMinute = "00분";
  bool liked = true;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.95,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 바 (취소 / 완료)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "취소",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                    const Text(
                      "활동 편집",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "완료",
                        style: TextStyle(color: Colors.deepPurple),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                const Text(
                  "필동함박에서 식사",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 24),

                const Text(
                  "활동 시각",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    DropdownButton<String>(
                      value: selectedHour,
                      items: [
                        for (int i = 0; i < 24; i++)
                          DropdownMenuItem(
                            value: "${i.toString().padLeft(2, '0')}시",
                            child: Text("${i.toString().padLeft(2, '0')}시"),
                          ),
                      ],
                      onChanged: (v) => setState(() => selectedHour = v!),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: selectedMinute,
                      items: [
                        for (int i = 0; i < 60; i += 5)
                          DropdownMenuItem(
                            value: "${i.toString().padLeft(2, '0')}분",
                            child: Text("${i.toString().padLeft(2, '0')}분"),
                          ),
                      ],
                      onChanged: (v) => setState(() => selectedMinute = v!),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Text(
                  "활동 내용",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: "후배와 점심식사를 했다...",
                    filled: true,
                    fillColor: const Color(0xFFF8F8F8),
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  "활동 평가",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => liked = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color:
                                liked
                                    ? const Color(0xFFEDE4FF)
                                    : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  liked
                                      ? Colors.deepPurpleAccent
                                      : Colors.transparent,
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.thumb_up,
                                color: Colors.deepPurple,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "좋았어요",
                                style: TextStyle(color: Colors.deepPurple),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => liked = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color:
                                !liked
                                    ? const Color(0xFFF3F3F3)
                                    : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.thumb_down,
                                color: Colors.black45,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "나빴어요",
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 관련 사진
                _sectionCard(
                  title: "관련 사진",
                  child: Row(
                    children: [
                      for (int i = 0; i < 3; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                // child: Image.network(
                                //   "https://picsum.photos/100?random=$i",
                                //   width: 70,
                                //   height: 70,
                                //   fit: BoxFit.cover,
                                // ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black45,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFFF3F3F3),
                          ),
                          child: const Center(
                            child: Text(
                              "사진 추가하기 +",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 위치
                _sectionCard(
                  title: "위치",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "서울 중구 동호로 256",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          "https://maps.googleapis.com/maps/api/staticmap?center=Seoul&zoom=14&size=400x200&key=YOUR_API_KEY",
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "위치 변경 →",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 앱 알림 내용
                _sectionCard(
                  title: "앱 알림에서 찾은 내용",
                  child: const Text(
                    "12시 필동함박 2인 네이버 예약\n"
                    "신한카드 필동함박에서 38000원 결제\n"
                    "후배의 밥약 카톡",
                    style: TextStyle(height: 1.5),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
