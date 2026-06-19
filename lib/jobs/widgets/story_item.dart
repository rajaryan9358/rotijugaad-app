import 'package:flutter/material.dart';
import 'package:rotijugaad/common/widgets/app_loading_indicator.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class StoryItem extends StatelessWidget {
  final String title;
  final String imageUrl;
  final bool isRead;
  final double width;
  final double height;

  const StoryItem({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.isRead,
    this.width = 72,
    this.height = 90,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isRead ? Colors.transparent : context.colors.primary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(context.spacing.sm)),
        border: Border.all(color: borderColor, width: 1.5),
        color: Colors.transparent,
      ),
      padding: EdgeInsets.all(context.spacing.xxs),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(context.spacing.sm)),
        child: Stack(
          children: [
            Opacity(
              opacity: isRead ? 0.55 : 1,
              child: Image.network(
                imageUrl,
                width: width,
                height: height,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: width,
                  height: height,
                  color: context.colors.surfaceContainerHighest,
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    width: width,
                    height: height,
                    color: context.colors.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: AppLoadingIndicator.inline(
                      color: context.colors.primary,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.2),
                padding: EdgeInsets.symmetric(
                  horizontal: context.spacing.xs,
                  vertical: context.spacing.xxs,
                ),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall!.copyWith(
                    color: context.colors.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
