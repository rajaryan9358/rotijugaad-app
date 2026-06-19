import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:rotijugaad/common/widgets/xicon.dart';
import 'package:rotijugaad/profile/sheets/kyc_verified_sheet.dart';
import 'package:rotijugaad/theme/app_icons.dart';
import 'package:rotijugaad/theme/context_ext.dart';

String? employeeGenderIconAsset(String? gender) {
  final normalized = (gender ?? '').trim().toLowerCase();
  if (normalized == 'male' || normalized == 'm' || normalized == 'man') {
    return 'assets/icons/ic_male.svg';
  }
  if (normalized == 'female' || normalized == 'f' || normalized == 'woman') {
    return 'assets/icons/ic_female.svg';
  }
  return null;
}

class EmployeeGenderIcon extends StatelessWidget {
  final String? gender;
  final double size;
  final Color? color;

  const EmployeeGenderIcon({
    super.key,
    required this.gender,
    this.size = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final asset = employeeGenderIconAsset(gender);
    if (asset == null) return const SizedBox.shrink();

    final normalized = (gender ?? '').trim().toLowerCase();
    final isFemale =
        normalized == 'female' || normalized == 'f' || normalized == 'woman';
    final resolvedColor =
        color ?? (isFemale ? context.colors.secondary : context.colors.primary);

    return SvgPicture.asset(
      asset,
      colorFilter: ColorFilter.mode(resolvedColor, BlendMode.srcIn),
      height: size,
      width: size,
    );
  }
}

class KycVerifiedBadgeIcon extends StatelessWidget {
  final double size;
  final bool isCurrentUser;

  const KycVerifiedBadgeIcon({
    super.key,
    this.size = 20,
    this.isCurrentUser = false,
  });

  Future<void> _openSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => KycVerifiedSheet(isCurrentUser: isCurrentUser),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(size),
      onTap: () => _openSheet(context),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: XIcon(AppIcon.shield, color: context.colors.primary, size: size),
      ),
    );
  }
}
