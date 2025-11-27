import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(MyApp());
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   List<String> _photo = [];
//   int _savedCount = -1;
//   bool _loading = false;

//   void _runCollect() async {
//     setState(() {
//       _loading = true;
//       _savedCount = -1;
//     });
//     List<String> photoList = await collectImages(DateTime(2025, 11, 25)); ///// <- 사용 예시!!
//     int count = photoList.length;
//     setState(() {
//       _photo = photoList;
//       _savedCount = count;
//       _loading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text('Today Photo Collector')),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: _loading ? null : _runCollect,
//                 child: Text(_loading ? '실행 중...' : '사진 경로 반환'),
//               ),
//               if (_savedCount >= 0)
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Text('저장한 사진 수: $_savedCount'),
//                 ),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: _photo.length,
//                   itemBuilder: (context, index) {
//                     return Text(_photo[index]);
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

Future<List<String>> collectImages(DateTime targetDate) async {
  try {
    // 1. 권한 요청
    final perm = await PhotoManager.requestPermissionExtend(); // 권한 요청
    if (!perm.hasAccess) {
      debugPrint('Photo permission denied.');
      return [];
    }

    // 2. 날짜 설정
    final start = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      0,
      0,
      0,
    );
    final end = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      23,
      59,
      59,
    );

    debugPrint('$start');

    // 3. 모든 이미지 앨범(전체 모음) 가져오기
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );

    if (albums.isEmpty) {
      debugPrint('No image albums found.');
      return [];
    }
    final AssetPathEntity allImagesAlbum = albums.first;

    // assetCountAsync로 비동기 개수 조회
    final int total = await allImagesAlbum.assetCountAsync;
    if (total == 0) {
      debugPrint('No images in album.');
      return [];
    }

    // 4. 오늘 찍은 사진들의 경로를 담을 리스트
    List<String> todayPaths = [];

    // 5. 페이지 단위로 안전하게 불러오기 (예: 한 페이지당 500개)
    const int pageSize = 500;
    int page = 0;

    while (page * pageSize < total) {
      final List<AssetEntity> assets = await allImagesAlbum.getAssetListPaged(
        page: page,
        size: pageSize,
      );

      if (assets.isEmpty) break;
      for (final asset in assets) {
        final takenAt = asset.createDateTime;
        if (takenAt.isBefore(start) || takenAt.isAfter(end)) continue;

        final file = await asset.file;
        if (file != null) {
          todayPaths.add(file.path);
        }
      }
      page++;
    }

    debugPrint("오늘 찍은 사진 수: ${todayPaths.length}");
    return todayPaths;
  } catch (e, st) {
    debugPrint("오류 발생: $e\n$st");
    return [];
  }
}
