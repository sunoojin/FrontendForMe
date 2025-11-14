import 'package:diary_for_me/common/ui_kit.dart';
import 'package:diary_for_me/timeline/service/event_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smooth_corner/smooth_corner.dart';

class EventCard extends StatelessWidget {
  final VoidCallback? onEdit;
  final Event event;

  const EventCard({
    super.key,
    this.onEdit,
    required this.event
  });

  @override
  Widget build(BuildContext context) {
    return ContainerButton(
      color: themePageColor,
      padding: const EdgeInsets.all(20),
      onTap: onEdit ?? () {},
      borderRadius: BorderRadius.circular(32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 시간
          Container(
            alignment: Alignment.center,
            width: 48,
            height: 36,
            child: Text(
              DateFormat('HH:mm').format(event.timestamp),
              style: const TextStyle(
                fontSize: 16,
                color: textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 24,
            width: 1,
            color: Colors.black.withAlpha(16),
          ),
          const SizedBox(width: 12),
          // 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: contentTitle()
                ),
                const SizedBox(height: 6),
                Text(
                  event.content,
                  style: contentDetail()
                ),
              ],
            ),
          ),
          Text(
            '편집 →',
            style: contentDetail(),
          ),
        ],
      ),
    );
  }
  /*
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(32),
      decoration: ShapeDecoration(
        shape: SmoothRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: const Color(0xFFF7F7F8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 시간
          Text(
            time,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          // 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
          // 편집 버튼
          GestureDetector(
            onTap: onEdit,
            child: const Padding(
              padding: EdgeInsets.only(left: 8, top: 4),
              child: Text(
                "편집 →",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
   */
}
