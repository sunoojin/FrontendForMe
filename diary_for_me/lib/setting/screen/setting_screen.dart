import 'package:diary_for_me/setting/widget/setting_category.dart';
import 'package:diary_for_me/timeline/service/event_model.dart';
import 'package:diary_for_me/timeline/service/timeline_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../common/ui_kit.dart';
import '../../diary/service/diary_model.dart';
import '../../diary/service/tag_model.dart';
import 'edit_collection_screen.dart';
import 'edit_profile_screen.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final diaryBox = Hive.box<Diary>('diaryBox');
    final tagsBox = Hive.box<Tag>('tagsBox');
    final timelineBox = Hive.box<TimeLine>('timelineBox');

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: textPrimary, size: 28.0),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '설정',
                style: pageTitle(),
              ),
              SizedBox(height: 16,),
              SettingCategory(
                title: '개인정보 변경하기',
                icon: Icons.person,
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => const EditProfileScreen()),
                  );
                },
              ),
              SizedBox(height: 16,),
              SettingCategory(
                title: '정보 수집 범위 변경하기',
                icon: Icons.collections,
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => const EditCollectionScreen()),
                  );
                },
              ),
              Expanded(child: SizedBox()),
              // 테스트용 db 초기화 버튼
              SettingCategory(
                title: '초기화',
                icon: Icons.warning,
                onTap: () async {
                  await diaryBox.clear();
                  await tagsBox.clear();
                  await timelineBox.clear();
                },
              ),
              SizedBox(height: 16,),
              // 테스트용 타임라인 추가 버튼
              SettingCategory(
                title: '타임라인 추가',
                icon: Icons.warning,
                onTap: () {
                  final newEvent1 = Event(
                      id: DateTime.now().toIso8601String(),
                      timestamp: DateTime.now(),
                      title: '새 이벤트 1',
                      content: '이벤트 내용 1',
                      feeling: 'good',
                      dailydata: {'gallery' : []}
                  );
                  final newEvent2 = Event(
                      id: DateTime.now().toIso8601String(),
                      timestamp: DateTime.now(),
                      title: '새 이벤트 2',
                      content: '이벤트 내용 2',
                      feeling: 'bad',
                      dailydata: {'gallery' : []}
                  );
                  final newTimeLine = TimeLine(
                      id: DateTime.now().toIso8601String(),
                      title: '새 타임라인 ${DateTime.now().second}초',
                      date: DateTime.now(),
                      events: [newEvent1, newEvent2],
                      selfsurvey: {'mood' : 'good', 'draft' : 'text'}
                  );
                  timelineBox.put(newTimeLine.id, newTimeLine);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
