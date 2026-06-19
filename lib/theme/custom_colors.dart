// lib/theme/custom_colors.dart
import 'package:flutter/material.dart';

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  final Color successBackground;
  final Color success;
  final Color onSuccess;

  // Hired status badge
  final Color hiredStatusBackground;
  final Color hiredStatusStroke;
  final Color hiredStatusForeground;

  final Color failureBackground;
  final Color failure;
  final Color onFailure;

  final Color warningBackground;
  final Color warning;
  final Color onWarning;
  final Color infoBackground;
  final Color info;
  final Color onInfo;

  // Optional: extra accents / gradients
  final Color brandAlt;
  final Color gradientStart;
  final Color gradientEnd;

  final Color stroke;

  const CustomColors({
    required this.failureBackground,
    required this.failure,
    required this.onFailure,
    required this.successBackground,
    required this.success,
    required this.onSuccess,
    required this.hiredStatusBackground,
    required this.hiredStatusStroke,
    required this.hiredStatusForeground,
    required this.warningBackground,
    required this.warning,
    required this.onWarning,
    required this.infoBackground,
    required this.info,
    required this.onInfo,
    required this.brandAlt,
    required this.gradientStart,
    required this.gradientEnd,
    required this.stroke,
  });

  // Light palette
  factory CustomColors.light() => const CustomColors(
    successBackground: Color(0xFFDFFFE6),
    success: Color(0xFF1E7B33),
    onSuccess: Colors.white,
    hiredStatusBackground: Color(0xFFE1EFF2),
    hiredStatusStroke: Color(0xFFCDE4CF),
    hiredStatusForeground: Color(0xFF276831),
    failureBackground: Color(0xFFF8E2E2),
    failure: Color(0xFFD21C1C),
    onFailure: Colors.white,
    warningBackground: Color(0xFFFCECDA),
    warning: Color(0xFFDF7B00),
    onWarning: Color(0xFF252A31),
    infoBackground: Color(0xFFC0E9FD),
    info: Color(0xFF0098DB),
    onInfo: Colors.white,
    brandAlt: Color(0xFF7148D2),
    gradientStart: Color(0xFFE8F4FD),
    gradientEnd: Color(0xFF42908E),
    stroke: Color(0xFFBAC7D5),
  );

  // Dark palette (contrasts flipped/adjusted)
  factory CustomColors.dark() => const CustomColors(
    successBackground: Color(0xFFDFFFE6),
    success: Color(0xFF1E7B33),
    onSuccess: Colors.white,
    hiredStatusBackground: Color(0xFFE1EFF2),
    hiredStatusStroke: Color(0xFFCDE4CF),
    hiredStatusForeground: Color(0xFF276831),
    failureBackground: Color(0xFFF8E2E2),
    failure: Color(0xFFD21C1C),
    onFailure: Colors.white,
    warningBackground: Color(0xFFFCECDA),
    warning: Color(0xFFDF7B00),
    onWarning: Color(0xFF252A31),
    infoBackground: Color(0xFFC0E9FD),
    info: Color(0xFF0098DB),
    onInfo: Colors.white,
    brandAlt: Color(0xFF7148D2),
    gradientStart: Color(0xFFE8F4FD),
    gradientEnd: Color(0xFF42908E),
    stroke: Color(0xFFBAC7D5),
  );

  @override
  CustomColors copyWith({
    Color? successBackground,
    Color? success,
    Color? onSuccess,
    Color? hiredStatusBackground,
    Color? hiredStatusStroke,
    Color? hiredStatusForeground,
    Color? failureBackground,
    Color? failure,
    Color? onFailure,
    Color? warningBackground,
    Color? warning,
    Color? onWarning,
    Color? infoBackground,
    Color? info,
    Color? onInfo,
    Color? brandAlt,
    Color? gradientStart,
    Color? gradientEnd,
    Color? stroke,
  }) => CustomColors(
    successBackground: successBackground ?? this.successBackground,
    success: success ?? this.success,
    onSuccess: onSuccess ?? this.onSuccess,
    hiredStatusBackground: hiredStatusBackground ?? this.hiredStatusBackground,
    hiredStatusStroke: hiredStatusStroke ?? this.hiredStatusStroke,
    hiredStatusForeground: hiredStatusForeground ?? this.hiredStatusForeground,
    failureBackground: failureBackground ?? this.failureBackground,
    failure: failure ?? this.failure,
    onFailure: onFailure ?? this.onFailure,
    warningBackground: warningBackground ?? this.warningBackground,
    warning: warning ?? this.warning,
    onWarning: onWarning ?? this.onWarning,
    infoBackground: infoBackground ?? this.infoBackground,
    info: info ?? this.info,
    onInfo: onInfo ?? this.onInfo,
    brandAlt: brandAlt ?? this.brandAlt,
    gradientStart: gradientStart ?? this.gradientStart,
    gradientEnd: gradientEnd ?? this.gradientEnd,
    stroke: stroke ?? this.stroke,
  );

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return CustomColors(
      successBackground: l(successBackground, other.successBackground),
      success: l(success, other.success),
      onSuccess: l(onSuccess, other.onSuccess),
      hiredStatusBackground: l(
        hiredStatusBackground,
        other.hiredStatusBackground,
      ),
      hiredStatusStroke: l(hiredStatusStroke, other.hiredStatusStroke),
      hiredStatusForeground: l(
        hiredStatusForeground,
        other.hiredStatusForeground,
      ),
      failureBackground: l(failureBackground, other.failureBackground),
      failure: l(failure, other.failure),
      onFailure: l(onFailure, other.onFailure),
      warningBackground: l(warningBackground, other.warningBackground),
      warning: l(warning, other.warning),
      onWarning: l(onWarning, other.onWarning),
      infoBackground: l(infoBackground, other.infoBackground),
      info: l(info, other.info),
      onInfo: l(onInfo, other.onInfo),
      brandAlt: l(brandAlt, other.brandAlt),
      gradientStart: l(gradientStart, other.gradientStart),
      gradientEnd: l(gradientEnd, other.gradientEnd),
      stroke: l(stroke, other.stroke),
    );
  }
}
