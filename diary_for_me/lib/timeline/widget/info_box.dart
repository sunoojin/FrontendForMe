import 'package:diary_for_me/common/colors.dart';
import 'package:flutter/material.dart';
import 'package:smooth_corner/smooth_corner.dart';

class InfoBox extends StatelessWidget {
  final String title;
  final String value;
  const InfoBox({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          shape: SmoothRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: themePageColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary, height: 1.4),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 32, height: 1.4, color: textPrimary),
                ),
                Text(
                  '개 ',
                  style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 32, height: 1.4, color: textTertiary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
