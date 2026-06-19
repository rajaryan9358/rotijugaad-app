import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rotijugaad/employers/providers/employers_provider.dart';
import 'package:rotijugaad/employees/providers/employees_provider.dart';
import 'package:rotijugaad/profile/dialogs/profile_incomplete_dialog.dart';
import 'package:rotijugaad/profile/screens/edit_employer_profile_screen.dart';
import 'package:rotijugaad/profile/utils/profile_status_helper.dart';
import 'package:rotijugaad/profile/utils/session_refresh_helper.dart';
import 'package:rotijugaad/utils/result.dart';
import 'package:rotijugaad/utils/shared_pref.dart';
import 'package:rotijugaad/users/services/users_service.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/applicants/screens/applicants_screen.dart';
import 'package:rotijugaad/candidates/screens/candidates_screen.dart';
import 'package:rotijugaad/employerjobs/screens/employer_jobs_screen.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/deeplinks/deep_link_pending.dart';

import '../../common/widgets/xicon.dart';
import '../../profile/screens/profile_screen.dart';
import '../../theme/app_icons.dart';
import '../container_nav.dart';

class EmployerContainer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EmployerContainerState();
}

class _EmployerContainerState extends State<EmployerContainer> {
  bool _bootstrapped = false;
  bool _didPromptIncompleteProfile = false;
  DateTime? _lastBackPressAt;

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  Future<void> _bootstrapProfile() async {
    if (_bootstrapped) return;
    _bootstrapped = true;

    final userJson = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_USER_JSON);
    final userId = _asInt(userJson?['id'] ?? userJson?['userId']);

    if (userId != null && userId > 0) {
      final result = await UsersService().getUserById(userId);
      switch (result) {
        case Success(value: final user):
          await SharedPrefUtils.saveJson(
            SharedPrefUtils.AUTH_USER_JSON,
            user.toJson(),
          );
          final type = (user.userType ?? '').trim();
          if (type.isNotEmpty) {
            await SharedPrefUtils.saveStr(SharedPrefUtils.USER_TYPE, type);
          }
          await SharedPrefUtils.saveBool(
            SharedPrefUtils.AUTH_PROFILE_COMPLETED,
            ProfileStatusHelper.isProfileCompleted(
              user: user.toJson(),
              profile: SharedPrefUtils.readJson(
                SharedPrefUtils.AUTH_PROFILE_JSON,
              ),
            ),
          );
          break;
        case Failure():
          break;
      }
    }

    var userType = SharedPrefUtils.readStr(
      SharedPrefUtils.USER_TYPE,
    ).trim().toLowerCase();
    if (userType.isEmpty) {
      userType = SharedPrefUtils.readStr(
        SharedPrefUtils.AUTH_PROFILE_TYPE,
      ).trim().toLowerCase();
    }
    final profileJson = SharedPrefUtils.readJson(
      SharedPrefUtils.AUTH_PROFILE_JSON,
    );
    final profileId = _asInt(
      profileJson?['id'] ??
          profileJson?['employeeId'] ??
          profileJson?['employerId'],
    );

    if (profileId != null && profileId > 0) {
      if (userType == 'employer') {
        await context.read<EmployersProvider>().refreshEmployerDetail(
          profileId,
        );
      } else {
        await context.read<EmployeesProvider>().refreshEmployeeDetail(
          profileId,
        );
      }
    }

    await _maybeShowIncompleteProfileDialog();

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _maybeShowIncompleteProfileDialog() async {
    if (!mounted || _didPromptIncompleteProfile) return;
    final isCompleted = SharedPrefUtils.readBool(
      SharedPrefUtils.AUTH_PROFILE_COMPLETED,
    );
    if (isCompleted ||
        ProfileStatusHelper.isProfileCompleted(
          user: SharedPrefUtils.readJson(SharedPrefUtils.AUTH_USER_JSON),
          profile: SharedPrefUtils.readJson(SharedPrefUtils.AUTH_PROFILE_JSON),
        )) {
      return;
    }

    _didPromptIncompleteProfile = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => ProfileIncompleteDialog(
        title: 'profile.incomplete.title'.tr(),
        message: 'profile.incomplete.message'.tr(),
        laterButtonText: 'profile.incomplete.later'.tr(),
        onLater: () => Navigator.of(dialogContext).pop(),
        onCompleteProfile: () async {
          Navigator.of(dialogContext).pop();
          final outcome = await Navigator.push<Object?>(
            context,
            MaterialPageRoute(
              builder: (_) => const EditEmployerProfileScreen(
                goToAddJobAfterVerification: true,
              ),
            ),
          );

          if (!mounted) return;
          await handleEditEmployerProfileOutcome(context, outcome);

          if (!mounted) return;
          await SessionRefreshHelper.refreshCurrentSession(context);
          if (!mounted) return;
          setState(() {});
        },
      ),
    );
  }

  void _onPendingTabIndex() {
    final idx = ContainerNav.pendingTabIndex.value;
    if (idx == null || !mounted) return;
    ContainerNav.pendingTabIndex.value = null;
    setState(() => _selectedIndex = idx);
  }

  @override
  void initState() {
    super.initState();
    ContainerNav.pendingTabIndex.addListener(_onPendingTabIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrapProfile().then((_) {
        if (!mounted) return;
        // ignore: unawaited_futures
        DeepLinkPending.consumeAndNavigate(context);
      });
    });
  }

  @override
  void dispose() {
    ContainerNav.pendingTabIndex.removeListener(_onPendingTabIndex);
    super.dispose();
  }

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    CandidatesScreen(),
    ApplicantsScreen(),
    EmployerJobsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return false;
    }

    final now = DateTime.now();
    final last = _lastBackPressAt;
    if (last == null || now.difference(last) > const Duration(seconds: 2)) {
      _lastBackPressAt = now;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('common.press_back_again_to_exit'.tr())),
        );
      }
      return false;
    }

    await SystemNavigator.pop();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _pages[_selectedIndex],

        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            // 🟢 Removes background highlight
            indicatorColor: Colors.transparent,

            // 🟢 Changes label text color
            labelTextStyle: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                );
              }
              return TextStyle(color: colors.onSurfaceVariant.withOpacity(0.7));
            }),
          ),
          child: NavigationBar(
            height: 65,
            backgroundColor: colors.surface,
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            destinations: [
              NavigationDestination(
                icon: const XIcon(AppIcon.applications),
                selectedIcon: XIcon(
                  AppIcon.applications,
                  color: colors.primary,
                ),
                label: 'nav.candidates'.tr(),
              ),
              NavigationDestination(
                icon: const XIcon(AppIcon.updateExperience),
                selectedIcon: XIcon(
                  AppIcon.updateExperience,
                  color: colors.primary,
                ),
                label: 'nav.applicants'.tr(),
              ),
              NavigationDestination(
                icon: const XIcon(AppIcon.jobs),
                selectedIcon: XIcon(AppIcon.jobs, color: colors.primary),
                label: 'nav.jobs'.tr(),
              ),
              NavigationDestination(
                icon: const XIcon(AppIcon.profile),
                selectedIcon: XIcon(AppIcon.profile, color: colors.primary),
                label: 'nav.profile'.tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
