import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:diary_for_me/db_models/event/event_model.dart';
import 'package:diary_for_me/timeline/widget/edit_event_cards/section_card.dart';
import 'package:diary_for_me/common/ui_kit.dart';
import 'package:smooth_corner/smooth_corner.dart';

class RelatedPhotoCard extends StatefulWidget {
  final Event event;
  const RelatedPhotoCard({super.key, required this.event});

  @override
  State<RelatedPhotoCard> createState() => _RelatedPhotoCardState();
}

class _RelatedPhotoCardState extends State<RelatedPhotoCard> {
  // 1. AnimatedList를 제어하기 위한 GlobalKey 선언
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  // 편의를 위해 갤러리 리스트 게터(getter) 사용
  List<String> get _gallery => widget.event.dailydata.gallery;

  void _removePicture(int index, String picture) {
    // 2. 리스트에서 삭제 애니메이션 실행
    _listKey.currentState?.removeItem(
      index,
      (context, animation) =>
          _buildPhotoItem(picture, animation), // 사라질 때 보여줄 위젯
      duration: const Duration(milliseconds: 300), // 애니메이션 속도
    );

    // 3. 실제 데이터 삭제 (setState 불필요 - AnimatedList가 알아서 다시 그림)
    widget.event.removePicture(picture);
  }

  // void _addPicture() {
  //   // 추가될 위치 (현재 리스트의 맨 뒤)
  //   final int newIndex = _gallery.length;

  //   // 1. 실제 데이터 추가
  //   widget.event.addPicture('https://picsum.photos/100?random=${DateTime.now().millisecondsSinceEpoch}');

  //   // 2. 리스트에 추가 애니메이션 실행
  //   _listKey.currentState?.insertItem(
  //     newIndex,
  //     duration: const Duration(milliseconds: 300),
  //   );
  // }
  void _addPicture() async {
    final ImagePicker picker = ImagePicker();

    // 갤러리에서 이미지 선택
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile == null) return; // 취소 시 종료

    final String filePath = pickedFile.path;

    // 1. 데이터 추가
    final int newIndex = _gallery.length;
    widget.event.addPicture(filePath);

    // 2. AnimatedList 애니메이션
    _listKey.currentState?.insertItem(
      newIndex,
      duration: const Duration(milliseconds: 300),
    );

    setState(() {}); // 필요 시 UI 갱신
  }

  final double imageSize = 120;

  // 개별 사진 아이템을 빌드하는 메서드 (애니메이션 적용)
  Widget _buildPhotoItem(String picture, Animation<double> animation) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutQuad,
      reverseCurve: Curves.easeInQuad,
    );

    return SizeTransition(
      axis: Axis.horizontal,
      axisAlignment: 0.0,
      sizeFactor: curvedAnimation,
      child: ScaleTransition(
        scale: curvedAnimation,
        child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: SizedBox(
            width: imageSize,
            child: Stack(
              children: [
                SmoothClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  smoothness: 0.6,
                  child:
                      // Image.network(
                      //   picture,
                      //   width: imageSize,
                      //   height: imageSize,
                      //   fit: BoxFit.cover,
                      // ),
                      Image(
                        image: picture.startsWith('http')
                            ? NetworkImage(picture)
                            : FileImage(File(picture)) as ImageProvider,
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                      ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  alignment: Alignment.topRight,
                  decoration: ShapeDecoration(
                    shape: SmoothRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                      smoothness: 0.6,
                      side: BorderSide(
                        color: Colors.black.withAlpha(24),
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    // 삭제 시 인덱스가 필요하므로 수정
                    onTap: () {
                      // 현재 데이터상의 인덱스를 찾아서 넘겨줌
                      final index = _gallery.indexOf(picture);
                      if (index != -1) {
                        _removePicture(index, picture);
                      }
                    },
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black38,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: '관련 사진',
      children: [
        SizedBox(height: 16),
        SizedBox(
          height: imageSize, // 리스트의 높이 고정
          child: AnimatedList(
            key: _listKey,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 20), // 시작 여백
            // 아이템 개수: 사진 개수 + 추가 버튼(1개)
            initialItemCount: _gallery.length + 1,
            itemBuilder: (context, index, animation) {
              if (index == _gallery.length) {
                return Padding(
                  padding: const EdgeInsets.only(right: 20), // 끝 여백
                  child: ContainerButton(
                    onTap: _addPicture,
                    color: themePageColor, // 기존 코드의 변수 사용
                    side: BorderSide(
                      color: themeDeepColor,
                      width: 1.0,
                    ), // 기존 코드 변수
                    width: imageSize,
                    height: imageSize,
                    borderRadius: BorderRadius.circular(24),
                    child: const Center(
                      child: Text(
                        "사진\n추가하기\n+",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: textSecondary, // 기존 코드 변수
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }

              // 그 외에는 사진 아이템
              return _buildPhotoItem(_gallery[index], animation);
            },
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
