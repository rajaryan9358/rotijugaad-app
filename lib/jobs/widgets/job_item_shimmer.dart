import 'package:flutter/material.dart';

import 'package:rotijugaad/common/widgets/app_shimmer.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class JobItemShimmer extends StatelessWidget {
  final double? horizontalPadding;

  const JobItemShimmer({super.key, this.horizontalPadding});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: spacing.xs,
        horizontal: horizontalPadding ?? spacing.sm,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.onPrimary,
          borderRadius: BorderRadius.all(Radius.circular(context.radii.sm)),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.sm,
          vertical: spacing.md,
        ),
        child: AppShimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppShimmerBox(height: 16, width: 160),
                        SizedBox(height: 4),
                        AppShimmerBox(height: 14, width: 220),
                      ],
                    ),
                  ),
                  AppShimmerBox(
                    height: 28,
                    width: 28,
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                ],
              ),
              SizedBox(height: spacing.sm),
              Row(
                children: const [
                  AppShimmerBox(height: 14, width: 140),
                  SizedBox(width: 12),
                  AppShimmerBox(height: 14, width: 90),
                ],
              ),
              SizedBox(height: spacing.sm),
              Row(
                children: const [
                  AppShimmerBox(height: 14, width: 170),
                  SizedBox(width: 12),
                  AppShimmerBox(height: 14, width: 100),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
