// lib/widgets/form_label.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class FormLabel extends StatelessWidget {
  final String text;
  final bool optional;
  const FormLabel(this.text, {super.key, this.optional = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Text(
          text,
          style: tt.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.primary,
          ),
        ),
        const Spacer(),
        if (optional)
          Text(
            'common.optional'.tr(),
            style: tt.labelMedium?.copyWith(color: cs.onPrimaryContainer),
          ),
      ],
    );
  }
}
