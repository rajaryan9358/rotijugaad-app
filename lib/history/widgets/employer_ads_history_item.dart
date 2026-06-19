import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../common/widgets/icon_text.dart';
import '../../common/widgets/xicon.dart';
import '../../employerjobs/screens/add_job_screen.dart';
import '../../theme/app_icons.dart';
import '../../theme/context_ext.dart';
import '../../utils/i18n_terms.dart';
import '../../utils/job_text_utils.dart';

class EmployerAdsHistoryItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const EmployerAdsHistoryItem({super.key, required this.item});

  String _locationText(bool isHindi) {
    final city =
        ((isHindi ? item['city_hindi'] : item['city_english']) ?? item['city'])
            .toString()
            .trim();
    final state =
        ((isHindi ? item['state_hindi'] : item['state_english']) ??
                item['state'])
            .toString()
            .trim();

    if (city.isNotEmpty && state.isNotEmpty) return '$city, $state';
    if (city.isNotEmpty) return city;
    if (state.isNotEmpty) return state;
    return '—';
  }

  int? _parseSalary(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    final s = (v ?? '').toString().trim();
    if (s.isEmpty) return null;
    return (num.tryParse(s))?.toInt();
  }

  String _salaryText(BuildContext context) {
    final minSalary = _parseSalary(item['salary_min']);
    final maxSalary = _parseSalary(item['salary_max']);

    String fmt(int v) => NumberFormat.decimalPattern('en_IN').format(v);

    final rawFreq = (item['salary_frequency'] ?? '').toString().trim();
    final freq = I18nTerms.fromRaw(context, rawFreq);
    final suffix = freq.isEmpty ? '' : '/$freq';

    if (minSalary == null && maxSalary == null) return '—';
    if (minSalary != null && maxSalary != null && minSalary != maxSalary) {
      return '₹${fmt(minSalary)} - ₹${fmt(maxSalary)}$suffix';
    }

    final s = minSalary ?? maxSalary!;
    return '₹${fmt(s)}$suffix';
  }

  DateTime? _parseTime(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;

    for (final pattern in const ['HH:mm:ss', 'HH:mm']) {
      try {
        return DateFormat(pattern).parseStrict(s);
      } catch (_) {
        // continue
      }
    }
    return null;
  }

  String _shiftText() {
    final timings = item['shift_timing'];
    if (timings is! List || timings.isEmpty) return '—';

    final first = timings.first;
    if (first is! Map) return '—';

    final m = first.cast<String, dynamic>();
    final fromRaw = (m['shift_from'] ?? '').toString();
    final toRaw = (m['shift_to'] ?? '').toString();

    final from = _parseTime(fromRaw);
    final to = _parseTime(toRaw);

    if (from != null && to != null) {
      return '${DateFormat('h:mm a').format(from)} - ${DateFormat('h:mm a').format(to)}';
    }

    final combined = [
      fromRaw.trim(),
      toRaw.trim(),
    ].where((x) => x.isNotEmpty).toList();
    if (combined.isEmpty) return '—';
    return combined.join(' - ');
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = context.locale.languageCode.toLowerCase() == 'hi';

    final title =
        ((isHindi
                    ? item['job_profile_name_hindi']
                    : item['job_profile_name_english']) ??
                item['job_profile_name'])
            .toString()
            .trim();
    final safeTitle = title.isEmpty ? '—' : title;

    final org =
        ((isHindi
                    ? item['employer_organization_name_hindi']
                    : item['employer_organization_name_english']) ??
                item['employer_organization_name'])
            .toString()
            .trim();
    final safeOrg = org.isEmpty ? '—' : org;

    final vacancies = (item['no_vacancy'] ?? '').toString().trim();
    final safeVacancies = vacancies.isEmpty ? '—' : vacancies;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.xcolors.stroke, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(context.radii.sm)),
        color: context.colors.onPrimary,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.sm,
        vertical: context.spacing.sm,
      ),
      margin: EdgeInsets.symmetric(vertical: context.spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            safeTitle,
            style: context.text.bodyLarge!.copyWith(
              fontWeight: FontWeight.w500,
              color: context.colors.primary,
            ),
          ),
          SizedBox(height: context.spacing.sm),
          Text(
            safeOrg,
            style: context.text.bodyMedium!.copyWith(
              color: context.colors.secondary,
            ),
          ),
          SizedBox(height: context.spacing.md),
          Row(
            children: [
              IconText(
                XIcon(AppIcon.location, size: 16),
                _locationText(isHindi),
              ),
              SizedBox(width: context.spacing.md),
              IconText(XIcon(AppIcon.time, size: 16), _shiftText()),
            ],
          ),
          SizedBox(height: context.spacing.sm),
          Row(
            children: [
              IconText(XIcon(AppIcon.salary, size: 16), _salaryText(context)),
              SizedBox(width: context.spacing.md),
              IconText(
                XIcon(AppIcon.vacancy, size: 16),
                safeVacancies == '—'
                    ? '—'
                    : formatVacancyRawText(safeVacancies),
              ),
            ],
          ),
          SizedBox(height: context.spacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final jobId = int.tryParse(
                  (item['job_id'] ?? '').toString(),
                );
                if (jobId == null || jobId <= 0) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddJobScreen(repostJobId: jobId),
                  ),
                );
              },
              child: Text('history.repost_ad'.tr()),
            ),
          ),
        ],
      ),
    );
  }
}
