import 'package:flutter/material.dart';

import 'app_shimmer.dart';

class AppListItemShimmer extends StatelessWidget {
  final EdgeInsetsGeometry padding;

  const AppListItemShimmer({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppShimmerBox(width: double.infinity, height: 16),
          SizedBox(height: 10),
          AppShimmerBox(width: 220, height: 12),
          SizedBox(height: 10),
          AppShimmerBox(width: 140, height: 12),
        ],
      ),
    );
  }
}

class AppListShimmer extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry padding;

  const AppListShimmer({
    super.key,
    this.itemCount = 6,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.builder(
        padding: padding,
        itemCount: itemCount,
        itemBuilder: (context, index) => const AppListItemShimmer(),
      ),
    );
  }
}

class AppFormShimmer extends StatelessWidget {
  final EdgeInsetsGeometry padding;

  const AppFormShimmer({super.key, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        padding: padding,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppShimmerBox(width: 180, height: 14),
            SizedBox(height: 10),
            AppShimmerBox(width: double.infinity, height: 48),
            SizedBox(height: 16),
            AppShimmerBox(width: 160, height: 14),
            SizedBox(height: 10),
            AppShimmerBox(width: double.infinity, height: 48),
            SizedBox(height: 16),
            AppShimmerBox(width: 140, height: 14),
            SizedBox(height: 10),
            AppShimmerBox(width: double.infinity, height: 48),
            SizedBox(height: 16),
            AppShimmerBox(width: double.infinity, height: 120),
            SizedBox(height: 24),
            AppShimmerBox(width: double.infinity, height: 48),
          ],
        ),
      ),
    );
  }
}

class AppCandidatesPageShimmer extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final int listItemCount;

  const AppCandidatesPageShimmer({
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.listItemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top header (welcome + name + action icons)
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppShimmerBox(width: 140, height: 12),
                      SizedBox(height: 10),
                      AppShimmerBox(width: 200, height: 16),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const AppShimmerBox(width: 34, height: 34),
                const SizedBox(width: 10),
                const AppShimmerBox(width: 34, height: 34),
              ],
            ),

            const SizedBox(height: 16),

            // Status card area (incomplete/pending/rejected)
            const AppShimmerBox(width: double.infinity, height: 86),

            const SizedBox(height: 16),

            // Stories section (title + horizontal items)
            const AppShimmerBox(width: 120, height: 14),
            const SizedBox(height: 12),
            Row(
              children: const [
                AppShimmerBox(width: 90, height: 90),
                SizedBox(width: 12),
                AppShimmerBox(width: 90, height: 90),
                SizedBox(width: 12),
                AppShimmerBox(width: 90, height: 90),
              ],
            ),

            const SizedBox(height: 20),

            // Salary type radios row
            Row(
              children: const [
                AppShimmerBox(width: 100, height: 20),
                SizedBox(width: 16),
                AppShimmerBox(width: 110, height: 20),
              ],
            ),

            const SizedBox(height: 16),

            // Search + Filter row
            Row(
              children: const [
                Expanded(
                  child: AppShimmerBox(width: double.infinity, height: 48),
                ),
                SizedBox(width: 16),
                AppShimmerBox(width: 92, height: 48),
              ],
            ),

            const SizedBox(height: 14),

            // Tab bar
            Row(
              children: const [
                AppShimmerBox(width: 120, height: 16),
                SizedBox(width: 16),
                AppShimmerBox(width: 150, height: 16),
              ],
            ),

            const SizedBox(height: 16),

            // Candidate list
            for (int i = 0; i < listItemCount; i++)
              AppListItemShimmer(
                padding: EdgeInsets.only(
                  left: 0,
                  right: 0,
                  top: i == 0 ? 0 : 12,
                  bottom: 0,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AppApplicantCardShimmer extends StatelessWidget {
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final bool isReceivedSent;

  const AppApplicantCardShimmer({
    super.key,
    this.margin = const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    this.padding = const EdgeInsets.all(12),
    required this.isReceivedSent,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: scheme.onPrimary,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AppShimmer(
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Employee name + badges area
                        AppShimmerBox(width: 180, height: 16),
                        SizedBox(height: 10),
                        // Employee id
                        AppShimmerBox(width: 90, height: 12),
                      ],
                    ),
                  ),
                  if (!isReceivedSent) ...const [
                    SizedBox(width: 12),
                    // Status pill/button
                    AppShimmerBox(
                      width: 120,
                      height: 44,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              if (isReceivedSent) ...[
                const AppShimmerBox(width: 240, height: 12),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AppShimmerBox(
                              width: double.infinity,
                              height: 16,
                            ),
                          ),
                          SizedBox(width: 12),
                          AppShimmerBox(
                            width: 110,
                            height: 36,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      AppShimmerBox(width: 200, height: 12),
                      SizedBox(height: 12),
                      AppShimmerBox(width: 220, height: 12),
                      SizedBox(height: 12),
                      AppShimmerBox(width: 200, height: 12),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: AppShimmerBox(
                              width: double.infinity,
                              height: 12,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: AppShimmerBox(
                              width: double.infinity,
                              height: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else ...const [
                AppShimmerBox(width: 180, height: 12),
                SizedBox(height: 12),
                AppShimmerBox(width: 220, height: 12),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: AppShimmerBox(width: double.infinity, height: 12),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AppShimmerBox(width: double.infinity, height: 12),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AppApplicantsListShimmer extends StatelessWidget {
  final String filter;
  final int itemCount;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry cardMargin;
  final EdgeInsetsGeometry cardPadding;

  const AppApplicantsListShimmer({
    super.key,
    required this.filter,
    this.itemCount = 6,
    this.padding = EdgeInsets.zero,
    this.cardMargin = const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    this.cardPadding = const EdgeInsets.all(12),
  });

  bool get _isReceivedSent {
    return filter == 'Received Interests' || filter == 'Sent Interests';
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return AppApplicantCardShimmer(
          isReceivedSent: _isReceivedSent,
          margin: cardMargin,
          padding: cardPadding,
        );
      },
    );
  }
}
