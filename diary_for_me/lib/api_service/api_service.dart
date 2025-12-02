import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter/foundation.dart';

class DailyLogApiService {
  final Dio _dio = Dio();
  late String baseUrl;

  Future<Map<String, dynamic>?> getTimelineFromAPI(Map<String, dynamic> jsonData) async {

    baseUrl = dotenv.env['BASE_URL'] ?? '';

    try {
      print('####################JSON 데이터 전송 시도####################');

      Response response = await _dio.post(
        '$baseUrl/api/v1/timeline',
        data: jsonData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      if (response.statusCode == 200) {
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
