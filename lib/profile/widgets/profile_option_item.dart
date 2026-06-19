import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rotijugaad/common/widgets/xicon.dart';
import 'package:rotijugaad/theme/app_icons.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class ProfileOptionItem extends StatelessWidget {
  final AppIcon appIcon;
  final String title;
  final VoidCallback onOptionClicked;

  const ProfileOptionItem(
    this.appIcon,
    this.title,
    this.onOptionClicked, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onOptionClicked,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: context.spacing.sm,
          vertical: context.spacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            XIcon(appIcon, color: context.colors.primary),
            SizedBox(width: context.spacing.sm),
            Expanded(child: Text(title, style: context.text.bodyMedium)),
          ],
        ),
      ),
    );
  }
}
