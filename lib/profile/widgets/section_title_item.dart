


import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final int index;
  final String title;
  const SectionTitle({super.key, required this.index, required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final txt = Theme.of(context).textTheme;
    return Text(
      '$index. $title',
      style: txt.titleSmall?.copyWith(
        color: cs.primary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}