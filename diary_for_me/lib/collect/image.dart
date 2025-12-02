import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:http/http.dart' as http; // http 패키지 import

Future<List<Map<String, String>>> collectAndUploadImages(DateTime targetDate) async {
  List<Map<String, String>> uploadedImages = [];

  try {
    // 1. 권한 요청
    final perm = await PhotoManager.requestPermissionExtend();
    if (!perm.hasAccess) {
      debugPrint('Photo permission denied.');
      return [];
    }

    // 시작시간 & 종료시간 설정
    final start = DateTime(
      targetDate.year, targetDate.month, targetDate.day, 6, 0, 0,
    );
    final end = DateTime(
      targetDate.year, targetDate.month, targetDate.day, 20, 59, 59,
    );

    // 2. 앨범 가져오기
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );

    if (albums.isEmpty) return [];
    final AssetPathEntity allImagesAlbum = albums.first;
    final int total = await allImagesAlbum.assetCountAsync;

    if (total == 0) return [];

    // 3. 페이지 단위로 조회 및 업로드
    const int pageSize = 500;
    int page = 0;

    final String baseUrl = dotenv.env['BASE_URL'] ?? '';
    final String uploadApiUrl = "$baseUrl/api/v1/upload/image";

    while (page * pageSize < total) {
      final List<AssetEntity> assets = await allImagesAlbum.getAssetListPaged(
        page: page,
        size: pageSize,
      );

      if (assets.isEmpty) break;

      for (final asset in assets) {
        final takenAt = asset.createDateTime;

        // 날짜 필터링
        if (takenAt.isBefore(start) || takenAt.isAfter(end)) continue;

        final file = await asset.file;
        if (file != null) {
          String? uploadedUrl = await _uploadImageToServer(file, uploadApiUrl);

          if (uploadedUrl != null) {
            uploadedImages.add({
              "timestamp": takenAt.toIso8601String(),
              "url": uploadedUrl,
            });
            print("업로드 완료: $uploadedUrl");
          }
          // --- 파일 업로드 로직 끝 ---
        }
      }
      page++;
    }

    print("오늘 업로드된 사진 수: ${uploadedImages.length}");
    return uploadedImages;

  } catch (e, st) {
    print("오류 발생: $e\n$st");
    return [];
  }
}

// 이미지 서버에 업로드 후 url 반환
Future<String?> _uploadImageToServer(File imageFile, String apiUrl) async {
  try {
    // Multipart Request 생성
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
    ));

    // 전송
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      // 성공 시 JSON 파싱
      final jsonResponse = jsonDecode(response.body);

      return jsonResponse['url'] as String?;
    } else {
      print("업로드 실패: ${response.statusCode} - ${response.body}");
      return null;
    }
  } catch (e) {
    print("업로드 중 예외 발생: $e");
    return null;
  }
}