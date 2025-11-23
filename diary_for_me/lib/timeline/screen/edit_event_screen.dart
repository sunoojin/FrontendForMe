import 'dart:ui';

import 'package:diary_for_me/timeline/widget/edit_dailydata_section.dart';
import 'package:flutter/material.dart';
import 'package:diary_for_me/common/ui_kit.dart';
import 'package:smooth_corner/smooth_corner.dart';
import '../../db_models/event/event_model.dart';

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
      builder:
          (_) => _ActivityEditContent(
            initialEvent: initialEvent, // 3. Content 위젯에 초기 데이터 전달
          ),
      useSafeArea: true,
      shape: SmoothRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        smoothness: 0.6,
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      enableDrag: false,
    );

    // 4. 모달에서 반환된 최종 Event 객체를 다시 반환
    return result;
  }
}

class _ActivityEditContent extends StatefulWidget {
  final Event? initialEvent;
  const _ActivityEditContent({super.key, this.initialEvent});

  @override
  State<_ActivityEditContent> createState() => _ActivityEditContentState();
}

class _ActivityEditContentState extends State<_ActivityEditContent> {
  final _formKey = GlobalKey<FormState>();

  int newTime = 12 * 60 + 0;

  String location = '서울 중구 동호로 256';

  late Event _resultEvent;

  // ModalRoute callback을 저장할 참조
  ModalRoute<dynamic>? _route;

  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    if (widget.initialEvent != null) {
      // [수정 모드]: 원본의 "복제본"을 생성
      _resultEvent = widget.initialEvent!.copyWith();
    } else {
      // [생성 모드]: "비어있는" 새 객체를 생성
      _resultEvent = Event.empty();
    }
    newTime = _resultEvent.timestamp.hour * 60 + (_resultEvent.timestamp.minute ~/ 30) * 30;
  }


  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // 1. 폼에 연결된 모든 onSaved 콜백을 실행시킴
      _formKey.currentState!.save();
      _resultEvent.timestamp = _resultEvent.timestamp.copyWith(
        hour: newTime ~/ 60,
        minute: newTime % 60,
      );

      // 2. 모든 변경사항이 적용된 _resultEvent 객체를 반환
      Navigator.of(context).pop(_resultEvent);
    }
  }

  // void _dismissChanges () {Navigator.pop(context);}

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // ModalRoute가 준비되면 pop 콜백을 등록
  //   final route = ModalRoute.of(context);
  //   if (_route != route) {
  //     // 이전에 등록한 게 있으면 제거
  //     if (_route != null) {
  //       _route!.removeScopedWillPopCallback(_onWillPop);
  //     }
  //     _route = route;
  //     _route?.addScopedWillPopCallback(_onWillPop);
  //   }
  // }

  // @override
  // void dispose() {
  //   // 안전하게 콜백 제거
  //   _route?.removeScopedWillPopCallback(_onWillPop);
  //   super.dispose();
  // }

  // 팝을 가로채서 확인 다이얼로그를 띄움
  // Future<bool> _onWillPop() async {
  //   // 만약 저장해도 되는 상황(변경 없음)이라면 바로 true 반환하도록 로직 추가 가능
  //   final shouldClose = await _showConfirmDiscardDialog();
  //   return shouldClose;
  // }

  // 취소 버튼에서 직접 호출하도록 변경
  void _dismissChanges() async {
    final shouldClose = await _showConfirmDiscardDialog();
    if (shouldClose) Navigator.of(context).pop();
  }

  // 실제 확인 다이얼로그
  Future<bool> _showConfirmDiscardDialog() async {
    // showDialog는 Future<bool?> 반환
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 명확히 선택하도록
      builder: (ctx) {
        return AlertDialog(
          title: const Text('편집 취소'),
          content: const Text('변경사항을 저장하지 않고 닫으시겠어요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('아니요'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('네'),
            ),
          ],
        );
      },
    );

    // null은 취소로 간주
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: PopScope<Event?>(
        // canPop: false,
        // onPopInvokedWithResult: (bool didPop, Event? result) async {
        //   // 사용자가 닫기 시도할 때(시스템/프로그래믹) 호출됨.
        //   final shouldClose = await _showConfirmDiscardDialog();
        //   if (shouldClose) {
        //     // 원하면 결과를 함께 반환할 수도 있음: Navigator.of(context).pop(_resultEvent);
        //     WidgetsBinding.instance.addPostFrameCallback((_) {
        //       Navigator.of(context).pop(_resultEvent);
        //     });
        //     Navigator.of(context).pop(_resultEvent);
        //   } else {
        //     // 닫기를 취소하면 아무것도 안 함.
        //   }
        // },
        child: Scaffold(
          backgroundColor: themePageColor,
          extendBodyBehindAppBar: true,
          // 상단 바
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  color: Colors.white.withAlpha(249),
                  height: 80,
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ContainerButton(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _dismissChanges(),
                        color: Colors.red.withAlpha(24),
                        child: Center(
                          child: Text(
                            '취소',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      ContainerButton(
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
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                // 활동 정보
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 64),
                        // 제목
                        TextFormField(
                          cursorColor: themeColor,
                          maxLines: 1,
                          style: pageTitle(),
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            hintText: '활동 이름을 입력해주세요',
                            contentPadding: EdgeInsets.zero,
                            hintStyle: pageTitle(color: textTertiary),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: themeDeepColor),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: themeDeepColor),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '제목을 입력해주세요';
                            }
                            return null;
                          },
                          initialValue: _resultEvent.title,
                          onSaved: (newValue) {
                            if (newValue != null) {
                              // 3. 샌드박스 객체의 값을 직접 수정
                              _resultEvent.title = newValue.trim();
                            }
                          },
                        ),
                        SizedBox(height: 16),
                        // 활동 시각 및 평가
                        Row(
                          children: [
                            // 활동 시각
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '활동 시각',
                                    style: TextStyle(
                                      color: textTertiary,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 52,
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                    decoration: ShapeDecoration(
                                      shape: SmoothRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        smoothness: 0.6,
                                        side: BorderSide(
                                          color: themeDeepColor,
                                          width: 1.0,
                                        ),
                                      ),
                                      color: themePageColor,
                                    ),
                                    child: DropdownButton<int>(
                                      isExpanded: true,
                                      underline: SizedBox(),
                                      value: newTime,
                                      dropdownColor: Colors.white,
                                      padding: EdgeInsets.all(0),
                                      elevation: 8,
                                      borderRadius: BorderRadius.circular(16),
                                      items: [
                                        for (int i = 0; i < 1440; i+= 30)
                                          DropdownMenuItem(
                                            value: i,
                                            child: Text(
                                              "${ (i ~/ 60).toString().padLeft(2, '0') }시 ${ (i % 60).toString().padLeft(2, '0') }분",
                                            ),
                                          ),
                                      ],
                                      onChanged:
                                          (v) => setState(() => newTime = v!),
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w400,
                                        color: textPrimary,
                                      ),
                                      icon: Icon(Icons.access_time_outlined, size: 20,),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 20,),
                            // 활동 평가
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '활동 평가',
                                    style: TextStyle(
                                      color: textTertiary,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ContainerButton(
                                          color: _resultEvent.feeling == 'good' ? Colors.redAccent.withAlpha(36) : themePageColor,
                                          side: BorderSide(
                                            color: _resultEvent.feeling == 'good' ? Colors.redAccent.withAlpha(48) : themeDeepColor,
                                            width: 1.0
                                          ),
                                          height: 52,
                                          onTap: () => setState(() => _resultEvent.feeling = 'good'),
                                          borderRadius: BorderRadius.circular(20),
                                          child: Center(
                                            child: Icon(
                                              Icons.thumb_up,
                                              color:
                                              _resultEvent.feeling == 'good' ? Colors.redAccent : textTertiary,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 6,),
                                      Expanded(
                                        child: ContainerButton(
                                          color: _resultEvent.feeling == 'bad' ? Colors.blueAccent.withAlpha(36) : themePageColor,
                                          side: BorderSide(
                                            color: _resultEvent.feeling == 'bad' ? Colors.blueAccent.withAlpha(48) : themeDeepColor,
                                            width: 1.0
                                          ),
                                          height: 52,
                                          onTap: () => setState(() => _resultEvent.feeling = 'bad'),
                                          borderRadius: BorderRadius.circular(20),
                                          child: Center(
                                            child: Icon(
                                              Icons.thumb_down,
                                              color:
                                              _resultEvent.feeling == 'bad' ? Colors.blueAccent : textTertiary,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),

                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 활동 내용
                        const Text(
                          '활동 내용',
                          style: TextStyle(
                            color: textTertiary,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          decoration: ShapeDecoration(
                            shape: SmoothRectangleBorder(
                              side: BorderSide(
                                color: themeDeepColor,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              smoothness: 0.6,
                            ),
                            color: themePageColor,
                          ),
                          child: TextFormField(
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
                            initialValue: _resultEvent.content,
                            onSaved: (newValue) {
                              if (newValue != null) {
                                _resultEvent.content = newValue;
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                // 관련 항목
                dailyDataEdit(event: _resultEvent)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
