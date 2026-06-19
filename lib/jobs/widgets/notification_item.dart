import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class NotificationItem extends StatelessWidget {
  final String title;
  final String description;
  final String dateLabel;
  final VoidCallback? onTap;
  final bool isActionable;
  final bool isRead;

  const NotificationItem({
    super.key,
    required this.title,
    required this.description,
    required this.dateLabel,
    this.onTap,
    this.isActionable = false,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.spacing.md,
            vertical: context.spacing.xs,
          ),
          decoration: BoxDecoration(
            color: isRead
                ? Colors.transparent
                : context.colors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.all(Radius.circular(context.radii.sm)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: context.text.bodyMedium!.copyWith(
                        fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isRead ? Icons.done_rounded : Icons.circle,
                        size: isRead ? 14 : 10,
                        color: isRead
                            ? context.colors.onSurface.withValues(alpha: 0.55)
                            : context.colors.primary,
                      ),
                      SizedBox(width: context.spacing.xs),
                      Text(
                        dateLabel,
                        style: context.text.bodySmall!.copyWith(
                          color: context.colors.onSurface,
                        ),
                      ),
                      if (isActionable) ...[
                        SizedBox(width: context.spacing.xs),
                        Icon(
                          CupertinoIcons.chevron_right,
                          size: 14,
                          color: context.colors.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              SizedBox(height: context.spacing.xs),
              Text(
                description,
                style: context.text.bodyMedium!.copyWith(
                  color: context.colors.onSurface.withValues(
                    alpha: isRead ? 0.8 : 1,
                  ),
                ),
              ),
              SizedBox(height: context.spacing.sm),
              Divider(color: context.colors.onSurface.withValues(alpha: 0.18)),
            ],
          ),
        ),
      ),
    );
  }
}
