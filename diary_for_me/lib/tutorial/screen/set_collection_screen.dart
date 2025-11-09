import 'package:flutter/material.dart';
import 'package:diary_for_me/common/colors.dart';
import 'package:diary_for_me/tutorial/widget/consent_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diary_for_me/main/home_screen.dart';

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

  Future<void> handleStartPressed() async {
    // 디버깅 로그 (개발모드에서만)
    debugPrint('선택상태: $_selected');

    try {
      final prefs = await SharedPreferences.getInstance();

      // 최소한의 플래그 저장: 사용자가 이미 정보 입력했음을 표시
      await prefs.setBool('hasUserInfo', true);

      // 각 항목의 선택 상태 저장
      await prefs.setBool('consent_push', _selected['push'] ?? false);
      await prefs.setBool('consent_gallery', _selected['gallery'] ?? false);
      await prefs.setBool('consent_location', _selected['location'] ?? false);
      await prefs.setBool('consent_user', _selected['user'] ?? false);

      // 저장 성공 후 HomePage로 이동 (현재 화면을 대체)
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      debugPrint('SharedPreferences 저장 오류: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장 중 오류가 발생했습니다. 다시 시도해 주세요.')),
      );
    }
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
                    debugPrint('선택상태: $_selected');
                    handleStartPressed();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 10,
                    shadowColor: mainColor,
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
