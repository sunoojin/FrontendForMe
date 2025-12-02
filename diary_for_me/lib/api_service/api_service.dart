import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DailyLogApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://서버주소...';

  Future<void> uploadDailyLog(Map<String, dynamic> jsonData) async {
    try {
      print('🚀 JSON 데이터 전송 시작 (이미지 포함)...');

      // Dio는 Map을 넣으면 자동으로 JSON으로 변환해서 보냅니다.
      Response response = await _dio.post(
        '$_baseUrl/api/upload',
        data: jsonData, // Base64 이미지가 포함된 Map
        options: Options(
          headers: {
            'Content-Type': 'application/json', // 일반 JSON 타입
          },
          // 대용량 전송 시 타임아웃 늘리기
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      print('✅ 업로드 성공: ${response.statusCode}');

    } catch (e) {
      print('❌ 업로드 에러: $e');
    }
  }
}