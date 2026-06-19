import 'package:flutter/material.dart';

import 'app_loading_indicator.dart';

class AppButtonChild extends StatelessWidget {
  final bool isLoading;
  final String label;
  final TextStyle? textStyle;
  final Color? loaderColor;
  final MainAxisAlignment alignment;

  const AppButtonChild({
    super.key,
    required this.isLoading,
    required this.label,
    this.textStyle,
    this.loaderColor,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final style =
        textStyle ??
        Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: scheme.onPrimary);

    final effectiveLoaderColor =
        loaderColor ?? style?.color ?? scheme.onPrimary;

    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: isLoading ? 0 : 1,
          child: Text(label, style: style),
        ),
        if (isLoading) AppLoadingIndicator.inline(color: effectiveLoaderColor),
      ],
    );
  }
}
