import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/employees/providers/employees_provider.dart';
import 'package:rotijugaad/theme/app_icons.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/utils/shared_pref.dart';
import 'package:rotijugaad/verifyidentity/screens/selfie_verification_screen.dart';
import 'package:rotijugaad/common/widgets/app_shimmer_placeholders.dart';
import 'package:rotijugaad/verifyidentity/sheets/verify_aadhar_sheet.dart';
import 'package:rotijugaad/verifyidentity/widgets/identity_item.dart';

import '../../common/dialogs/primary_dialog.dart';
import '../../common/widgets/toolbar.dart';
import '../../profile/dialogs/profile_pending_review_dialog.dart';

class VerifyIdentityScreen extends StatefulWidget {
  final int? employeeId;
  final bool showReviewDialogOnExit;

  const VerifyIdentityScreen({
    super.key,
    this.employeeId,
    this.showReviewDialogOnExit = false,
  });

  @override
  State<StatefulWidget> createState() => _VerifyIdentityScreenState();
}

class _VerifyIdentityScreenState extends State<VerifyIdentityScreen> {
  EmployeesProvider? _employeesProvider;
  int? _employeeId;
  bool _initialLoading = true;
  bool _initialRequestSent = false;

  bool _isAadhaarVerified(EmployeesProvider provider) {
    final emp = provider.employeeDetail ?? provider.personalInfo;
    return (emp?.aadharVerifiedAt ?? '').trim().isNotEmpty;
  }

  bool _isSelfieVerified(EmployeesProvider provider) {
    final emp = provider.employeeDetail ?? provider.personalInfo;
    return (emp?.selfieLink ?? '').trim().isNotEmpty;
  }

  int? _resolveEmployeeIdFromPrefs() {
    final profile = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_PROFILE_JSON);
    final id = profile?['id'] ?? profile?['employeeId'];
    if (id is int) return id;
    return int.tryParse((id ?? '').toString());
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _showFinishValidationDialog({
    required bool isAadharVerified,
    required bool isSelfieVerified,
  }) {
    String message;

    if (!isAadharVerified && !isSelfieVerified) {
      message = 'verify.identity.verify_aadhaar_and_selfie_first'.tr();
    } else if (!isAadharVerified) {
      message = 'verify.identity.verify_aadhaar_first'.tr();
    } else {
      message = 'verify.identity.capture_selfie_first'.tr();
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => PrimaryDialog(
        message,
        title: 'common.unable_to_continue'.tr(),
        showIcon: false,
      ),
    );
  }

  Future<void> _handleFinish({
    required bool isAadharVerified,
    required bool isSelfieVerified,
  }) async {
    if (!isAadharVerified || !isSelfieVerified) {
      await _showFinishValidationDialog(
        isAadharVerified: isAadharVerified,
        isSelfieVerified: isSelfieVerified,
      );
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          PrimaryDialog('verify.identity.kyc_verified_success'.tr()),
    );

    if (!mounted) return;

    if (widget.showReviewDialogOnExit) {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (_) => const ProfilePendingReviewDialog(),
      );
      if (!mounted) return;
    }

    Navigator.of(context).pop();
  }

  Future<void> _handleSkip() async {
    if (widget.showReviewDialogOnExit) {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (_) => const ProfilePendingReviewDialog(),
      );
      if (!mounted) return;
    }
    Navigator.of(context).pop();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _employeesProvider ??= context.read<EmployeesProvider>();
  }

  @override
  void dispose() {
    final id = _employeeId;
    final provider = _employeesProvider;
    if (id != null && provider != null) {
      provider.refreshEmployeeDetail(id);
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _employeeId = widget.employeeId ?? _resolveEmployeeIdFromPrefs();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = _employeeId;
      if (id == null) return;
      _initialRequestSent = true;
      context.read<EmployeesProvider>().refreshEmployeeDetail(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmployeesProvider>(
      builder: (context, provider, _) {
        final emp = provider.employeeDetail ?? provider.personalInfo;
        final kycStatusRaw = (emp?.kycStatus ?? '').trim().toLowerCase();
        final kycStatus = kycStatusRaw.isEmpty ? 'init' : kycStatusRaw;
        final isKycPending = kycStatus == 'pending';
        final showAadhaarVerifyAction = !isKycPending;
        final isAadharVerified = _isAadhaarVerified(provider);
        final isSelfieVerified = _isSelfieVerified(provider);
        if (_initialLoading && _initialRequestSent && !provider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            if (!_initialLoading) return;
            setState(() => _initialLoading = false);
          });
        }

        if (_initialLoading || (provider.isLoading && emp == null)) {
          return Scaffold(
            backgroundColor: context.colors.onPrimary,
            body: SafeArea(
              child: Stack(
                children: [
                  const AppFormShimmer(),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: context.colors.onPrimary,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Toolbar('verify.identity.title'.tr(), () {
                  Navigator.of(context).pop();
                }),
                Divider(color: context.xcolors.stroke),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacing.md,
                    vertical: context.spacing.sm,
                  ),
                  color: context.xcolors.successBackground,
                  child: Text(
                    'verify.identity.employee_note'.tr(),
                    style: context.text.bodyMedium!.copyWith(
                      color: context.xcolors.success,
                    ),
                  ),
                ),
                SizedBox(height: context.spacing.md),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: IdentityItem(
                    key: ValueKey('aadhar-$isAadharVerified'),
                    title: 'verify.identity.verify_aadhaar_title'.tr(),
                    description: isKycPending
                        ? 'profile.verification.kyc_in_review'.tr()
                        : (kycStatus == 'init'
                              ? 'profile.verification.aadhaar_pending'.tr()
                              : 'verify.identity.verify_aadhaar_desc'.tr()),
                    appIcon: AppIcon.verifyAadhar,
                    isVerified: isAadharVerified,
                    showAction: showAadhaarVerifyAction,
                    buttonText: 'common.verify'.tr(),
                    onVerifyClicked: () async {
                      final id = _employeeId;
                      if (id == null) {
                        _snack('verify.identity.unable_find_profile'.tr());
                        return;
                      }

                      final employeesProvider = context
                          .read<EmployeesProvider>();

                      final result = await showModalBottomSheet<Map<String, dynamic>?>(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (context) => VerifyAadharSheet(employeeId: id),
                      );

                      if (!context.mounted) return;

                      if (result?['ok'] != true && result?['message'] != null) {
                        await showDialog<void>(
                          context: context,
                          builder: (ctx) => PrimaryDialog(
                            result!['message'] as String,
                            showIcon: false,
                          ),
                        );
                        return;
                      }

                      if (result?['ok'] == true) {
                        await employeesProvider.refreshEmployeeDetail(id);
                      }
                    },
                  ),
                ),
                SizedBox(height: context.spacing.sm),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: IdentityItem(
                    key: ValueKey('selfie-$isSelfieVerified'),
                    title: 'verify.identity.selfie_title'.tr(),
                    description: 'verify.identity.selfie_desc'.tr(),
                    appIcon: AppIcon.selfiePhoto,
                    isVerified: isSelfieVerified,
                    buttonText: 'common.verify'.tr(),
                    onVerifyClicked: () async {
                      final id = _employeeId;
                      if (id == null) {
                        _snack('verify.identity.unable_find_profile'.tr());
                        return;
                      }

                      final employeesProvider = context
                          .read<EmployeesProvider>();

                      final ok = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SelfieVerificationScreen(employeeId: id),
                        ),
                      );

                      if (ok == true) {
                        await employeesProvider.refreshEmployeeDetail(id);
                      }
                    },
                  ),
                ),
                const Spacer(),
                SizedBox(height: context.spacing.md),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: context.spacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colors.onPrimary,
                            foregroundColor: context.colors.primary,
                            side: BorderSide(color: context.colors.primary),
                            elevation: 0,
                          ),
                          onPressed: _handleSkip,
                          child: Text('common.skip'.tr()),
                        ),
                      ),
                      SizedBox(width: context.spacing.md),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _handleFinish(
                            isAadharVerified: isAadharVerified,
                            isSelfieVerified: isSelfieVerified,
                          ),
                          child: Text('common.finish'.tr()),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.spacing.md),
              ],
            ),
          ),
        );
      },
    );
  }
}
