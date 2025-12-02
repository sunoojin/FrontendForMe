import 'db_manager.dart'; // DB 클래스가 있는 파일 경로
import 'background_log/background_log_model.dart'; // ServiceStatus 모델 경로

class ServiceStatusManager {
  static const int _uniqueId = 0;

  // 상태 저장
  Future<void> updateServiceStatus(AppServiceState newState) async {
    final isar = await DB().instance;

    final newStatusObj = ServiceStatus(state: newState);
    // 모델에서 id = 0 으로 초기화되어 있지만, 명시적으로 확실하게 하기 위해 할당 가능
    newStatusObj.id = _uniqueId;

    await isar.writeTxn(() async {
      await isar.serviceStatus.put(newStatusObj);
    });
  }

  // 상태 불러오기
  Future<AppServiceState?> getServiceStatus() async {
    final isar = await DB().instance;

    // ID가 0인 데이터를 조회
    final statusObj = await isar.serviceStatus.get(_uniqueId);

    // 데이터가 존재하면 state 반환
    return statusObj?.state;
  }

  // 상태 변화 감지
  Stream<AppServiceState> watchServiceStatus() async* {
    final isar = await DB().instance;

    // 0번 ID 객체의 변화만 감지
    yield* isar.serviceStatus
        .watchObject(_uniqueId, fireImmediately: true)
        .map((statusObj) => statusObj?.state ?? AppServiceState.waiting);
  }
}