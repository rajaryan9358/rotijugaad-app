import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rotijugaad/jobs/models/job_dto.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/utils/i18n_terms.dart';
import 'package:rotijugaad/utils/job_text_utils.dart';

import '../../common/widgets/icon_text.dart';
import '../../common/widgets/xicon.dart';
import '../../theme/app_icons.dart';

class ApplicationItem extends StatelessWidget {
  final JobDto job;
  final String? status;
  final DateTime? appliedAt;
  final bool isGreyed;

  const ApplicationItem({
    super.key,
    required this.job,
    this.status,
    this.appliedAt,
    this.isGreyed = false,
  });

  static String? _joinLocation(String? city, String? state) {
    final parts = <String>[];
    if (city != null && city.trim().isNotEmpty) parts.add(city.trim());
    if (state != null && state.trim().isNotEmpty) parts.add(state.trim());
    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  static String _salaryText(BuildContext context, JobDto job) {
    final min = job.salaryMin;
    final max = job.salaryMax;
    final unit = (job.salaryType ?? '').trim();

    if (min == null && max == null) {
      return 'common.salary_not_specified'.tr();
    }

    final a = min != null
        ? NumberFormat.decimalPattern('en_IN').format(min)
        : null;
    final b = max != null
        ? NumberFormat.decimalPattern('en_IN').format(max)
        : null;

    final range = [
      a,
      b,
    ].whereType<String>().where((x) => x.trim().isNotEmpty).toList();
    final base = range.isEmpty
        ? 'common.salary_not_specified'.tr()
        : '₹${range.join(' - ')}';

    return unit.isEmpty ? base : '$base/${I18nTerms.fromRaw(context, unit)}';
  }

  static String _statusLabel(BuildContext context, String? raw) {
    final s = (raw ?? '').trim();
    return s.isEmpty
        ? I18nTerms.fromRaw(context, 'active')
        : I18nTerms.fromRaw(context, s);
  }

  static String _formatAppliedAt(BuildContext context, DateTime? appliedAt) {
    if (appliedAt == null) return '-';
    final locale = context.locale.toString();
    return 'common.applied_on'.tr(
      args: [DateFormat('d MMM, y • hh:mm a', locale).format(appliedAt.toLocal())],
    );
  }

  static AppIcon _statusIcon(String? raw) {
    final s = (raw ?? '').trim().toLowerCase();
    switch (s) {
      case 'expired':
        return AppIcon.expired;
      case 'active':
        return AppIcon.activeJob;
      case 'applied':
        return AppIcon.applied;
      case 'shortlisted':
        return AppIcon.shortlisted;
      case 'rejected':
        return AppIcon.rejected;
      case 'hired':
        return AppIcon.hired;
      default:
        return AppIcon.applied;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = job.jobProfile ?? 'Job';
    final org = job.organizationName ?? job.employerName ?? '';
    final location = _joinLocation(job.jobCity, job.jobState) ?? '-';
    final salary = _salaryText(context, job);

    final vacancy = job.noVacancy;
    final vacancyText = vacancy == null
        ? '-'
        : formatVacancyCountText(vacancy, vacanciesLeft: true);

    final hired = job.hiredTotal;
    final hiredText = hired == null
        ? '-'
        : 'common.hired_count'.tr(args: [hired.toString()]);

    final appliedText = _formatAppliedAt(context, appliedAt);

    final statusText = _statusLabel(context, status);
    final icon = _statusIcon(statusText);

    final statusBg = isGreyed
        ? context.colors.onSurface.withOpacity(0.12)
        : context.colors.secondary;

    final statusFg = isGreyed
        ? context.colors.onSurface.withOpacity(0.7)
        : context.colors.onPrimary;

    return Opacity(
      opacity: isGreyed ? 0.55 : 1,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.onPrimary,
          borderRadius: BorderRadius.all(Radius.circular(context.spacing.sm)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: context.spacing.sm,
          vertical: context.spacing.md,
        ),
        margin: EdgeInsets.symmetric(
          vertical: context.spacing.sm,
          horizontal: context.spacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.text.bodyMedium!.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                    if (org.trim().isNotEmpty)
                      Text(
                        org,
                        style: context.text.bodySmall!.copyWith(
                          color: context.colors.secondary,
                        ),
                      ),
                  ],
                ),
                SizedBox(
                  height: context.spacing.xxxl,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing.md,
                      ),
                      backgroundColor: statusBg,
                      disabledBackgroundColor: statusBg,
                      elevation: 0,
                    ),
                    onPressed: null,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        XIcon(icon, color: statusFg),
                        SizedBox(width: context.spacing.xs),
                        Text(
                          statusText,
                          style: context.text.bodySmall!.copyWith(
                            color: statusFg,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.spacing.sm),
            IconText(XIcon(AppIcon.location, size: 16), location),
            SizedBox(height: context.spacing.sm),
            Row(
              children: [
                IconText(XIcon(AppIcon.salary, size: 16), salary),
                SizedBox(width: context.spacing.md),
                IconText(XIcon(AppIcon.vacancy, size: 16), vacancyText),
              ],
            ),
            SizedBox(height: context.spacing.sm),
            Row(
              children: [
                IconText(XIcon(AppIcon.hiredJobs, size: 16), hiredText),
                SizedBox(width: context.spacing.md),
                IconText(XIcon(AppIcon.dateTime, size: 16), appliedText),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
