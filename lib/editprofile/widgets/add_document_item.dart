import 'package:flutter/material.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class AddDocumentItem extends StatelessWidget {
  final String documentName;
  final VoidCallback? onTap;

  const AddDocumentItem(this.documentName, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.all(Radius.circular(context.radii.sm)),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: context.colors.primary, width: 1),
          borderRadius: BorderRadius.all(Radius.circular(context.radii.sm)),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: context.spacing.sm,
          vertical: context.spacing.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                documentName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodyMedium,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.sm,
                vertical: context.spacing.sm,
              ),
              child: Text(
                'Select file',
                style: context.text.bodyMedium!.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
