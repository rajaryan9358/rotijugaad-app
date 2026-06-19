import 'package:flutter/material.dart';

import 'package:rotijugaad/common/widgets/app_shimmer.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class JobDetailsShimmer extends StatelessWidget {
  const JobDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.md),
            child: AppShimmer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: spacing.md),
                  Row(
                    children: const [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppShimmerBox(height: 18, width: 180),
                            SizedBox(height: 4),
                            AppShimmerBox(height: 14, width: 220),
                          ],
                        ),
                      ),
                      AppShimmerBox(
                        height: 48,
                        width: 48,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing.xl),
                  const AppShimmerBox(height: 14, width: 220),
                  SizedBox(height: spacing.sm),
                  const AppShimmerBox(height: 14, width: 260),
                  SizedBox(height: spacing.sm),
                  const AppShimmerBox(height: 14, width: 200),
                  SizedBox(height: spacing.lg),
                  const AppShimmerBox(height: 16, width: 200),
                  SizedBox(height: spacing.sm),
                  const AppShimmerBox(
                    height: 90,
                    width: double.infinity,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  SizedBox(height: spacing.lg),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: scheme.onPrimary,
            padding: EdgeInsets.symmetric(
              horizontal: spacing.md,
              vertical: spacing.md,
            ),
            child: AppShimmer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppShimmerBox(height: 16, width: 200),
                  SizedBox(height: spacing.sm),
                  Wrap(
                    spacing: spacing.sm,
                    runSpacing: spacing.sm,
                    children: const [
                      _ChipBox(width: 140),
                      _ChipBox(width: 110),
                      _ChipBox(width: 90),
                      _ChipBox(width: 120),
                    ],
                  ),
                  SizedBox(height: spacing.lg),
                  const AppShimmerBox(height: 16, width: 160),
                  SizedBox(height: spacing.sm),
                  Wrap(
                    spacing: spacing.sm,
                    runSpacing: spacing.sm,
                    children: const [
                      _ChipBox(width: 120),
                      _ChipBox(width: 110),
                      _ChipBox(width: 80),
                    ],
                  ),
                  SizedBox(height: spacing.lg),
                  const AppShimmerBox(height: 16, width: 120),
                  SizedBox(height: spacing.sm),
                  Wrap(
                    spacing: spacing.sm,
                    runSpacing: spacing.sm,
                    children: const [
                      _ChipBox(width: 130),
                      _ChipBox(width: 170),
                    ],
                  ),
                  SizedBox(height: spacing.xxxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipBox extends StatelessWidget {
  final double width;
  const _ChipBox({required this.width});

  @override
  Widget build(BuildContext context) {
    return AppShimmerBox(
      height: 28,
      width: width,
      borderRadius: BorderRadius.all(Radius.circular(999)),
    );
  }
}
