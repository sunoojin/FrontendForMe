import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

// 작성하신 모델 파일들의 g.dart가 포함된 파일들 import
import 'background_log/background_log_model.dart';
import 'diary/diary_model.dart';
import 'timeline/timeline_model.dart';
// daily_data_model.dart는 embedded만 있으므로 스키마 등록 불필요하지만,
// 만약 의존성 때문에 필요하다면 import 하세요.

class DB {
  // 1. 싱글톤 패턴 (앱 전체에서 공유)
  static final DB _instance = DB._internal();
  factory DB() => _instance;
  DB._internal();

  Isar? _isar;

  // 2. 외부에서 호출할 Getter
  Future<Isar> get instance async {
    // 이미 열려있다면 바로 반환
    if (_isar != null && _isar!.isOpen) {
      return _isar!;
    }

    // 닫혀있거나 처음이라면 오픈
    _isar = await _openIsar();
    return _isar!;
  }

  // 3. 실제 오픈 로직 (설정 집중 관리)
  Future<Isar> _openIsar() async {
    final dir = await getApplicationDocumentsDirectory();

    // Isar 인스턴스가 이미 존재하는지 확인 (멀티 아이솔레이트 환경 대비)
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [
          // [중요] @collection 어노테이션이 붙은 클래스의 Schema만 넣습니다.
          // (@embedded 클래스는 넣지 않아도 됩니다)
          LocationLogSchema,      // from background_log_model
          AppNotificationLogSchema, // from background_log_model
          ServiceStatusSchema,
          DiarySchema,            // from diary_model
          TagSchema,              // from diary_model
          TimeLineSchema,         // from timeline_model
        ],
        directory: dir.path,
        name: 'diary_db', // DB 이름
        inspector: true,  // 디버그 모드에서 Isar Inspector 사용 가능
      );
    }

    // 이미 열려있는 인스턴스 가져오기
    return Isar.getInstance('diary_db')!;
  }
}