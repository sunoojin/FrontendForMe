import 'package:flutter/material.dart';
import 'package:smooth_corner/smooth_corner.dart';

class ContainerButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ContainerButton({
    super.key,
    required this.child,
    required this.onTap,
    this.padding,
    this.width,
    this.height,
    this.borderRadius
  });

  @override
  State<ContainerButton> createState() => _ContainerButtonState();
}

class _ContainerButtonState extends State<ContainerButton> {
  // _scale 대신 _isPressed로 상태 관리
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    // _isPressed 상태에 따라 값 결정
    final double scale = _isPressed ? 0.97 : 1.0;
    final Color bgColor =
    _isPressed ? Color(0xFF111111).withAlpha(16) : Colors.transparent;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer( // AnimatedScale + Container -> AnimatedContainer
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack, // 기존 커브 유지

        // 1. Scale 애니메이션
        transform: Matrix4.identity()..scale(scale),
        transformAlignment: Alignment.center,

        // 2. Color 애니메이션
        padding: widget.padding ?? EdgeInsets.symmetric(),
        width: widget.width,
        height: widget.height,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: bgColor,
          shape: SmoothRectangleBorder(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            smoothness: 0.6,
          ),
        ),
        alignment: Alignment.topLeft,
        child: widget.child
      ),
    );
  }
}

Widget bottomButton({required VoidCallback onTap, required Widget child}) {
  return ContainerButton(
    onTap: onTap,
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    child: child,
  );
}