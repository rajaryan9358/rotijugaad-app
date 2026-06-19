import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../candidatedetail/screens/candidate_detail_screen.dart';
import '../../common/widgets/employee_identity_badges.dart';
import '../../common/widgets/icon_text.dart';
import '../../common/widgets/xicon.dart';
import '../../theme/app_icons.dart';
import '../../theme/context_ext.dart';
import '../../utils/i18n_terms.dart';

class EmployerInterestHistoryItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const EmployerInterestHistoryItem({super.key, required this.item});

  String _asLowerStr(dynamic v) => (v ?? '').toString().trim().toLowerCase();

  DateTime? _asDate(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v.toString()).toLocal();
    } catch (_) {
      return null;
    }
  }

  Widget _kycIcon() {
    final status = _asLowerStr(item['kyc_status']);
    if (status == 'verified') {
      return const KycVerifiedBadgeIcon(size: 20);
    }
    return const SizedBox.shrink();
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

  @override
  Widget build(BuildContext context) {
    final isHindi = context.locale.languageCode.toLowerCase() == 'hi';
    final unlockedAt = _asDate(item['interest_unlocked_time']);
    final unlockedText = unlockedAt == null
        ? 'history.unlocked_on'.tr(args: ['—'])
        : 'history.unlocked_on'.tr(
            args: [DateFormat('hh:mm a, d MMM y').format(unlockedAt)],
          );

    final name =
        ((isHindi
                    ? item['employee_name_hindi']
                    : item['employee_name_english']) ??
                item['employee_name'] ??
                '')
            .toString()
            .trim();
    final safeName = name.isEmpty ? '—' : name;
    final genderAsset = employeeGenderIconAsset(item['gender']?.toString());
    final rawContact = (item['contact'] ?? '').toString().trim();
    final isDeleted = rawContact.isNotEmpty &&
        (rawContact.startsWith('-') ||
            (num.tryParse(rawContact.replaceAll(RegExp(r'\s'), '')) ?? 0) < 0);

    final profiles = _jobProfilesFrom(item, isHindi).take(3).toList();

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
            'history.interest_details'.tr(),
            style: context.text.bodyMedium!.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: context.spacing.sm),
          Text(unlockedText, style: context.text.bodySmall),
          SizedBox(height: context.spacing.md),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  safeName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: context.text.bodyMedium!.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: context.spacing.xs),
              _kycIcon(),
              if (genderAsset != null) ...[
                SizedBox(width: context.spacing.xs),
                EmployeeGenderIcon(gender: item['gender']?.toString()),
              ],
            ],
          ),
          SizedBox(height: context.spacing.sm),
          Row(
            children: [
              IconText(XIcon(AppIcon.salary, size: 16), _salaryText(context)),
              SizedBox(width: context.spacing.md),
              IconText(
                XIcon(AppIcon.location, size: 16),
                _locationText(isHindi),
              ),
            ],
          ),
          SizedBox(height: context.spacing.sm),
          if (profiles.isNotEmpty)
            Wrap(
              spacing: context.spacing.md,
              runSpacing: context.spacing.xs,
              children: [
                for (final p in profiles)
                  IconText(XIcon(AppIcon.jobType, size: 16), p),
              ],
            )
          else
            IconText(XIcon(AppIcon.jobType, size: 16), '—'),
          SizedBox(height: context.spacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isDeleted
                  ? null
                  : () {
                      final candidateId = int.tryParse(
                        (item['employee_id'] ?? '').toString(),
                      );
                      if (candidateId == null || candidateId <= 0) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CandidateDetailScreen(candidateId: candidateId),
                        ),
                      );
                    },
              child: Text('history.view_profile'.tr()),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _jobProfilesFrom(Map<String, dynamic> source, bool isHindi) {
    final profiles = source['employee_job_profiles'];
    if (profiles is! List) return const [];

    return profiles
        .whereType<Map>()
        .map((m) {
          final map = m.cast<String, dynamic>();
          final raw =
              (isHindi
                      ? map['profile_hindi'] ?? map['profileHindi']
                      : map['profile_english'] ?? map['profileEnglish'])
                  .toString()
                  .trim();
          return raw;
        })
        .where((s) => s.isNotEmpty)
        .toList();
  }
}
