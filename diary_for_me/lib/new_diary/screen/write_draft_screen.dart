import 'dart:ui';

import 'package:diary_for_me/common/ui_kit.dart';
import 'package:diary_for_me/home/screen/home_screen.dart';
import 'package:diary_for_me/new_diary/screen/finish_generation_screen.dart';
import 'package:diary_for_me/new_diary/service/diary_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:smooth_corner/smooth_corner.dart';

// [필수] DB 매니저 및 모델 import
import '../../DB/db_manager.dart';
import '../../DB/diary/diary_model.dart';
import '../../DB/timeline/timeline_model.dart';

class WriteDraftScreen extends StatefulWidget {
  // [변경] timelineKey(String) -> timelineId(int)
  final int timelineId;
  final String emotion;

  const WriteDraftScreen({
    super.key,
    required this.timelineId,
    required this.emotion,
  });

  @override
  State<WriteDraftScreen> createState() => _WriteDraftScreenState();
}

class _WriteDraftScreenState extends State<WriteDraftScreen> {
  // [삭제] Hive Box 및 Service 제거
  // late final DiaryService diaryService;
  // late final Box<TimeLine> timelineBox;
  // late final Box<Diary> diaryBox;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // [삭제] Hive 초기화 로직 제거
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // [핵심] 일기 생성 로직 (Isar 버전)
  // 임시임
  Future<void> _generateDiary() async {
    // 1. DB 인스턴스 가져오기
    final isar = await DB().instance;

    // 2. 타임라인 가져오기
    final timeline = await isar.timeLines.get(widget.timelineId);
    if (timeline == null) return; // 타임라인이 없으면 종료

    int? newDiaryId;

    await isar.writeTxn(() async {
      // 3. 타임라인 업데이트 (초안 저장 및 상태 변경)
      // SelfSurvey가 null일 수 있으므로 초기화
      timeline.selfsurvey ??= SelfSurvey();
      timeline.selfsurvey!.draft = _controller.text;
      timeline.selfsurvey!.mood = widget.emotion;
      timeline.status = TimelineStatus.completed; // 상태를 완료로 변경 (혹은 processing)

      await isar.timeLines.put(timeline);

      // 4. 새 일기 생성 (AI 생성 로직은 생략하고 더미 데이터 저장)
      // 실제로는 여기서 AI API를 호출하여 결과를 받아와야 합니다.
      final newDiary = Diary(
        title: '새 일기', // AI가 생성한 제목
        content: DiaryContent(text: _controller.text.isEmpty ? 'AI가 생성한 일기 내용입니다.' : _controller.text), // AI 생성 내용
        tag: [], // 초기 태그
      );

      // 5. 타임라인과 연결
      newDiary.timeline.value = timeline;

      // 6. 일기 저장
      newDiaryId = await isar.diarys.put(newDiary);

      // 7. IsarLink 저장 (필수)
      await newDiary.timeline.save();
    });

    if (newDiaryId == null) return;

    // 화면 이동
    if (!mounted) return;

    // 홈 화면으로 스택 초기화 후 이동
    Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute(builder: (context) => const HomePage()),
          (Route<dynamic> route) => false,
    );

    // 완료 화면으로 이동
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => FinishGenerationScreen(diaryId: newDiaryId!), // ID 전달
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: textPrimary, size: 28.0),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
        actions: [
          Text('3', style: appbarButton(color: textPrimary)),
          Text('/3', style: appbarButton(color: textTertiary)),
          const SizedBox(width: 20),
        ],
      ),
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('일기 초안을 작성해 볼까요?', style: pageTitle()),
              const SizedBox(height: 8),
              Text('오늘의 하루를 적어보세요', style: cardDetail()),
              const SizedBox(height: 16),
              // 입력 필드
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: ShapeDecoration(
                      shape: SmoothRectangleBorder(
                        side: BorderSide(color: themeDeepColor, width: 1.0),
                        borderRadius: BorderRadius.circular(32),
                        smoothness: 0.6,
                      ),
                      color: themePageColor,
                    ),
                    child: TextField(
                      controller: _controller,
                      onChanged: (text) {
                        setState(() {});
                      },
                      cursorColor: themeColor,
                      minLines: 3,
                      maxLines: null,
                      style: diaryDetail(fontWeight: FontWeight.w400),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(20),
                        hintText: '내용을 입력해주세요.',
                        hintStyle: diaryDetail(color: textTertiary),
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: _controller.text.isEmpty
                    ? Text(
                  textAlign: TextAlign.center,
                  '일기 초안이 없어도 AI가 일기를 생성할 수 있지만,\n결과가 정확하지 않을 수 있어요.',
                  style: contentDetail(),
                )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              // 버튼
              _controller.text.isEmpty
                  ? ContainerButton(
                key: const ValueKey('empty'),
                borderRadius: BorderRadius.circular(24),
                color: themeColor.withAlpha(24),
                height: 68,
                onTap: _generateDiary,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '건너뛰고 일기 생성하기',
                        style: mainButton(color: themeColor),
                      ),
                      Icon(
                        Icons.navigate_next,
                        size: 24,
                        color: themeColor,
                      ),
                    ],
                  ),
                ),
              )
                  : ContainerButton(
                key: const ValueKey('fill'),
                borderRadius: BorderRadius.circular(24),
                color: themeColor.withAlpha(255),
                height: 68,
                shadows: [
                  BoxShadow(
                    color: themeColor.withAlpha(128),
                    spreadRadius: -20,
                    blurRadius: 30,
                    offset: const Offset(0, 30),
                  ),
                ],
                onTap: _generateDiary,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('일기 생성하기', style: mainButton()),
                      const Icon(
                        Icons.navigate_next,
                        size: 24,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              // 안전영역
              const SafeArea(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}