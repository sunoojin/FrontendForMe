import 'dart:ui';
import 'package:flutter/material.dart';

PreferredSizeWidget blurryAppBar({required List<Widget> children, required Color color}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(kToolbarHeight),
    child: ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: AppBar(
          backgroundColor: color.withAlpha(160),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 20,
          title: SizedBox(
            width: double.infinity, height: kToolbarHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children
            ),
          ),
        ),
      ),
    ),
  );
}