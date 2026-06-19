
import 'package:flutter/material.dart';

class Paragraph extends StatelessWidget {
  final String text;
  final TextStyle? style;
  const Paragraph(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style ?? Theme.of(context).textTheme.bodyMedium,
    );
  }
}