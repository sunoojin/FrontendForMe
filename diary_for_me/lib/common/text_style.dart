import 'package:flutter/material.dart';
import 'colors.dart';

TextStyle pageTitle({
  Color color = textPrimary,
  FontWeight fontWeight = FontWeight.w700,
}) {
  return TextStyle(
    fontSize: 28.0,
    height: 1.2,
    fontWeight: fontWeight,
    color: color
  );
}

TextStyle cardDetail({
  Color color = textSecondary,
  FontWeight fontWeight = FontWeight.w500,
}) {
  return TextStyle(
      fontSize: 16.0,
      height: 1.2,
      fontWeight: fontWeight,
      color: color
  );
}

TextStyle cardTitle({
  Color color = textPrimary,
  FontWeight fontWeight = FontWeight.w700,
}) {
  return TextStyle(
      fontSize: 20.0,
      height: 1.2,
      fontWeight: fontWeight,
      color: color
  );
}

TextStyle contentTitle({
  Color color = textPrimary,
  FontWeight fontWeight = FontWeight.w700,
}) {
  return TextStyle(
      fontSize: 18.0,
      height: 1.2,
      fontWeight: fontWeight,
      color: color
  );
}

TextStyle contentDetail({
  Color color = textTertiary,
  FontWeight fontWeight = FontWeight.w500,
}) {
  return TextStyle(
      fontSize: 14.0,
      height: 1.2,
      fontWeight: fontWeight,
      color: color
  );
}