import 'package:flutter/material.dart';
import 'custom_colors.dart';
import 'extensions.dart';

// Design baseline: 390 × 844 (iPhone 14 Pro)
const double _kDesignWidth = 390.0;

// Clamp keeps small phones from shrinking too aggressively and tablets from
// becoming comically oversized.
const double _kScaleMin = 0.85;
const double _kScaleMax = 1.30;

double _scaleFor(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  return (width / _kDesignWidth).clamp(_kScaleMin, _kScaleMax);
}

AppSpacing _scaledSpacing(double s) => AppSpacing(
      xxs: 2.0 * s,
      xs: 4.0 * s,
      sm: 8.0 * s,
      md: 12.0 * s,
      lg: 16.0 * s,
      xl: 20.0 * s,
      xxl: 24.0 * s,
      xxxl: 32.0 * s,
    );

AppRadii _scaledRadii(double s) => AppRadii(
      sm: 8.0 * s,
      md: 12.0 * s,
      lg: 16.0 * s,
      xl: 24.0 * s,
    );

TextTheme _scaledTextTheme(TextTheme base, double s) {
  TextStyle? sc(TextStyle? style) {
    if (style == null) return null;
    final size = style.fontSize;
    return size == null ? style : style.copyWith(fontSize: size * s);
  }

  return base.copyWith(
    displayLarge: sc(base.displayLarge),
    displayMedium: sc(base.displayMedium),
    displaySmall: sc(base.displaySmall),
    headlineLarge: sc(base.headlineLarge),
    headlineMedium: sc(base.headlineMedium),
    headlineSmall: sc(base.headlineSmall),
    titleLarge: sc(base.titleLarge),
    titleMedium: sc(base.titleMedium),
    titleSmall: sc(base.titleSmall),
    bodyLarge: sc(base.bodyLarge),
    bodyMedium: sc(base.bodyMedium),
    bodySmall: sc(base.bodySmall),
    labelLarge: sc(base.labelLarge),
    labelMedium: sc(base.labelMedium),
    labelSmall: sc(base.labelSmall),
  );
}

/// Drop this into [MaterialApp.builder] to make every theme token
/// (spacing, radii, typography) scale proportionally to the device width
/// relative to the 390 px design baseline.
class ScaledTheme extends StatelessWidget {
  final Widget child;

  const ScaledTheme({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final s = _scaleFor(context);
    final base = Theme.of(context);

    final scaled = base.copyWith(
      textTheme: _scaledTextTheme(base.textTheme, s),
      appBarTheme: base.appBarTheme.copyWith(
        titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
          fontSize: (base.appBarTheme.titleTextStyle?.fontSize ?? 20) * s,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: base.elevatedButtonTheme.style?.copyWith(
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
          ),
        ),
      ),
      extensions: [
        _scaledSpacing(s),
        _scaledRadii(s),
        base.extension<CustomColors>() ?? CustomColors.light(),
      ],
    );

    return Theme(data: scaled, child: child);
  }
}
