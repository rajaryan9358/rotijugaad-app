import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rotijugaad/common/widgets/toolbar.dart';
import 'package:rotijugaad/editprofile/screens/add_experience_screen.dart';
import 'package:rotijugaad/editprofile/screens/documents_screen.dart';
import 'package:rotijugaad/editprofile/screens/experiences_screen.dart';
import 'package:rotijugaad/editprofile/screens/job_profile_screen.dart';
import 'package:rotijugaad/editprofile/screens/personal_info_screen.dart';
import 'package:rotijugaad/profile/dialogs/profile_pending_review_dialog.dart';
import 'package:rotijugaad/profile/utils/session_refresh_helper.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/utils/shared_pref.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/employees/providers/employees_provider.dart';
import 'package:rotijugaad/verifyidentity/screens/verify_identity_screen.dart';

enum EditProfileMode { formOnly, completeFlow }

class EditProfile extends StatefulWidget {
  final EditProfileMode mode;
  final String title;
  final bool openKycOnSubmit;

  const EditProfile({
    super.key,
    this.mode = EditProfileMode.completeFlow,
    this.title = 'Update Profile',
    this.openKycOnSubmit = false,
  });

  @override
  State<StatefulWidget> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  int? _userId;
  int? _employeeId;
  int _step = 0;
  bool _showAddExperience = false;
  int? _editingExperienceId;

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  void _loadIds() {
    final profile = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_PROFILE_JSON);
    _employeeId = _asInt(profile?['id'] ?? profile?['employeeId']);
    _userId = _asInt(profile?['userId'] ?? profile?['user_id'] ?? _employeeId);

    // Fallback for older sessions.
    _userId ??= _asInt(
      SharedPrefUtils.readJson(SharedPrefUtils.AUTH_USER_JSON)?['id'],
    );

    _employeeId ??= _userId;
  }

  String get _toolbarTitle {
    if (widget.mode == EditProfileMode.formOnly)
      return _resolveTitle(widget.title);

    switch (_step) {
      case 1:
        return 'profile.flow.job_profiles'.tr();
      case 2:
        return _showAddExperience || _editingExperienceId != null
            ? (_editingExperienceId != null
                  ? 'profile.flow.edit_experience'.tr()
                  : 'profile.flow.add_experience'.tr())
            : 'profile.flow.experiences'.tr();
      case 3:
        return 'profile.additional_documents.title'.tr();
      default:
        return _resolveTitle(widget.title);
    }
  }

  String _resolveTitle(String title) {
    switch (title) {
      case 'Update Profile':
        return 'profile.actions.update_profile'.tr();
      default:
        return title;
    }
  }

  Future<void> _handleProfileSaved(int employeeId) async {
    if (widget.mode == EditProfileMode.formOnly) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _employeeId = employeeId;
      _step = 1;
    });
  }

  Future<void> _openExperienceStep() async {
    final employeeId = _employeeId;
    if (employeeId == null) {
      setState(() {
        _step = 2;
        _showAddExperience = true;
        _editingExperienceId = null;
      });
      return;
    }

    final provider = context.read<EmployeesProvider>();
    await provider.fetchExperiences(employeeId);
    if (!mounted) return;

    final hasAnyExperience = provider.experiences.isNotEmpty;
    setState(() {
      _step = 2;
      _editingExperienceId = null;
      _showAddExperience = !hasAnyExperience;
    });
  }

  Future<void> _handleProfileSubmissionComplete() async {
    final employeeId = _employeeId;
    if (employeeId == null) {
      Navigator.of(context).pop(true);
      return;
    }

    await SessionRefreshHelper.refreshCurrentSession(context);
    if (!mounted) return;

    await SharedPrefUtils.saveBool(
      SharedPrefUtils.AUTH_PROFILE_COMPLETED,
      true,
    );

    if (!mounted) return;
    final provider = context.read<EmployeesProvider>();
    final employee = provider.employeeDetail ?? provider.personalInfo;
    final kycStatus = (employee?.kycStatus ?? '').trim().toLowerCase();

    if (widget.openKycOnSubmit &&
        (kycStatus.isEmpty || kycStatus == 'init' || kycStatus == 'rejected')) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => VerifyIdentityScreen(
            employeeId: employeeId,
            showReviewDialogOnExit: true,
          ),
        ),
        result: true,
      );
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const ProfilePendingReviewDialog(),
    );

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  void _handleBack() {
    if (widget.mode == EditProfileMode.formOnly || _step == 0) {
      Navigator.of(context).pop();
      return;
    }

    if (_step == 2 && (_showAddExperience || _editingExperienceId != null)) {
      setState(() {
        _showAddExperience = false;
        _editingExperienceId = null;
      });
      return;
    }

    setState(() {
      _step = (_step - 1).clamp(0, 3);
    });
  }

  Widget _buildBody() {
    final userId = _userId;
    final employeeId = _employeeId;

    if (userId == null) {
      return Center(
        child: Text(
          'profile.flow.unable_to_load_user_details'.tr(),
          style: context.text.bodyMedium,
        ),
      );
    }

    switch (_step) {
      case 0:
        return PersonalInfoScreen(
          userId: userId,
          submitButtonText: widget.mode == EditProfileMode.formOnly
              ? 'Update Profile'
              : 'Continue to Job Profile',
          showBackButtonOnLoading: false,
          onContinue: _handleProfileSaved,
        );
      case 1:
        if (employeeId == null) return const SizedBox.shrink();
        return JobProfileScreen(
          employeeId: employeeId,
          showBackButtonOnLoading: false,
          onButtonClicked: () {
            _openExperienceStep();
          },
        );
      case 2:
        if (employeeId == null) return const SizedBox.shrink();
        if (_showAddExperience || _editingExperienceId != null) {
          return AddExperienceScreen(
            employeeId: employeeId,
            experienceId: _editingExperienceId,
            onButtonClicked: () {
              final hasAnyExperience = context
                  .read<EmployeesProvider>()
                  .experiences
                  .isNotEmpty;

              setState(() {
                _showAddExperience = false;
                _editingExperienceId = null;
                if (!hasAnyExperience) {
                  _step = 3;
                }
              });
            },
          );
        }
        return ExperiencesScreen(
          employeeId: employeeId,
          onButtonClicked: () {
            setState(() => _step = 3);
          },
          onAddClicked: () {
            setState(() {
              _showAddExperience = true;
              _editingExperienceId = null;
            });
          },
          onEditClicked: (experienceId) {
            setState(() {
              _editingExperienceId = experienceId;
              _showAddExperience = false;
            });
          },
        );
      case 3:
        if (employeeId == null) return const SizedBox.shrink();
        return DocumentsScreen(
          employeeId: employeeId,
          onButtonClicked: _handleProfileSubmissionComplete,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadIds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.onPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Toolbar(_toolbarTitle, _handleBack),
            Divider(color: context.xcolors.stroke, height: 1),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  left: context.spacing.md,
                  right: context.spacing.md,
                  top: context.spacing.md,
                ),
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
