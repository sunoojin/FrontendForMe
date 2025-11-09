import 'package:flutter/material.dart';
import 'package:diary_for_me/common/colors.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:diary_for_me/tutorial/widget/consent_card.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null); // 생년월일 선택 오류 수정
  runApp(const MaterialApp(home: SetCollectionScreen()));
}

class SetCollectionScreen extends StatefulWidget {
  const SetCollectionScreen({super.key});

  @override
  State<SetCollectionScreen> createState() => _SetCollectionScreenState();
}

class _SetCollectionScreenState extends State<SetCollectionScreen> {
  // 선택 상태들을 저장 (푸쉬 알림, 갤러리, 위치, 사용자)
  final Map<String, bool> _selected = {
    'push': false,
    'gallery': false,
    'location': false,
    'user': true,
  };

  void _toggle(String key) {
    setState(() {
      _selected[key] = !(_selected[key] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 20.0;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 바: 뒤로가기 + 진행도
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 12,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Icon(Icons.arrow_back, size: 24),
                  ),
                  const Spacer(),
                  const Text(
                    '2',
                    style: TextStyle(fontSize: 24, color: textPrimary),
                  ),
                  const Text(
                    '/2',
                    style: TextStyle(fontSize: 24, color: textSecondary),
                  ),
                ],
              ),
            ),

            // 본문
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 30,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      // 제목
                      const Text(
                        '일기 생성에 사용할 항목을\n골라주세요',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            //const SizedBox(height: 12),

            // 카드 그리드
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                ),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    ConsentCard(
                      title: '푸쉬 알림',
                      subtitle: '앱의 알림들을\n수집합니다.',
                      icon: Icons.notifications_none,
                      selected: _selected['push'] ?? false,
                      onTap: () => _toggle('push'),
                    ),
                    ConsentCard(
                      title: '갤러리',
                      subtitle: '갤러리 내의 사진을\n수집합니다.',
                      icon: Icons.image_outlined,
                      selected: _selected['gallery'] ?? false,
                      onTap: () => _toggle('gallery'),
                    ),
                    ConsentCard(
                      title: '위치 정보',
                      subtitle: 'GPS 정보를\n수집합니다.',
                      icon: Icons.location_on_outlined,
                      selected: _selected['location'] ?? false,
                      onTap: () => _toggle('location'),
                    ),
                    ConsentCard(
                      title: '사용자 정보',
                      subtitle: '사용자의 성별과\n나이를 수집합니다.',
                      icon: Icons.person_outline,
                      selected: _selected['user'] ?? false,
                      onTap: () => _toggle('user'),
                    ),
                  ],
                ),
              ),
            ),

            // 안내 문구
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding,
              ),
              child: Text(
                '선택시 민감정보수집 및 활용에 동의하는 것으로 간주됩니다.',
                style: TextStyle(color: infoText, fontSize: 14),
              ),
            ),

            const SizedBox(height: 18),

            // 시작하기 버튼
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: () {
                    // 예시: 선택된 항목들을 로그로 확인
                    // kDebugMode 또는 debugPrint 사용 가능
                    debugPrint('선택상태: $_selected');
                    // TODO: 권한 요청/다음 화면으로 이동 등
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 10,
                    shadowColor: mainColor.withOpacity(0.35),
                  ),
                  child: const Text(
                    '시작하기',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
