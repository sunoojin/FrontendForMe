import 'package:diary_for_me/common/colors.dart';
import 'package:diary_for_me/common/text_style.dart';
import 'package:flutter/material.dart';
import 'package:diary_for_me/common/widgets/buttons.dart';
import 'package:smooth_corner/smooth_corner.dart';

class DiaryTile extends StatefulWidget {

  const DiaryTile({super.key});

  @override
  State<DiaryTile> createState() => _DiaryTileState();
}

class _DiaryTileState extends State<DiaryTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: ContainerButton(
        borderRadius: BorderRadius.circular(26),
        onTap: () {},
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사진
            Container(
              width: 88,
              height: 88,
              decoration: ShapeDecoration(
                shape: SmoothRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  smoothness: 0.6
                ),
                color: themeColor.withAlpha(24)
              ),
            ),
            SizedBox(width: 12,),
            // 제목 및 내용
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '2025.11.11 (화)',
                    style: cardDetail(),
                  ),
                  SizedBox(height: 6,),
                  Text(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: contentTitle(),
                    '일기 제목'
                  ),
                  SizedBox(height: 6,),
                  Text(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: contentDetail(fontSize: 12),
                    '일기내용일기내용일기내용일기내용일기내용일기내용일기내용일기내용일기내용일기내용일기내용일기내용일기내용일기내용일기내용일기내용일기내용일기내용일기내용일기내용일기내용일기내용일기내용일기내용일기내용일기내용일기내용일기내용일기내용일기내용'
                  )
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}

