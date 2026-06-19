import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rotijugaad/common/widgets/xicon.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class IconText extends StatelessWidget {
  final XIcon icon;
  final String text;
  final Color? color;

  const IconText(this.icon, this.text, {super.key, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        SizedBox(width: context.spacing.sm),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodySmall!.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
