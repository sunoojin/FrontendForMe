import 'package:diary_for_me/common/colors.dart';
import 'package:diary_for_me/common/text_style.dart';
import 'package:diary_for_me/diary/diary_page.dart';
import 'package:flutter/material.dart';
import 'package:diary_for_me/common/widgets/buttons.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';


class DiaryTile extends StatefulWidget {
  final String title;
  final String details;
  final DateTime date;
  final List<String> tags;

  const DiaryTile({
    super.key,
    required this.title,
    required this.details,
    required this.date,
    required this.tags,
  });

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
        // 터치 시 동작
        // 일기 페이지로 이동
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => DiaryPage(title: widget.title, details: widget.details, tags: widget.tags, date: widget.date,))
          );
        },
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사진이 들어갈 영역
            // 임시로 대체함
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
                    style: cardDetail(),
                    DateFormat('yyyy.MM.dd(E)').format(widget.date)
                  ),
                  SizedBox(height: 6,),
                  Text(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: contentTitle(),
                    widget.title
                  ),
                  SizedBox(height: 6,),
                  Text(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: contentDetail(fontSize: 12),
                    widget.details
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

