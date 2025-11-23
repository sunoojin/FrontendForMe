import 'dart:math';

String getRandomGreeting() {
  final hour = DateTime.now().hour;
  final random = Random();

  List<String> greetings;

  if (hour >= 5 && hour < 12) {
    // 아침 (05:00 ~ 11:59)
    greetings = [
      '좋은 아침이에요 ☀️',
      '아침 식사는 챙기셨나요? 🥪',
    ];
  } else if (hour >= 12 && hour < 17) {
    // 오후 (12:00 ~ 17:59)
    greetings = [
      '맛있는 점심 드셨나요? 🍱',
      '오후도 힘차게 파이팅! 💪',
      '잠시 하늘을 보며 쉬어가도 좋아요 ️',
    ];
  } else if (hour >= 17 && hour < 22) {
    // 저녁 (18:00 ~ 21:59)
    greetings = [
      '오늘 하루 수고 많았어요 👏',
      '하루를 마무리할 시간이에요 🌙',
      '행복한 저녁 시간 되세요!',
    ];
  } else {
    // 밤/새벽 (22:00 ~ 04:59)
    greetings = [
      '오늘 밤도 평안하시길 🌟',
      '좋은 꿈 꾸세요 💤',
      '내일은 더 빛날 거예요 ✨',
      '감성 충만한 새벽이네요',
    ];
  }

  // 해당 리스트에서 랜덤으로 하나 뽑기
  return greetings[random.nextInt(greetings.length)];
}