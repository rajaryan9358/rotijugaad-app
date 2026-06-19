import 'package:flutter/material.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class AddedDocumentItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const AddedDocumentItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.all(Radius.circular(context.radii.sm)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(context.radii.sm)),
          border: Border.all(color: context.colors.primary, width: 1),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: context.spacing.xs,
          vertical: context.spacing.xs,
        ),
        child: Row(
          children: [
            Image.asset('assets/images/img_pdf.png', width: 40),
            SizedBox(width: context.spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyMedium!.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: context.spacing.xs),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete, color: context.colors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
