
import 'package:flutter/material.dart';

class StepDotsIndicator extends StatelessWidget {
  final int total;
  final int current;
  final double dot;
  final double spacing;
  final Duration duration;

  const StepDotsIndicator({
    super.key,
    required this.total,
    required this.current,
    this.dot = 10,
    this.spacing = 16,
    this.duration = const Duration(milliseconds: 250),
  }) : assert(total > 0);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final bool isActive = i <= current; // fill up to current
        return AnimatedContainer(
          duration: duration,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          width: dot * (isActive ? 1.2 : 1.0),
          height: dot,
          decoration: BoxDecoration(
            color: isActive ? cs.primary : cs.primary.withOpacity(0.25),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
