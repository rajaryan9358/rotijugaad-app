


import 'package:flutter/material.dart';

class Bullet extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  const Bullet(this.text, {super.key, this.textStyle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // dot
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 8),
            child: Container(
              width: 6, height: 6,
              decoration: BoxDecoration(
                color: cs.onSurface,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // text
          Expanded(child: Text(text, style: textStyle ?? Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}