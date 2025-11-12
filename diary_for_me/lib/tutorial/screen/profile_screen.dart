import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // date 포맷을 위함
import 'package:diary_for_me/common/colors.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'set_collection_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController(); // 이름
  DateTime? _selectedDate; // 생년월일
  String? _gender; // 성별

  // 입력창
  Widget _roundedInput({required String category, required Widget child}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              category,
              style: TextStyle(
                fontSize: 14,
                color: textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F7F8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Color(0xFFEDEEF0),
              style: BorderStyle.solid,
            ),
          ),
          child: child,
        ),
      ],
    );
  }

  // 생년월일 선택 함수
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 100);
    final lastDate = now;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(now.year - 20),
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return child!;
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> handleNextPressed() async {
    debugPrint('이름: ${_nameController.text}');
    debugPrint('생년월일: $_selectedDate');
    debugPrint('성별: $_gender');

    try {
      final prefs = await SharedPreferences.getInstance();

      // 사용자 정보 저장
      await prefs.setString('name', _nameController.text.trim());
      final dateStr = _selectedDate?.toIso8601String() ?? '';
      await prefs.setString('date', dateStr);
      await prefs.setString('gender', _gender ?? '');

      // 저장 성공 후 원하는 화면으로 이동
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SetCollectionScreen()),
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
                    '1',
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
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // 제목
                      const Text(
                        '정보를 입력해 주세요',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 이름 입력 (둥근 박스)
                      _roundedInput(
                        category: '이름',
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: '예) 홍길동',
                            hintStyle: TextStyle(color: Colors.black38),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 생년월일 / 성별 (가로 배치)
                      Row(
                        children: [
                          // 생년월일
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: _pickDate,
                                  child: _roundedInput(
                                    category: '생년월일',
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _selectedDate == null
                                                ? '선택해 주세요'
                                                : DateFormat.yMMMMd(
                                                  'ko',
                                                ).format(_selectedDate!),
                                            style: TextStyle(
                                              color:
                                                  _selectedDate == null
                                                      ? Colors.black38
                                                      : Colors.black87,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.calendar_today_outlined,
                                          size: 18,
                                          color: Colors.black54,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          // 성별
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                _roundedInput(
                                  category: '성별',
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _gender,
                                      isExpanded: true,
                                      isDense: true,
                                      hint: const Text(
                                        '선택해 주세요',
                                        style: TextStyle(color: Colors.black38),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'male',
                                          child: Text('남성'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'female',
                                          child: Text('여성'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'other',
                                          child: Text('선택 안 함'),
                                        ),
                                      ],
                                      onChanged:
                                          (v) => setState(() => _gender = v),
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // 안내 문구
                      const Text(
                        '입력한 정보들은 일기생성을 위해 AI에 활용될 수 있습니다.',
                        style: TextStyle(fontSize: 14, color: infoText),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.18,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 하단의 "다음으로 →" 텍스트 버튼 (가운데 정렬)
            Padding(
              padding: const EdgeInsets.only(bottom: 18.0),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    // 다음 버튼 동작: 이름만 필수 입력
                    if (_nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('이름을 입력해 주세요')),
                      );
                      return;
                    }
                    handleNextPressed();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    '다음으로  →',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
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
