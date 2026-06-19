

// lib/theme/extensions.dart
import 'package:flutter/material.dart';
import 'tokens.dart';

@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  final double xxs; // 2
  final double xs;  // 4
  final double sm;  // 8
  final double md;  // 12
  final double lg;  // 16
  final double xl;  // 20
  final double xxl; // 24
  final double xxxl; // 32

  const AppSpacing({
    this.xxs  = Tokens.space2,
    this.xs   = Tokens.space4,
    this.sm   = Tokens.space8,
    this.md   = Tokens.space12,
    this.lg   = Tokens.space16,
    this.xl   = Tokens.space20,
    this.xxl  = Tokens.space24,
    this.xxxl = Tokens.space32,
  });

  @override
  AppSpacing copyWith({
    double? xxs,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? xxxl,
  }) {
    return AppSpacing(
      xxs:  xxs  ?? this.xxs,
      xs:   xs   ?? this.xs,
      sm:   sm   ?? this.sm,
      md:   md   ?? this.md,
      lg:   lg   ?? this.lg,
      xl:   xl   ?? this.xl,
      xxl:  xxl  ?? this.xxl,
      xxxl: xxxl ?? this.xxxl,
    );
  }

  @override
  AppSpacing lerp(ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) return this;
    return AppSpacing(
      xxs:  lerpDouble(xxs,  other.xxs,  t)!,
      xs:   lerpDouble(xs,   other.xs,   t)!,
      sm:   lerpDouble(sm,   other.sm,   t)!,
      md:   lerpDouble(md,   other.md,   t)!,
      lg:   lerpDouble(lg,   other.lg,   t)!,
      xl:   lerpDouble(xl,   other.xl,   t)!,
      xxl:  lerpDouble(xxl,  other.xxl,  t)!,
      xxxl: lerpDouble(xxxl, other.xxxl, t)!,
    );
  }
}


@immutable
class AppRadii extends ThemeExtension<AppRadii> {
  final double sm;   // 8
  final double md;   // 12
  final double lg;   // 16
  final double xl;   // 24

  const AppRadii({
    this.sm = Tokens.radius8,
    this.md = Tokens.radius12,
    this.lg = Tokens.radius16,
    this.xl = Tokens.radius24,
  });

  @override
  AppRadii copyWith({
    double? sm,
    double? md,
    double? lg,
    double? xl,
  }) {
    return AppRadii(
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
    );
  }

  @override
  AppRadii lerp(ThemeExtension<AppRadii>? other, double t) {
    if (other is! AppRadii) return this;
    return AppRadii(
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
    );
  }
}
double? lerpDouble(double a, double b, double t) => a + (b - a) * t;
