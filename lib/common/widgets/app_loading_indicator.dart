import 'package:flutter/material.dart';

class AppLoadingIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;
  final double? value;

  const AppLoadingIndicator({
    super.key,
    this.size = 18,
    this.strokeWidth = 2,
    this.color,
    this.value,
  });

  const AppLoadingIndicator.inline({
    super.key,
    this.size = 18,
    this.strokeWidth = 2,
    this.color,
    this.value,
  });

  const AppLoadingIndicator.page({
    super.key,
    this.size = 28,
    this.strokeWidth = 3,
    this.color,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator.adaptive(
        value: value,
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? scheme.primary),
      ),
    );
  }
}
