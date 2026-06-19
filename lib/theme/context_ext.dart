// lib/theme/context_ext.dart
import 'package:flutter/material.dart';
import 'custom_colors.dart';
import 'extensions.dart';

extension XCtx on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get text => theme.textTheme;

  AppSpacing get spacing => theme.extension<AppSpacing>()!;
  AppRadii get radii => theme.extension<AppRadii>()!;
  CustomColors get xcolors =>
      Theme.of(this).extension<CustomColors>() ?? CustomColors.light();
}
