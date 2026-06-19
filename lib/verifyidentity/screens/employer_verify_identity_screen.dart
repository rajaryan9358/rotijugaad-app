import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/common/dialogs/primary_dialog.dart';
import 'package:rotijugaad/employers/providers/employers_provider.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/utils/shared_pref.dart';

import '../../common/widgets/toolbar.dart';
import '../../theme/app_icons.dart';
import '../sheets/employer_verify_aadhar_sheet.dart';
import '../widgets/identity_item.dart';

class EmployerVerifyIdentityScreen extends StatefulWidget {
  final bool goToAddJobOnExit;

  const EmployerVerifyIdentityScreen({
    super.key,
    this.goToAddJobOnExit = false,
  });

  @override
  State<StatefulWidget> createState() => _EmployerVerifyIdentityScreenState();
}

class _EmployerVerifyIdentityScreenState
    extends State<EmployerVerifyIdentityScreen> {
  int? _employerId;

  String _kycStatus(Map<String, dynamic>? employer) {
    final raw =
        employer?['kyc_status'] ??
        employer?['verification_status'] ??
        employer?['kycStatus'] ??
        '';
    final s = raw.toString().trim().toLowerCase();
    return s.isEmpty ? 'init' : s;
  }

  @override
  void initState() {
    super.initState();
    _loadEmployerIdAndRefresh();
  }

  Future<void> _loadEmployerIdAndRefresh() async {
    final id = SharedPrefUtils.readInt('auth_employer_id');
    if (!mounted) return;

    setState(() {
      _employerId = id > 0 ? id : null;
    });

    if (_employerId != null) {
      await context.read<EmployersProvider>().refreshEmployerDetail(
        _employerId!,
      );
    }
  }

  Map<String, dynamic>? _currentEmployer(EmployersProvider provider) {
    return provider.employerDetail ??
        SharedPrefUtils.readJson(SharedPrefUtils.AUTH_PROFILE_JSON);
  }

  bool _isAadhaarVerified(Map<String, dynamic>? employer) {
    final v = employer?['aadhar_verified_at'];
    if (v == null) return false;
    final s = v.toString().trim();
    return s.isNotEmpty && s.toLowerCase() != 'null';
  }

  bool _isDocumentUploaded(Map<String, dynamic>? employer) {
    final v = employer?['document_link'];
    if (v == null) return false;
    final s = v.toString().trim();
    return s.isNotEmpty && s.toLowerCase() != 'null';
  }

  Future<void> _verifyAadhaar() async {
    final employerId = _employerId;
    if (employerId == null) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => PrimaryDialog(
          'verify.identity.complete_profile_first'.tr(),
          showIcon: false,
        ),
      );
      return;
    }

    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EmployerVerifyAadharSheet(employerId: employerId),
    );

    if (!mounted) return;

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
      await context.read<EmployersProvider>().refreshEmployerDetail(employerId);
    }
  }

  Future<void> _uploadDocument() async {
    final employerId = _employerId;
    if (employerId == null) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => PrimaryDialog(
          'verify.identity.complete_profile_first'.tr(),
          showIcon: false,
        ),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: false,
    );

    if (!mounted) return;

    final path = result?.files.single.path;
    if (path == null || path.trim().isEmpty) return;

    final ok = await context.read<EmployersProvider>().uploadEmployerDocument(
      employerId: employerId,
      file: File(path),
    );

    if (!mounted) return;

    if (!ok) {
      final msg =
          context.read<EmployersProvider>().lastError?.message ??
          'verify.identity.failed_document_upload'.tr();
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => PrimaryDialog(msg, showIcon: false),
      );
      return;
    }

    await context.read<EmployersProvider>().refreshEmployerDetail(employerId);
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          PrimaryDialog('verify.identity.document_uploaded_success'.tr()),
    );
  }

  Future<void> _completeVerification({
    required bool isAadharVerified,
    required bool isDocumentUploaded,
  }) async {
    if (!isAadharVerified && !isDocumentUploaded) {
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => PrimaryDialog(
          'verify.identity.verify_aadhaar_or_document_first'.tr(),
          title: 'common.unable_to_continue'.tr(),
          showIcon: false,
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          PrimaryDialog('verify.identity.profile_completed_success'.tr()),
    );

    if (!mounted) return;
    // Only return a result; the caller decides next navigation.
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployersProvider>();
    final employer = _currentEmployer(provider);

    final kycStatus = _kycStatus(employer);
    final isKycPending = kycStatus == 'pending';
    final showAadhaarVerifyAction = !isKycPending;

    final isAadharVerified = _isAadhaarVerified(employer);
    final isDocumentUploaded = _isDocumentUploaded(employer);

    return Scaffold(
      backgroundColor: context.colors.onPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Toolbar('verify.identity.title'.tr(), () {
              Navigator.of(context).pop();
            }),
            Divider(
              color: context.xcolors.stroke.withValues(alpha: 0.5),
              height: 1,
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.md,
                vertical: context.spacing.sm,
              ),
              color: context.xcolors.successBackground,
              child: Text(
                'verify.identity.employer_note'.tr(),
                style: context.text.bodyMedium!.copyWith(
                  color: context.xcolors.success,
                ),
              ),
            ),
            SizedBox(height: context.spacing.md),
            IdentityItem(
              title: 'verify.identity.verify_aadhaar_title'.tr(),
              description: isKycPending
                  ? 'profile.verification.kyc_in_review'.tr()
                  : (kycStatus == 'init'
                        ? 'profile.verification.aadhaar_pending'.tr()
                        : 'verify.identity.verify_aadhaar_desc'.tr()),
              appIcon: AppIcon.verifyAadhar,
              isVerified: isAadharVerified,
              showAction: showAadhaarVerifyAction,
              onVerifyClicked: _verifyAadhaar,
            ),
            SizedBox(height: context.spacing.sm),
            IdentityItem(
              title: 'verify.identity.upload_documents'.tr(),
              description: 'verify.identity.upload_documents_desc'.tr(),
              appIcon: AppIcon.verifyAadhar,
              isVerified: isDocumentUploaded,
              buttonText: 'common.upload'.tr(),
              onVerifyClicked: _uploadDocument,
            ),
            Spacer(),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: context.spacing.md,
                vertical: context.spacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primaryContainer,
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (widget.goToAddJobOnExit) {
                          Navigator.of(context).pop(true);
                          return;
                        }
                        Navigator.of(context).pop(false);
                      },
                      child: Text(
                        'common.skip'.tr(),
                        style: context.text.bodyMedium,
                      ),
                    ),
                  ),
                  SizedBox(width: context.spacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _completeVerification(
                        isAadharVerified: isAadharVerified,
                        isDocumentUploaded: isDocumentUploaded,
                      ),
                      child: Text('profile.complete.title'.tr()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
