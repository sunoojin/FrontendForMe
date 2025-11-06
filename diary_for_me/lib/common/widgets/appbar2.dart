import 'dart:ui';
import 'package:flutter/material.dart';

/// 페이드 아웃 블러 효과가 적용된 AppBar를 생성하는 함수
PreferredSizeWidget blurryAppBar({
  required List<Widget> children,
  double blurSigma = 10.0,
  Color tintColor = const Color(0x1A000000), // Colors.black.withOpacity(0.1)
}) {
  return AppBar(
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    flexibleSpace: ClipRect(
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,       // 100% 불투명 (블러 보임)
              Colors.transparent, // 100% 투명 (블러 사라짐)
            ],
            stops: const [0.0, 0.8], // 하단 80% 지점에서 투명해짐
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn, // 마스크의 알파값(투명도)을 적용
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            color: tintColor, // 블러 위에 덮일 틴트 색상
          ),
        ),
      ),
    ),
    title: SizedBox(
      width: double.infinity, height: kToolbarHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children
      ),
    ),
  );
}