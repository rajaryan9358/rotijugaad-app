// lib/common/widgets/segment_indicator.dart
import 'package:flutter/material.dart';

class SegmentIndicator extends StatelessWidget {
  final int total;        // >= 2
  final int current;      // 0-based
  final double circle;    // dot diameter
  final double lineH;     // connector height
  final double gap;       // visual spacing between dots
  final Color? base;      // base = ColorScheme.primary

  const SegmentIndicator({
    super.key,
    required this.total,
    required this.current,
    this.circle = 24,
    this.lineH = 6,
    this.gap = 56,
    this.base,
  }) : assert(total >= 2);

  @override
  Widget build(BuildContext context) {
    final primary = base ?? Theme.of(context).colorScheme.primary;

    // tones
    final cDoneDot   = primary;                 // darkest
    final cDoneLine  = primary.withOpacity(.65);
    final cFutureDot = primary.withOpacity(.30);
    final cFutureLine= primary.withOpacity(.18);

    final idx = current.clamp(0, total - 1);

    return LayoutBuilder(
      builder: (context, cons) {
        // Track length: dots spread by `gap`, centered horizontally
        final trackLen = (total - 1) * gap;
        final neededWidth = trackLen + circle; // left half + segments + right half
        final width = cons.maxWidth;
        final startX = (width - neededWidth) / 2 + circle / 2; // center the indicator
        final endX   = startX + trackLen;

        // progress X to end of current step
        final progressX = idx == 0 ? startX : startX + (trackLen * (idx / (total - 1)));

        return SizedBox(
          height: circle,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              // --- background (future) line ---
              Positioned(
                left: startX,
                right: width - endX,
                top: (circle - lineH) / 2,
                child: _Line(color: cFutureLine, height: lineH),
              ),
              // --- filled (done) line up to current ---
              Positioned(
                left: startX,
                width: (progressX - startX).clamp(0, trackLen),
                top: (circle - lineH) / 2,
                child: _Line(color: cDoneLine, height: lineH),
              ),
              // --- dots ---
              ...List.generate(total, (i) {
                final x = startX + gap * i - circle / 2;
                final isDone = i <= idx;                // current and previous
                final dotColor = isDone ? cDoneDot : cFutureDot;
                return Positioned(
                  left: x,
                  top: 0,
                  child: Container(
                    width: circle,
                    height: circle,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _Line extends StatelessWidget {
  final Color color;
  final double height;
  const _Line({required this.color, required this.height});

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(999),
    ),
  );
}
