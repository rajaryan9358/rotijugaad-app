

import 'package:flutter/material.dart';

class SegmentBar extends StatelessWidget {
  final double value;
  final Color activeColor;
  final Color bgColor;
  const SegmentBar({
    required this.value,
    required this.activeColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: 3.5,
        backgroundColor: bgColor,
        color: activeColor,
      ),
    );
  }
}