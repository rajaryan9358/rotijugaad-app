// lib/theme/x_icon.dart
import 'package:flutter/material.dart';

import '../../theme/app_icons.dart';

class XIcon extends StatelessWidget {
  final AppIcon icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  const XIcon(
      this.icon, {
        super.key,
        this.size,
        this.color,
        this.semanticLabel,
      });

  @override
  Widget build(BuildContext context) {
    final iconData = AppIcons.solar[icon]!;
    return Icon(iconData, size: size, color: color, semanticLabel: semanticLabel);
  }
}
