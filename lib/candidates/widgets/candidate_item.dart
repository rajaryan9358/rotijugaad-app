import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rotijugaad/common/widgets/employee_identity_badges.dart';
import 'package:rotijugaad/common/widgets/xicon.dart';
import 'package:rotijugaad/network/api_client.dart';
import 'package:rotijugaad/theme/app_icons.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/utils/i18n_terms.dart';

import '../../common/widgets/icon_text.dart';
import '../models/candidate_summary.dart';

class CandidateItem extends StatelessWidget {
  final CandidateSummaryDto candidate;
  final bool isHindi;
  final VoidCallback? onShortlistTap;
  final bool isShortlistLoading;

  const CandidateItem({
    super.key,
    required this.candidate,
    required this.isHindi,
    this.onShortlistTap,
    this.isShortlistLoading = false,
  });

  String _salaryText(BuildContext context) {
    final salary = candidate.expectedSalary;
    if (salary == null) return '—';

    final formatted = NumberFormat.decimalPattern('en_IN').format(salary);
    final freq = (candidate.expectedSalaryFrequency ?? '').trim().toLowerCase();

    if (freq.isNotEmpty) {
      return '₹$formatted/${I18nTerms.fromRaw(context, freq)}';
    }
    return '₹$formatted';
  }

  String _locationText() {
    final city =
        ((isHindi
                    ? candidate.preferredCityHindi
                    : candidate.preferredCityEnglish) ??
                (isHindi
                    ? candidate.preferredCityEnglish
                    : candidate.preferredCityHindi) ??
                (isHindi ? candidate.cityHindi : candidate.cityEnglish) ??
                (isHindi ? candidate.cityEnglish : candidate.cityHindi) ??
                candidate.preferredCity ??
                candidate.city ??
                '')
            .trim();
    final state =
        ((isHindi
                    ? candidate.preferredStateHindi
                    : candidate.preferredStateEnglish) ??
                (isHindi
                    ? candidate.preferredStateEnglish
                    : candidate.preferredStateHindi) ??
                (isHindi ? candidate.stateHindi : candidate.stateEnglish) ??
                (isHindi ? candidate.stateEnglish : candidate.stateHindi) ??
                candidate.preferredState ??
                candidate.state ??
                '')
            .trim();

    if (city.isNotEmpty && state.isNotEmpty) return '$city, $state';
    if (city.isNotEmpty) return city;
    if (state.isNotEmpty) return state;
    return '—';
  }

  String _jobProfilesText() {
    final profiles = candidate.jobProfiles
        .map((p) {
          final raw =
              ((isHindi ? p.profileHindi : p.profileEnglish).trim()).isNotEmpty
              ? (isHindi ? p.profileHindi : p.profileEnglish).trim()
              : (isHindi ? p.profileEnglish : p.profileHindi).trim();
          return raw;
        })
        .where((s) => s.isNotEmpty)
        .toList();

    if (profiles.isEmpty) return '—';
    return profiles.take(3).join(', ');
  }

  String? _resolveImageUrl(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) return value;
    if (value.startsWith('/')) return '${ApiClient.baseUrl}$value';
    return '${ApiClient.baseUrl}/$value';
  }

  Widget _kycIcon() {
    final status = (candidate.kycStatus ?? '').trim().toLowerCase();
    if (status == 'verified') {
      return const KycVerifiedBadgeIcon(size: 20);
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final name =
        ((isHindi ? candidate.nameHindi : candidate.nameEnglish) ??
                candidate.name ??
                '')
            .trim();
    final safeName = name.isEmpty ? '—' : name;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(context.radii.sm)),
        color: context.colors.onPrimary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.sm,
        vertical: context.spacing.sm,
      ),
      margin: EdgeInsets.symmetric(
        vertical: context.spacing.sm,
        horizontal: context.spacing.md,
      ),
      child: Stack(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(context.radii.sm)),
                child: _resolveImageUrl(candidate.selfieLink) != null
                    ? Image.network(
                        _resolveImageUrl(candidate.selfieLink)!,
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/profile_placeholder.png',
                          width: 80,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        'assets/images/profile_placeholder.png',
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
              ),
              SizedBox(width: context.spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            safeName,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.bodyLarge!.copyWith(
                              color: context.colors.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(width: context.spacing.xs),
                        _kycIcon(),
                        SizedBox(width: context.spacing.xs),
                        EmployeeGenderIcon(
                          gender: candidate.gender,
                          size: 16,
                        ),
                      ],
                    ),
                    SizedBox(height: context.spacing.xs),
                    Text(
                      _jobProfilesText(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyMedium!.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                    SizedBox(height: context.spacing.sm),
                    IconText(XIcon(AppIcon.salary, size: 16), _salaryText(context)),
                    SizedBox(height: context.spacing.sm),
                    IconText(XIcon(AppIcon.location, size: 16), _locationText()),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: isShortlistLoading ? null : onShortlistTap,
              child: isShortlistLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.colors.primary,
                      ),
                    )
                  : XIcon(
                      candidate.isShortlisted
                          ? AppIcon.shortlisted
                          : AppIcon.shortlist,
                      color: candidate.isShortlisted
                          ? context.colors.primary
                          : context.colors.onPrimaryContainer,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
