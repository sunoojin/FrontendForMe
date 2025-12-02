import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';

class DailyLogApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://서버주소...';

  Future<Map<String, dynamic>?> uploadDailyLog(Map<String, dynamic> jsonData) async {
    try {
      print('####################JSON 데이터 전송 시도####################');

      Response response = await _dio.post(
        '$_baseUrl/api/upload',
        data: jsonData,
        options: Options(
          headers: {
            'Content-Type': 'application/json', // 일반 JSON 타입
          },
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('[업로드 및 타임라인 생성 성공]: ${response.statusCode}');
        // [핵심] 서버로부터 받은 JSON 데이터 반환
        return response.data as Map<String, dynamic>;
      } else {
        print('[❌서버 응답 오류]: ${response.statusCode}');
        return null;
      }

    } catch (e) {
      print('[❌업로드 에러]: $e');
      return null;
    }
  }
}
