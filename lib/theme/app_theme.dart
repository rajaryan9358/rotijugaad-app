// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:rotijugaad/theme/custom_colors.dart';
import 'extensions.dart'; // <-- important

class Brand {
  // LIGHT PALETTE (YOUR EXACT COLORS)
  static const primary        = Color(0xFF0098DB);
  static const onPrimary      = Colors.white;
  static const secondary      = Color(0xFFF1557C);
  static const onSecondary    = Colors.white;
  static const tertiary       = Color(0xFFE8EDF1);
  static const onTertiary     = Colors.white;

  static const surface        = Color(0xFFFFFFFF);
  static const onSurface      = Color(0xFF3E4E63);
  static const background     = Color(0xFFF6F7F9);
  static const onBackground   = Color(0xFF252A31);

  static const error          = Color(0xFFD21C1C);
  static const onError        = Colors.white;

  // OPTIONAL “container” roles if you use them:
  static const primaryContainer   = Color(0xFFF6F7F9);
  static const onPrimaryContainer = Color(0xFF252A31);
  static const secondaryContainer = Color(0xFFE8EDF1);
  static const onSecondaryContainer = Color(0xFF252A31);
  static const surfaceVariant     = Color(0xFFFFFFFF);
  static const outline            = Color(0xFFE8EDF1);
}

class AppTheme {
  static ThemeData light() {
    final scheme = const ColorScheme(
      brightness: Brightness.light,
      primary: Brand.primary,
      onPrimary: Brand.onPrimary,
      secondary: Brand.secondary,
      onSecondary: Brand.onSecondary,
      tertiary: Brand.tertiary,
      onTertiary: Brand.onTertiary,
      error: Brand.error,
      onError: Brand.onError,
      background: Brand.background,
      onBackground: Brand.onBackground,
      surface: Brand.surface,
      onSurface: Brand.onSurface,

      // Optional roles to keep Material 3 happy:
      primaryContainer: Brand.primaryContainer,
      onPrimaryContainer: Brand.onPrimaryContainer,
      secondaryContainer: Brand.secondaryContainer,
      onSecondaryContainer: Brand.onSecondaryContainer,
      surfaceVariant: Brand.surfaceVariant,
      outline: Brand.outline,
      // You can also set inverseSurface/primaryFixed etc. if you use them.
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.background,
      // Typography (optional)
      // fontFamily: 'Montserrat',

      // ---- Component-level exact styling (centralized) ----
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return scheme.onSurface.withValues(alpha: 0.12);
            }
            return scheme.primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return scheme.onSurface.withValues(alpha: 0.38);
            }
            return scheme.onPrimary;
          }),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(scheme.secondary),
          foregroundColor: WidgetStatePropertyAll(scheme.onSecondary),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStatePropertyAll(BorderSide(color: scheme.primary)),
          foregroundColor: WidgetStatePropertyAll(scheme.primary),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: scheme.surface,
        labelStyle: TextStyle(color: scheme.onSurface.withValues(alpha: .7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: scheme.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: scheme.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: Brand.secondaryContainer,
        selectedColor: Brand.secondary,
        labelStyle: TextStyle(color: scheme.onSecondaryContainer),
        shape: StadiumBorder(side: BorderSide(color: Brand.primary)),
        secondaryLabelStyle: TextStyle(color: scheme.onSecondary),
        side: BorderSide(color: Brand.primary),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),

      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected) ? scheme.primary.withValues(alpha: .45) : scheme.primary.withValues(alpha: .4)),
        thumbColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected) ? scheme.primary : scheme.surface),
      ),

      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 1,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.onSurface,
        contentTextStyle: TextStyle(color: scheme.surface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: scheme.primary,
        selectionHandleColor: scheme.primary,
        selectionColor: scheme.primary.withValues(alpha: .25),
      ),
      extensions: [
        AppSpacing(), // <-- attach
        AppRadii(),   // <-- attach
        CustomColors.light()
      ],
    );
  }

  // If you need DARK too, specify exact dark colors here (no seeding).
  static ThemeData dark() {
    final scheme = const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF7FD494),
      onPrimary: Color(0xFF003919),
      secondary: Color(0xFF7ED3D0),
      onSecondary: Color(0xFF003233),
      tertiary: Color(0xFFCFBEFF),
      onTertiary: Color(0xFF1F0A6B),
      background: Color(0xFF0C1116),
      onBackground: Color(0xFFE6EDF3),
      surface: Color(0xFF0F141A),
      onSurface: Color(0xFFE6EDF3),
      error: Color(0xFFFFB4A9),
      onError: Color(0xFF680003),
      primaryContainer: Color(0xFF0F2A1B),
      onPrimaryContainer: Color(0xFFCFEFDA),
      secondaryContainer: Color(0xFF0E2A2A),
      onSecondaryContainer: Color(0xFFCDEEEE),
      surfaceVariant: Color(0xFF1E252D),
      outline: Color(0xFF8A93A0),
    );
    return light().copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.background,
      inputDecorationTheme: light().inputDecorationTheme.copyWith(
        fillColor: scheme.surface,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      ),
    );
  }
}
