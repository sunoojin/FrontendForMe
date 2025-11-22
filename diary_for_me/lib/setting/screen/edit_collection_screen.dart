//
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:diary_for_me/common/colors.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:diary_for_me/tutorial/widget/consent_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diary_for_me/home/screen/home_screen.dart';

import '../../common/ui_kit.dart';

class EditCollectionScreen extends StatefulWidget {
  const EditCollectionScreen({super.key});

  @override
  State<EditCollectionScreen> createState() => _EditCollectionScreenState();
}

class _EditCollectionScreenState extends State<EditCollectionScreen> {
  // 선택 상태들을 저장 (푸쉬 알림, 갤러리, 위치, 사용자)
  final Map<String, bool> _selected = {
    'push': false,
    'gallery': false,
    'location': false,
    'user': true,
  };

  @override
  void initState() {
    super.initState();
    _loadConsents();
  }

  // SharedPreferences에서 저장된 동의 상태 불러오기
  Future<void> _loadConsents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // prefs에 값이 없으면 기존 _selected 값(기본값)을 유지
      final push = prefs.getBool('consent_push');
      final gallery = prefs.getBool('consent_gallery');
      final location = prefs.getBool('consent_location');
      final user = prefs.getBool('consent_user');

      // mounted 체크 후 setState로 반영
      if (!mounted) return;
      setState(() {
        if (push != null) _selected['push'] = push;
        if (gallery != null) _selected['gallery'] = gallery;
        if (location != null) _selected['location'] = location;
        if (user != null) _selected['user'] = user;
      });

      debugPrint(
        'Loaded consents: push=$push, gallery=$gallery, location=$location, user=$user',
      );
    } catch (e) {
      debugPrint('SharedPreferences 로드 실패: $e');
    }
  }

  void _toggle(String key) async {
    setState(() {
      _selected[key] = !(_selected[key] ?? false);
    });

    // 즉시 SharedPreferences에 저장
    try {
      final prefs = await SharedPreferences.getInstance();
      switch (key) {
        case 'push':
          await prefs.setBool('consent_push', _selected['push'] ?? false);
          break;
        case 'gallery':
          await prefs.setBool('consent_gallery', _selected['gallery'] ?? false);
          break;
        case 'location':
          await prefs.setBool(
            'consent_location',
            _selected['location'] ?? false,
          );
          break;
        case 'user':
          await prefs.setBool('consent_user', _selected['user'] ?? false);
          break;
      }
      debugPrint('토글 저장: $key=${_selected[key]}');
    } catch (e) {
      debugPrint('SharedPreferences 저장 오류(토글): $e');
    }
  }

  Future<void> handleStartPressed() async {
    // 1) 선택 상태 디버그
    debugPrint('선택상태: $_selected');

    // 2) 권한 요청 결과를 저장할 맵
    final Map<String, bool> consentResult = {};

    // 헬퍼: 단일 Permission 요청 후 granted 여부 반환
    Future<bool> requestPermission(Permission permission) async {
      final status = await permission.status;
      if (status.isGranted) return true;

      final result = await permission.request();

      if (result.isGranted) return true;

      if (result.isPermanentlyDenied) {
        // 사용자에게 설정 열기를 권유
        final open = await showDialog<bool>(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text('권한 필요'),
                content: const Text('이 권한은 앱의 핵심 기능에 필요합니다. 설정에서 허용하시겠어요?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('취소'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('설정 열기'),
                  ),
                ],
              ),
        );
        if (open == true) {
          await openAppSettings();
        }
        return false;
      }

      // denied 혹은 기타 경우
      return false;
    }

    // 3) 갤러리 권한 요청 (플랫폼별)
    if (_selected['gallery'] == true) {
      bool granted = false;
      if (Platform.isIOS) {
        granted = await requestPermission(Permission.photos);
      } else {
        // Android: 외부 저장소 접근 (Android 13 이상은 별도 권한 필요할 수 있음)
        granted = await requestPermission(Permission.storage);
      }
      consentResult['gallery'] = granted;
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('갤러리 접근 권한이 없어 사진 수집이 제한됩니다.')),
        );
      }
    } else {
      consentResult['gallery'] = false;
    }

    // 4) 알림(푸시) 권한 요청
    if (_selected['push'] == true) {
      // Permission.notification은 Android & iOS 지원
      final granted = await requestPermission(Permission.notification);
      consentResult['push'] = granted;
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('알림 권한이 없어 푸시 정보 수집이 제한됩니다.')),
        );
      }
    } else {
      consentResult['push'] = false;
    }

    // 5) 위치 권한 요청
    if (_selected['location'] == true) {
      // 위치는 foreground 위치 권한으로 요청
      final granted = await requestPermission(Permission.locationWhenInUse);
      consentResult['location'] = granted;
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치 권한이 없어 위치 기반 기능이 제한됩니다.')),
        );
      }
    } else {
      consentResult['location'] = false;
    }

    // 6) 사용자 정보(프로필 같은 내부 데이터) 동의는 앱 내부 동의로 처리
    consentResult['user'] = _selected['user'] ?? false;

    // 7) SharedPreferences에 저장
    try {
      final prefs = await SharedPreferences.getInstance();

      // 동의 플래그 저장 (원하면 저장 키 통일)
      await prefs.setBool('consent_push', consentResult['push'] ?? false);
      await prefs.setBool('consent_gallery', consentResult['gallery'] ?? false);
      await prefs.setBool(
        'consent_location',
        consentResult['location'] ?? false,
      );
      await prefs.setBool('consent_user', consentResult['user'] ?? false);

      // 사용자가 정보를 입력했다는 플래그 (이미 profile에서 저장했더라도 안전하게 표시)
      await prefs.setBool('hasUserInfo', true);

      debugPrint('권한 저장 완료: $consentResult');
    } catch (e) {
      debugPrint('SharedPreferences 저장 오류: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('동의 저장 중 오류가 발생했습니다.')));
      return;
    }

    // 8) 모든 흐름 끝나면 홈으로 이동
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute(builder: (context) => const HomePage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: textPrimary, size: 28.0),
        backgroundColor: themePageColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
      ),
      backgroundColor: themePageColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 본문
              Text('수집할 항목의 범위를\n변경해주세요', style: pageTitle()),

              SizedBox(height: 16),

              //const SizedBox(height: 12),
              Expanded(
                child: Row(
                  children: [
                    ConsentCard(
                      title: '푸쉬 알림',
                      subtitle: '앱의 알림들을\n수집합니다.',
                      icon: Icons.notifications_none,
                      selected: _selected['push'] ?? false,
                      onTap: () => _toggle('push'),
                    ),
                    SizedBox(width: 12),
                    ConsentCard(
                      title: '갤러리',
                      subtitle: '갤러리 내의 사진을\n수집합니다.',
                      icon: Icons.image_outlined,
                      selected: _selected['gallery'] ?? false,
                      onTap: () => _toggle('gallery'),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12),
              Expanded(
                child: Row(
                  children: [
                    ConsentCard(
                      title: '위치 정보',
                      subtitle: 'GPS 정보를\n수집합니다.',
                      icon: Icons.location_on_outlined,
                      selected: _selected['location'] ?? false,
                      onTap: () => _toggle('location'),
                    ),
                    SizedBox(width: 12),
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
              const SizedBox(height: 16),
              // 안내 문구
              Center(
                child: Text(
                  '선택 시 민감정보수집 및 활용에 동의하는 것으로 간주됩니다.',
                  style: TextStyle(color: infoText, fontSize: 14),
                ),
              ),

              const SizedBox(height: 48),

              // 시작하기 버튼
              ContainerButton(
                borderRadius: BorderRadius.circular(24),
                color: themeColor.withAlpha(24),
                height: 68,
                onTap: () {
                  debugPrint('선택상태: $_selected');
                  handleStartPressed();
                },
                child: Center(
                  child: Text('변경하기', style: mainButton(color: themeColor)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'dart:io' show Platform;
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:diary_for_me/common/colors.dart';

// import 'package:permission_handler/permission_handler.dart';
// import 'package:diary_for_me/tutorial/widget/consent_card.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:diary_for_me/home/screen/home_screen.dart';

// import '../../common/ui_kit.dart';

// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/services.dart';

// class EditCollectionScreen extends StatefulWidget {
//   const EditCollectionScreen({super.key});

//   @override
//   State<EditCollectionScreen> createState() => _EditCollectionScreenState();
// }

// class _EditCollectionScreenState extends State<EditCollectionScreen> {
//   // 선택 상태들을 저장 (푸쉬 알림, 갤러리, 위치, 사용자)
//   final Map<String, bool> _selected = {
//     'push': false,
//     'gallery': false,
//     'location': false,
//     'user': true,
//   };

//   // MethodChannel for opening notification access settings
//   static const MethodChannel _platform = MethodChannel(
//     'app.channel.notification',
//   );

//   @override
//   void initState() {
//     super.initState();
//     _loadConsents();
//   }

//   // SharedPreferences에서 저장된 동의 상태 불러오기
//   Future<void> _loadConsents() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final push = prefs.getBool('consent_push');
//       final gallery = prefs.getBool('consent_gallery');
//       final location = prefs.getBool('consent_location');
//       final user = prefs.getBool('consent_user');

//       if (!mounted) return;
//       setState(() {
//         if (push != null) _selected['push'] = push;
//         if (gallery != null) _selected['gallery'] = gallery;
//         if (location != null) _selected['location'] = location;
//         if (user != null) _selected['user'] = user;
//       });

//       debugPrint(
//         'Loaded consents: push=$push, gallery=$gallery, location=$location, user=$user',
//       );
//     } catch (e) {
//       debugPrint('SharedPreferences 로드 실패: $e');
//     }
//   }

//   void _toggle(String key) async {
//     setState(() {
//       _selected[key] = !(_selected[key] ?? false);
//     });

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       switch (key) {
//         case 'push':
//           await prefs.setBool('consent_push', _selected['push'] ?? false);
//           break;
//         case 'gallery':
//           await prefs.setBool('consent_gallery', _selected['gallery'] ?? false);
//           break;
//         case 'location':
//           await prefs.setBool(
//             'consent_location',
//             _selected['location'] ?? false,
//           );
//           break;
//         case 'user':
//           await prefs.setBool('consent_user', _selected['user'] ?? false);
//           break;
//       }
//       debugPrint('토글 저장: $key=${_selected[key]}');
//     } catch (e) {
//       debugPrint('SharedPreferences 저장 오류(토글): $e');
//     }
//   }

//   // 기기에서 Android SDK int를 가져옴 (Android가 아니면 0 반환)
//   Future<int> _getAndroidSdkInt() async {
//     if (!Platform.isAndroid) return 0;
//     try {
//       final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//       final info = await deviceInfo.androidInfo;
//       return info.version.sdkInt ?? 0;
//     } catch (e) {
//       debugPrint('Failed to get android sdk int: $e');
//       return 0;
//     }
//   }

//   // 알림 접근 설정 화면 열기 (네이티브에서 인텐트로 처리)
//   Future<void> _openNotificationAccessSettings() async {
//     try {
//       await _platform.invokeMethod('openNotificationAccess');
//     } on PlatformException catch (e) {
//       debugPrint(
//         'Failed to open notification access settings via platform channel: $e',
//       );
//       // fallback: 열 수 없다면 앱 설정이라도 열어본다
//       await openAppSettings();
//     }
//   }

//   Future<void> handleStartPressed() async {
//     debugPrint('선택상태: $_selected');

//     final Map<String, bool> consentResult = {};

//     Future<bool> requestPermission(Permission permission) async {
//       final status = await permission.status;
//       if (status.isGranted) return true;

//       final result = await permission.request();
//       if (result.isGranted) return true;

//       if (result.isPermanentlyDenied) {
//         final open = await showDialog<bool>(
//           context: context,
//           builder:
//               (ctx) => AlertDialog(
//                 title: const Text('권한 필요'),
//                 content: const Text('이 권한은 앱의 핵심 기능에 필요합니다. 설정에서 허용하시겠어요?'),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.of(ctx).pop(false),
//                     child: const Text('취소'),
//                   ),
//                   TextButton(
//                     onPressed: () => Navigator.of(ctx).pop(true),
//                     child: const Text('설정 열기'),
//                   ),
//                 ],
//               ),
//         );
//         if (open == true) {
//           await openAppSettings();
//         }
//         return false;
//       }

//       return false;
//     }

//     // 3) 갤러리 권한 요청 (플랫폼별 + Android SDK 분기)
//     if (_selected['gallery'] == true) {
//       bool granted = false;
//       if (Platform.isIOS) {
//         granted = await requestPermission(Permission.photos);
//       } else if (Platform.isAndroid) {
//         final sdk = await _getAndroidSdkInt();
//         debugPrint('Android SDK: $sdk');
//         if (sdk >= 33) {
//           // Android 13+: READ_MEDIA_IMAGES
//           granted = await requestPermission(Permission.photos);
//         } else {
//           // <= Android 12: READ_EXTERNAL_STORAGE
//           granted = await requestPermission(Permission.storage);
//         }
//       } else {
//         granted = true; // 기타 플랫폼
//       }
//       consentResult['gallery'] = granted;
//       if (!granted) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('갤러리 접근 권한이 없어 사진 수집이 제한됩니다.')),
//         );
//       }
//     } else {
//       consentResult['gallery'] = false;
//     }

//     // 4) 알림(푸시) 권한 요청
//     if (_selected['push'] == true) {
//       // 4-1: 일반 푸시 수신 허용 (앱이 알림을 보낼/받을 수 있게 하는 권한)
//       final grantedNotification = await requestPermission(
//         Permission.notification,
//       );
//       consentResult['push'] = grantedNotification;

//       if (!grantedNotification) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('알림 권한이 없어 푸시 정보 수집이 제한됩니다.')),
//         );
//       }

//       // 4-2: "다른 앱의 알림(Notification access)을 읽어 수집" 하려는 경우
//       // 이 기능은 NotificationListenerService + 사용자의 시스템 승인(설정 직접 ON)이 필요합니다.
//       // 앱에서 자동으로 허용받을 수 없으므로 사용자에게 설정 화면을 열도록 안내합니다.
//       final wantReadOtherAppNotifications = await showDialog<bool>(
//         context: context,
//         builder:
//             (ctx) => AlertDialog(
//               title: const Text('알림 접근(선택)'),
//               content: const Text(
//                 '앱이 기기에서 발생하는 다른 앱의 알림을 읽어올 수 있도록 허용하시겠어요?\n'
//                 '이 기능을 켜면 더 많은 자동화(예: 알림 기반 일기 작성)가 가능하지만, 시스템 설정에서 직접 허용해야 합니다.',
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(ctx).pop(false),
//                   child: const Text('아니요'),
//                 ),
//                 TextButton(
//                   onPressed: () => Navigator.of(ctx).pop(true),
//                   child: const Text('설정 열기'),
//                 ),
//               ],
//             ),
//       );

//       if (wantReadOtherAppNotifications == true) {
//         // 네이티브 설정 화면으로 이동시도 (MainActivity에서 MethodChannel 처리 필요)
//         await _openNotificationAccessSettings();

//         // 유저가 설정에서 켰는지 여부는 네이티브에서 콜백/서비스로 확인해야 함.
//         // 여기서는 사용자가 설정을 열었음을 기록해 둠(실제 허용 여부는 나중에 확인 필요).
//         consentResult['notification_listener_requested'] = true;
//       } else {
//         consentResult['notification_listener_requested'] = false;
//       }
//     } else {
//       consentResult['push'] = false;
//       consentResult['notification_listener_requested'] = false;
//     }

//     // 5) 위치 권한 요청
//     if (_selected['location'] == true) {
//       final granted = await requestPermission(Permission.locationWhenInUse);
//       consentResult['location'] = granted;
//       if (!granted) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('위치 권한이 없어 위치 기반 기능이 제한됩니다.')),
//         );
//       }
//     } else {
//       consentResult['location'] = false;
//     }

//     // 6) 사용자 정보 동의
//     consentResult['user'] = _selected['user'] ?? false;

//     // 7) SharedPreferences에 저장
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('consent_push', consentResult['push'] ?? false);
//       await prefs.setBool('consent_gallery', consentResult['gallery'] ?? false);
//       await prefs.setBool(
//         'consent_location',
//         consentResult['location'] ?? false,
//       );
//       await prefs.setBool('consent_user', consentResult['user'] ?? false);
//       // optional: 기록 that we asked for notification listener
//       await prefs.setBool(
//         'notification_listener_requested',
//         consentResult['notification_listener_requested'] ?? false,
//       );
//       await prefs.setBool('hasUserInfo', true);

//       debugPrint('권한 저장 완료: $consentResult');
//     } catch (e) {
//       debugPrint('SharedPreferences 저장 오류: $e');
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('동의 저장 중 오류가 발생했습니다.')));
//       return;
//     }

//     // 8) 홈으로 이동
//     if (!mounted) return;
//     Navigator.of(context).pushAndRemoveUntil(
//       CupertinoPageRoute(builder: (context) => const HomePage()),
//       (Route<dynamic> route) => false,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: IconThemeData(color: textPrimary, size: 28.0),
//         backgroundColor: themePageColor,
//         surfaceTintColor: Colors.transparent,
//         elevation: 0,
//         titleSpacing: 20,
//       ),
//       backgroundColor: themePageColor,
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//         child: SafeArea(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('수집할 항목의 범위를\n변경해주세요', style: pageTitle()),
//               const SizedBox(height: 16),
//               Expanded(
//                 child: Row(
//                   children: [
//                     ConsentCard(
//                       title: '푸쉬 알림',
//                       subtitle: '앱의 알림들을\n수집합니다.',
//                       icon: Icons.notifications_none,
//                       selected: _selected['push'] ?? false,
//                       onTap: () => _toggle('push'),
//                     ),
//                     const SizedBox(width: 12),
//                     ConsentCard(
//                       title: '갤러리',
//                       subtitle: '갤러리 내의 사진을\n수집합니다.',
//                       icon: Icons.image_outlined,
//                       selected: _selected['gallery'] ?? false,
//                       onTap: () => _toggle('gallery'),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Expanded(
//                 child: Row(
//                   children: [
//                     ConsentCard(
//                       title: '위치 정보',
//                       subtitle: 'GPS 정보를\n수집합니다.',
//                       icon: Icons.location_on_outlined,
//                       selected: _selected['location'] ?? false,
//                       onTap: () => _toggle('location'),
//                     ),
//                     const SizedBox(width: 12),
//                     ConsentCard(
//                       title: '사용자 정보',
//                       subtitle: '사용자의 성별과\n나이를 수집합니다.',
//                       icon: Icons.person_outline,
//                       selected: _selected['user'] ?? false,
//                       onTap: () => _toggle('user'),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Center(
//                 child: Text(
//                   '선택 시 민감정보수집 및 활용에 동의하는 것으로 간주됩니다.',
//                   style: TextStyle(color: infoText, fontSize: 14),
//                 ),
//               ),
//               const SizedBox(height: 48),
//               ContainerButton(
//                 borderRadius: BorderRadius.circular(24),
//                 color: themeColor.withAlpha(24),
//                 height: 68,
//                 onTap: () {
//                   debugPrint('선택상태: $_selected');
//                   handleStartPressed();
//                 },
//                 child: Center(
//                   child: Text('변경하기', style: mainButton(color: themeColor)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
