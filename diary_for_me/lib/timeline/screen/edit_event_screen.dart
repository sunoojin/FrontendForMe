import 'dart:ui';

import 'package:diary_for_me/timeline/widget/location_box.dart';
import 'package:flutter/material.dart';
import 'package:diary_for_me/common/ui_kit.dart';
import 'package:diary_for_me/timeline/widget/section_card.dart';
import 'package:smooth_corner/smooth_corner.dart';
import '../service/event_model.dart';

class ActivityEditSheet {
  static Future<Event?> show(
      BuildContext context, {
        Event? initialEvent, // 1. 수정할 Event 객체를 받음
      }) async {
    // 2. showModalBottomSheet가 Event?를 반환하도록 타입을 지정
    final Event? result = await showModalBottomSheet<Event?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // 투명하게 두고
      builder: (_) => _ActivityEditContent(
        initialEvent: initialEvent, // 3. Content 위젯에 초기 데이터 전달
      ),
      useSafeArea: true,
      // ... (기존 shape, clipBehavior 등)
      shape: RoundedRectangleBorder( // SmoothRectangleBorder 대신 표준 사용 (호환성)
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      enableDrag: true, // 드래그로 닫을 수 있게 하는 것이 일반적입니다.
    );

    // 4. 모달에서 반환된 최종 Event 객체를 다시 반환
    return result;
  }
}

class _ActivityEditContent extends StatefulWidget {
  final Event? initialEvent;
  const _ActivityEditContent({
    super.key,
    this.initialEvent
  });

  @override
  State<_ActivityEditContent> createState() => _ActivityEditContentState();
}

class _ActivityEditContentState extends State<_ActivityEditContent> {
  String selectedHour = "12시";
  String selectedMinute = "00분";
  bool liked = true;
  String location = '서울 중구 동호로 256';

  // 사진 추가 함수
  void _addPicture () {}
  // 사진 삭제 함수
  void _removePicture () {}
  // 위치 변경 함수
  void _changeLocation () {}
  // 저장 함수
  void _saveChanges () {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.5,
      maxChildSize: 1,
      builder: (context, scrollController) {
        return GestureDetector(
          onTap: () {FocusScope.of(context).unfocus();},
          child: Scaffold(
            extendBodyBehindAppBar: true,
            // 상단 바
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY:18),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Container(
                      color: Colors.white.withAlpha(249),
                      height: 80,
                      padding: EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IntrinsicWidth(
                            child: ContainerButton(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => Navigator.pop(context),
                              color: themeDeepColor,
                              child: Center(
                                child: Text(
                                  '취소',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500
                                  ),
                                )
                              ),
                            ),
                          ),
                          IntrinsicWidth(
                            child: ContainerButton(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              borderRadius: BorderRadius.circular(20),
                              onTap: _saveChanges,
                              color: themeDeepColor,
                              child: Center(
                                child: Text(
                                  '완료',
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500
                                  ),
                                )
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            backgroundColor: themePageColor,
            body: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              controller: scrollController,
              child: Column(
                children: [
                  // 활동 정보
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 64,),
                        // 제목
                        TextField(
                          cursorColor: themeColor,
                          maxLines: 1,
                          style: pageTitle(),
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            hintText: '활동 이름을 입력해주세요',
                            contentPadding: EdgeInsets.zero,
                            hintStyle: pageTitle(color: textTertiary),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: themeDeepColor)
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: themeDeepColor)
                            ),
                          ),
                        ),
                        SizedBox(height: 16,),
                        // 활동 시각
                        const Text(
                          '활동 시각',
                          style: TextStyle(
                            color: textTertiary,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700
                          )
                        ),
                        const SizedBox(height: 6,),
                        IntrinsicWidth(
                          child: Container(
                            height: 52,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            decoration: ShapeDecoration(
                              shape: SmoothRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                smoothness: 0.6,
                                side: BorderSide(color: themeDeepColor, width: 1.0)
                              ),
                              color: themePageColor,
                            ),
                            child: Row(
                              children: [
                                // 시간 선택
                                DropdownButton<String>(
                                  underline: SizedBox(),
                                  value: selectedHour,
                                  dropdownColor: Colors.white,
                                  padding: EdgeInsets.all(0),
                                  elevation: 8,
                                  borderRadius: BorderRadius.circular(16),
                                  items: [
                                    for (int i = 0; i < 24; i++)
                                      DropdownMenuItem(
                                        value: "${i.toString().padLeft(2, '0')}시",
                                        child: Text("${i.toString().padLeft(2, '0')}시"),
                                      ),
                                  ],
                                  onChanged: (v) => setState(() => selectedHour = v!),
                                  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400, color: textPrimary),
                                ),
                                Container(color: Colors.black.withAlpha(30), height: 24, width: 1,),
                                SizedBox(width: 10,),
                                // 분 선택
                                DropdownButton<String>(
                                  underline: SizedBox(),
                                  value: selectedMinute,
                                  dropdownColor: Colors.white,
                                  padding: EdgeInsets.all(0),
                                  elevation: 8,
                                  borderRadius: BorderRadius.circular(20),
                                  items: [
                                    for (int i = 0; i < 60; i += 5)
                                      DropdownMenuItem(
                                        value: "${i.toString().padLeft(2, '0')}분",
                                        child: Text("${i.toString().padLeft(2, '0')}분"),
                                      ),
                                  ],
                                  onChanged: (v) => setState(() => selectedMinute = v!),
                                  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400, color: textPrimary),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16,),
                        // 활동 내용
                        const Text(
                          '활동 내용',
                          style: TextStyle(
                            color: textTertiary,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700
                          )
                        ),
                        const SizedBox(height: 6,),
                        Container(
                          decoration: ShapeDecoration(
                            shape: SmoothRectangleBorder(
                              side: BorderSide(color: themeDeepColor, width: 1.0),
                              borderRadius: BorderRadius.circular(20),
                              smoothness: 0.6,
                            ),
                            color: themePageColor,
                          ),
                          child: TextField(
                            cursorColor: themeColor,
                            minLines: 1,
                            maxLines: null,
                            style: diaryDetail(fontWeight: FontWeight.w400),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(14),
                              hintText: '내용을 입력해주세요.',
                              hintStyle: diaryDetail(color: textTertiary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16,),

                        // 평가
                        const Text(
                          '활동 평가',
                          style: TextStyle(
                            color: textTertiary,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700
                          )
                        ),
                        const SizedBox(height: 6,),
                        Container(
                          clipBehavior: Clip.antiAlias,
                          padding: EdgeInsets.all(6),
                          decoration: ShapeDecoration(
                            shape: SmoothRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                              smoothness: 0.6
                            ),
                            color: themePageColor,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => liked = true),
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: ShapeDecoration(
                                      color:
                                      liked
                                          ? Colors.white
                                          : themePageColor,
                                      /*
                                      border: Border.all(
                                        color: liked ? themeColor : Colors.transparent,
                                      ),

                                       */
                                      shape: SmoothRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                        smoothness: 0.6
                                      ),
                                      shadows: [
                                        liked ?
                                        BoxShadow(
                                          color: Colors.black.withAlpha(20),
                                          blurRadius: 16.0,
                                          offset: Offset.zero,
                                        ) :
                                        BoxShadow(
                                          color: Colors.black.withAlpha(0),
                                          blurRadius: 16.0,
                                          offset: Offset.zero,
                                        )
                                      ]
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.thumb_up,
                                          color: liked ? themeColor : textTertiary,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "좋았어요",
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: liked ? themeColor : textTertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => liked = false),
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: ShapeDecoration(
                                      color:
                                      !liked
                                          ? Colors.white
                                          : themePageColor,
                                      /*
                                      border: Border.all(
                                        color: liked ? themeColor : Colors.transparent,
                                      ),

                                       */
                                      shape: SmoothRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                        smoothness: 0.6
                                      ),
                                      shadows: [
                                        !liked ?
                                        BoxShadow(
                                          color: Colors.black.withAlpha(20),
                                          blurRadius: 16.0,
                                          offset: Offset.zero,
                                        ) :
                                        BoxShadow(
                                          color: Colors.black.withAlpha(0),
                                          blurRadius: 16.0,
                                          offset: Offset.zero,
                                        )
                                      ]
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.thumb_down,
                                          color: !liked ? themeColor : textTertiary,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "나빴어요",
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: !liked ? themeColor : textTertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 관련 항목
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      children: [
                        // 관련 사진
                        SectionCard2(
                          title: '관련 사진',
                          children: [
                            SizedBox(height: 16,),

                            // 사진 목록
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: BouncingScrollPhysics(),
                              child: Row(
                                children: [
                                  SizedBox(width: 20,),
                                  for (int i = 0; i < 3; i++)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Stack(
                                        children: [
                                          SmoothClipRRect(
                                            borderRadius: BorderRadius.circular(20),
                                            smoothness: 0.6,
                                            child: Image.network(
                                              "https://picsum.photos/100?random=$i",
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: GestureDetector(
                                              onTap: () => _removePicture(),
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  color: Colors.black45,
                                                  shape: BoxShape.circle,
                                                ),
                                                padding: const EdgeInsets.all(2),
                                                child: const Icon(
                                                  Icons.close,
                                                  size: 20,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  GestureDetector(
                                    onTap: _addPicture,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: ShapeDecoration(
                                        shape: SmoothRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          smoothness: 0.6,
                                          side: BorderSide(
                                            color: themeDeepColor,
                                            width: 1.0
                                          )
                                        ),
                                        color: themePageColor,
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "사진\n추가하기\n+",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: textSecondary,
                                            fontWeight: FontWeight.w500
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 20,)
                                ],
                              ),
                            ),
                            SizedBox(height: 8,),
                          ],

                        ),

                        // 위치
                        SectionCard2(
                          title: '위치',
                          children: [
                            contents(
                              children: [
                                Text(
                                  location ?? '주소 없음',
                                  style: cardTitle(),
                                ),
                                SizedBox(height: 16,),
                                // LocationBox에 위치 위젯 구현하면됨
                                LocationBox(),
                                borderHorizontal(),
                              ]
                            ),
                            bottomButton(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('위치 변경', style: cardDetail(color: textTertiary)),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 19,
                                    color: textTertiary,
                                  ),
                                ],
                              ),
                              onTap: _changeLocation
                            ),
                          ],
                        ),

                        // 알림
                        SectionCard2(
                          title: '앱 알림에서 찾은 내용',
                          children: [
                            contents(
                              children: [
                                const Text(
                                  "12시 필동함박 2인 네이버 예약\n"
                                      "신한카드 필동함박에서 38000원 결제\n"
                                      "후배의 밥약 카톡",
                                  style: TextStyle(
                                    color: textPrimary,
                                    height: 1.8,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16.0
                                  ),
                                ),
                              ]
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 80,)
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
