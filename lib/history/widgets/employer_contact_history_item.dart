import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../candidatedetail/screens/candidate_detail_screen.dart';
import '../../common/widgets/employee_identity_badges.dart';
import '../../common/widgets/xicon.dart';
import '../../theme/app_icons.dart';
import '../../theme/context_ext.dart';

class EmployerContactHistoryItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const EmployerContactHistoryItem({super.key, required this.item});

  DateTime? _asDate(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v.toString()).toLocal();
    } catch (_) {
      return null;
    }
  }

  String _asLowerStr(dynamic v) => (v ?? '').toString().trim().toLowerCase();

  Widget _kycIcon() {
    final status = _asLowerStr(item['kyc_status']);
    if (status == 'verified') {
      return const KycVerifiedBadgeIcon(size: 20);
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = context.locale.languageCode.toLowerCase() == 'hi';
    final unlockedAt = _asDate(item['contact_unlock_time']);
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

    final mobile = (item['contact'] ?? '').toString().trim();
    final safeMobile = mobile.isEmpty ? '—' : mobile;
    final isDeleted = mobile.isNotEmpty &&
        (mobile.startsWith('-') ||
            (num.tryParse(mobile.replaceAll(RegExp(r'\s'), '')) ?? 0) < 0);
    final genderAsset = employeeGenderIconAsset(item['gender']?.toString());

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
            'history.contact_details'.tr(),
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
          if (!isDeleted) ...[
            SizedBox(height: context.spacing.xs),
            Row(
              children: [
                XIcon(AppIcon.callFilled, color: context.colors.primary),
                SizedBox(width: context.spacing.xs),
                Text(
                  safeMobile,
                  style: context.text.bodySmall!.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
          ],
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
}
