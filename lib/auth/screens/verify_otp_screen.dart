import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/auth/providers/auth_provider.dart';
import 'package:rotijugaad/auth/screens/auth_screen.dart';
import 'package:rotijugaad/common/dialogs/message_dialog.dart';
import 'package:rotijugaad/common/widgets/app_button_child.dart';
import 'package:rotijugaad/common/widgets/otp_field.dart';
import 'package:rotijugaad/container/screens/employer_container.dart';
import 'package:rotijugaad/container/screens/main_container.dart';
import 'package:rotijugaad/employees/services/employees_service.dart';
import 'package:rotijugaad/employers/services/employers_service.dart';
import 'package:rotijugaad/masters/providers/masters_provider.dart';
import 'package:rotijugaad/jobs/screens/help_support_screen.dart';
import 'package:rotijugaad/navigation/app_page_route.dart';
import 'package:rotijugaad/profile/screens/terms_condition_screen.dart';
import 'package:rotijugaad/settings/providers/language_provider.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/users/services/users_service.dart';
import 'package:rotijugaad/utils/result.dart';
import 'package:rotijugaad/utils/shared_pref.dart';

import '../../common/widgets/heading_subheading.dart';
import '../../common/widgets/toolbar.dart';

enum OtpFlow { login, signup }

class VerifyOtpScreen extends StatefulWidget {
  final OtpFlow flow;

  const VerifyOtpScreen({super.key, required this.flow});

  @override
  State<StatefulWidget> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  static const int _otpCountdownSeconds = 30;

  Timer? _timer;
  int _secondsLeft = _otpCountdownSeconds;
  final FocusNode _otpFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 280), _focusOtpField);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (mounted) {
      setState(() => _secondsLeft = _otpCountdownSeconds);
    } else {
      _secondsLeft = _otpCountdownSeconds;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  void _focusOtpField() {
    if (!mounted) return;
    FocusScope.of(context).requestFocus(_otpFocusNode);
  }

  void _goToAuthScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      AppPageRoute.slideFade(page: AuthScreen()),
      (route) => false,
    );
  }

  String get _timerText => '00:${_secondsLeft.toString().padLeft(2, '0')}s';

  String _verificationSubtitle(String mobile) {
    final trimmed = mobile.trim();
    if (trimmed.isEmpty) {
      return 'auth.otp.subtitle_generic'.tr();
    }

    return 'auth.otp.subtitle_with_mobile'.tr(args: [trimmed]);
  }

  Future<void> _showErrorDialog(
    String message, {
    String? title,
    bool showContactSupport = false,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => MessageDialog(
        title: title ?? 'common.unable_to_continue'.tr(),
        message: message,
        secondaryButtonLabel: showContactSupport ? 'Contact Support' : null,
        onSecondaryButtonPressed: showContactSupport
            ? () => Navigator.of(dialogContext).push(
                  MaterialPageRoute(builder: (_) => HelpSupportScreen()),
                )
            : null,
      ),
    );
  }

  Future<void> _resendOtp() async {
    final authProvider = context.read<AuthProvider>();

    try {
      if (widget.flow == OtpFlow.login) {
        await authProvider.sendLoginOtp();
      } else {
        await authProvider.sendSignupOtp();
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('common.otp_sent'.tr())));
      _startTimer();
      Future<void>.delayed(const Duration(milliseconds: 180), _focusOtpField);
    } catch (e) {
      if (!context.mounted) return;

      await _showErrorDialog(authProvider.lastError?.message ?? e.toString());
    }
  }

  Widget _buildResendSection(AuthProvider auth) {
    if (_secondsLeft > 0) {
      return SizedBox(
        width: double.infinity,
        height: 40,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'auth.otp.send_in'.tr(args: [_timerText]),
            style: context.text.bodyMedium,
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: auth.isLoading ? null : _resendOtp,
        child: SizedBox(
          width: double.infinity,
          height: 40,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'auth.otp.resend'.tr(),
              style: context.text.bodyMedium!.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _verifyOtp() async {
    final auth = context.read<AuthProvider>();

    if (auth.otp.trim().length != 4) {
      await _showErrorDialog(
        'common.invalid_otp_message'.tr(),
        title: 'common.invalid_otp_title'.tr(),
      );
      return;
    }

    try {
      final response = widget.flow == OtpFlow.login
          ? await auth.verifyLoginOtp()
          : await auth.verifySignupOtp();

      final resolvedType = response.user.userType ?? auth.userType;
      if (resolvedType.trim().isNotEmpty) {
        auth.userType = resolvedType;
        SharedPrefUtils.saveStr(SharedPrefUtils.USER_TYPE, resolvedType);
      }

      final storedUserType = SharedPrefUtils.readStr(SharedPrefUtils.USER_TYPE);
      final userType = storedUserType.isNotEmpty
          ? storedUserType
          : auth.userType;

      try {
        await UsersService().updatePreferredLanguage(
          userId: response.user.id,
          preferredLanguage: context.read<LanguageProvider>().languageCode,
        );
      } catch (_) {}

      try {
        final profile = response.profile ?? const <String, dynamic>{};
        final profileId = (profile['id'] as num?)?.toInt();

        if (userType == 'employer') {
          final id = profileId ?? response.user.id;
          final res = await EmployersService().getEmployerById(id);
          switch (res) {
            case Success(value: final data):
              final employer = data['employer'];
              if (employer is Map<String, dynamic>) {
                await SharedPrefUtils.saveJson(
                  SharedPrefUtils.AUTH_PROFILE_JSON,
                  employer,
                );
              }
              break;
            case Failure():
              break;
          }
        } else {
          final service = EmployeesService();

          if (profileId != null && profileId > 0) {
            final res = await service.getEmployeeById(profileId);
            switch (res) {
              case Success(value: final detail):
                await SharedPrefUtils.saveJson(
                  SharedPrefUtils.AUTH_PROFILE_JSON,
                  detail.employee.raw,
                );
                break;
              case Failure():
                break;
            }
          } else {
            final res = await service.getPersonalInfo(response.user.id);
            switch (res) {
              case Success(value: final emp):
                await SharedPrefUtils.saveJson(
                  SharedPrefUtils.AUTH_PROFILE_JSON,
                  emp.raw,
                );
                break;
              case Failure():
                break;
            }
          }
        }
      } catch (_) {}

      context.read<MastersProvider>().loadMasters(force: true);

      if (!context.mounted) return;

      if (userType == 'employer') {
        Navigator.pushAndRemoveUntil(
          context,
          AppPageRoute.slideFade(page: EmployerContainer()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          AppPageRoute.slideFade(page: MainContainer()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      await _showErrorDialog(
        auth.lastError?.message ?? e.toString(),
        showContactSupport: auth.lastError?.code == 'FC_03',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final auth = context.watch<AuthProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goToAuthScreen();
      },
      child: Scaffold(
        backgroundColor: context.colors.onPrimary,
        body: SafeArea(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: context.spacing.md),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Toolbar('', _goToAuthScreen),
                      Row(
                        children: [
                          Text(
                            'EN',
                            style: context.text.bodyMedium!.copyWith(
                              color: context.colors.secondary.withValues(
                                alpha: lang.isHindi ? 0.4 : 1,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Switch(
                            value: lang.isHindi,
                            activeColor: context.colors.onSecondary,
                            activeTrackColor: context.colors.primary,
                            inactiveTrackColor: context.colors.secondary,
                            inactiveThumbColor: context.colors.onPrimary,
                            onChanged: (bool value) {
                              lang.setLanguage(
                                value ? AppLanguage.hi : AppLanguage.en,
                              );

                              context.setLocale(
                                value ? const Locale('hi') : const Locale('en'),
                              );
                            },
                          ),
                          Text(
                            'HI',
                            style: context.text.bodyMedium!.copyWith(
                              color: context.colors.primary.withValues(
                                alpha: lang.isHindi ? 1 : 0.4,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: context.spacing.lg),
                  Center(child: Image.asset('assets/images/img_otp.png')),
                  SizedBox(height: context.spacing.lg),
                  HeadingSubheading(
                    'auth.otp.title'.tr(),
                    _verificationSubtitle(auth.mobile),
                  ),
                  SizedBox(height: context.spacing.lg),
                  OtpField(
                    enabled: !auth.isLoading,
                    focusNode: _otpFocusNode,
                    length: 4,
                    validator: (otp) => null,
                    onChanged: (otp) {
                      context.read<AuthProvider>().otp = otp;
                    },
                    onCompleted: (otp) {
                      context.read<AuthProvider>().otp = otp ?? '';
                      return null;
                    },
                  ),
                  SizedBox(height: context.spacing.sm),
                  _buildResendSection(auth),
                  SizedBox(height: context.spacing.sm),
                  Wrap(
                    spacing: context.spacing.xs,
                    runSpacing: context.spacing.xxs,
                    children: [
                      Text(
                        'auth.otp.agree_prefix'.tr(),
                        style: context.text.bodyLarge,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            AppPageRoute.slideFade(
                              page: TermsConditionScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'auth.otp.terms'.tr(),
                          style: context.text.bodyMedium!.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.spacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _verifyOtp,
                      child: AppButtonChild(
                        label: 'common.continue'.tr(),
                        isLoading: auth.isLoading,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
