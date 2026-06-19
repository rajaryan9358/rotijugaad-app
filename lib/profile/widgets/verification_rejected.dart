import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/employees/providers/employees_provider.dart';
import 'package:rotijugaad/employers/providers/employers_provider.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/utils/shared_pref.dart';
import 'package:rotijugaad/verifyidentity/screens/employer_verify_identity_screen.dart';
import 'package:rotijugaad/verifyidentity/screens/verify_identity_screen.dart';

class VerificationRejected extends StatelessWidget {
  const VerificationRejected({super.key});

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  Future<void> _refreshAfterVerify(BuildContext context) async {
    final profile = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_PROFILE_JSON);
    final id = _asInt(
      profile?['id'] ?? profile?['employeeId'] ?? profile?['employerId'],
    );
    if (id == null || id <= 0) return;

    final type = SharedPrefUtils.readStr(
      SharedPrefUtils.USER_TYPE,
    ).trim().toLowerCase();
    if (type == 'employer') {
      await context.read<EmployersProvider>().refreshEmployerDetail(id);
    } else {
      await context.read<EmployeesProvider>().refreshEmployeeDetail(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 3, color: context.xcolors.failure),
        Container(
          color: context.xcolors.failureBackground,
          padding: EdgeInsets.symmetric(
            horizontal: context.spacing.md,
            vertical: context.spacing.md,
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/ic_incomplete.svg',
                color: context.xcolors.failure,
              ),
              SizedBox(width: context.spacing.sm),
              Text(
                'profile.verification.aadhaar_rejected'.tr(),
                style: context.text.bodyMedium!.copyWith(
                  color: context.colors.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.xcolors.failure,
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacing.sm,
                    ),
                  ),
                  onPressed: () async {
                    final type = SharedPrefUtils.readStr(
                      SharedPrefUtils.USER_TYPE,
                    );
                    if (type == 'employee') {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VerifyIdentityScreen(),
                        ),
                      );
                    } else {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmployerVerifyIdentityScreen(),
                        ),
                      );
                    }

                    await _refreshAfterVerify(context);
                  },
                  child: Text(
                    'profile.verification.verify_again'.tr(),
                    style: context.text.bodySmall!.copyWith(
                      color: context.colors.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
