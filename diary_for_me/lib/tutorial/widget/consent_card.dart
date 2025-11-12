import 'package:flutter/material.dart';
import 'package:diary_for_me/common/colors.dart';

/// 개별 카드 위젯
class ConsentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const ConsentCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 카드 배경(약한 회색), 둥근 모서리, 내부 패딩
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeDeepColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 아이콘 + 텍스트
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 아이콘 (상단 좌측)
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 28, color: textTertiary),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: textTertiary,
                    height: 1.2,
                  ),
                ),
              ],
            ),

            // 체크 동그라미 (우측 상단)
            Positioned(
              right: 6,
              top: 6,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: selected ? mainColor : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? mainColor : const Color(0xFFE9E9EA),
                    width: 1.2,
                  ),
                ),
                child:
                    selected
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : const Icon(
                          Icons.check,
                          size: 18,
                          color: Color(0xFFE9E9EA),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
