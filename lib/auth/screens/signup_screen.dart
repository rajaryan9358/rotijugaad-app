import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/auth/providers/auth_provider.dart';
import 'package:rotijugaad/auth/screens/auth_screen.dart';
import 'package:rotijugaad/auth/screens/signin_screen.dart';
import 'package:rotijugaad/auth/screens/verify_otp_screen.dart';
import 'package:rotijugaad/common/dialogs/message_dialog.dart';
import 'package:rotijugaad/common/widgets/app_button_child.dart';
import 'package:rotijugaad/common/widgets/labeled_form_field.dart';
import 'package:rotijugaad/navigation/app_page_route.dart';
import 'package:rotijugaad/settings/providers/language_provider.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/utils/shared_pref.dart';

import '../../common/widgets/clickable_text.dart';
import '../../common/widgets/heading_subheading.dart';
import '../../common/widgets/toolbar.dart';

class SignupScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _referredByController = TextEditingController();
  final _mobileFocusNode = FocusNode();

  void _clearDraft() {
    final auth = context.read<AuthProvider>();
    auth.clearAuthDraft(keepUserType: false);
    _nameController.clear();
    _mobileController.clear();
    _referredByController.clear();
  }

  Future<void> _openVerifyOtpScreen() async {
    FocusScope.of(context).unfocus();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      AppPageRoute.slideFade(
        page: const VerifyOtpScreen(flow: OtpFlow.signup),
        beginOffset: const Offset(0.04, 0.0),
        duration: const Duration(milliseconds: 320),
        reverseDuration: const Duration(milliseconds: 240),
      ),
    );
  }

  void _goToAuthScreen() {
    _clearDraft();
    Navigator.pushAndRemoveUntil(
      context,
      AppPageRoute.slideFade(page: AuthScreen()),
      (route) => false,
    );
  }

  Future<void> _showErrorDialog(String message) {
    return showDialog<void>(
      context: context,
      builder: (_) => MessageDialog(
        title: 'common.unable_to_continue'.tr(),
        message: message,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _mobileController.text = auth.mobile;
    _nameController.text = auth.name;
    _referredByController.text = auth.referredBy;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _referredByController.dispose();
    _mobileFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final auth = context.watch<AuthProvider>();
    final isValidMobile = _mobileController.text.trim().length == 10;
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
                      Toolbar("", () {
                        _goToAuthScreen();
                      }),
                      Row(
                        children: [
                          Text(
                            "EN",
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
                            "HI",
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
                  Center(child: Image.asset("assets/images/img_signup.png")),
                  SizedBox(height: context.spacing.lg),
                  HeadingSubheading(
                    'auth.signup.title'.tr(),
                    'auth.signup.subtitle'.tr(),
                  ),
                  SizedBox(height: context.spacing.lg),
                  LabeledFormField(
                    title: 'auth.signup.name_title'.tr(),
                    hintText: 'auth.signup.name_hint'.tr(),
                    enabled: !auth.isLoading,
                    controller: _nameController,
                    onChanged: (v) => context.read<AuthProvider>().name = v,
                  ),
                  SizedBox(height: context.spacing.sm),
                  LabeledFormField(
                    title: 'auth.signup.mobile_title'.tr(),
                    hintText: 'auth.signup.mobile_hint'.tr(),
                    controller: _mobileController,
                    enabled: !auth.isLoading,
                    focusNode: _mobileFocusNode,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    onChanged: (v) {
                      context.read<AuthProvider>().mobile = v;
                      if (v.length == 10) {
                        _mobileFocusNode.unfocus();
                      }
                    },
                  ),
                  SizedBox(height: context.spacing.sm),
                  LabeledFormField(
                    title: 'auth.signup.referred_by_title'.tr(),
                    hintText: 'auth.signup.referred_by_hint'.tr(),
                    optional: true,
                    enabled: !auth.isLoading,
                    controller: _referredByController,
                    onChanged: (v) =>
                        context.read<AuthProvider>().referredBy = v,
                  ),
                  SizedBox(height: context.spacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.isLoading || !isValidMobile
                          ? null
                          : () async {
                              final auth = context.read<AuthProvider>();

                              auth.name = _nameController.text.trim();
                              auth.mobile = _mobileController.text.trim();
                              auth.referredBy = _referredByController.text
                                  .trim();

                              final storedUserType = SharedPrefUtils.readStr(
                                SharedPrefUtils.USER_TYPE,
                              );

                              if (storedUserType.isNotEmpty) {
                                auth.userType = storedUserType;
                              }

                              try {
                                await auth.sendSignupOtp();
                                if (!context.mounted) return;
                                await _openVerifyOtpScreen();
                              } catch (e) {
                                if (!context.mounted) return;
                                await _showErrorDialog(
                                  auth.lastError?.message ?? e.toString(),
                                );
                              }
                            },
                      child: AppButtonChild(
                        label: 'auth.signin.request_otp'.tr(),
                        isLoading: auth.isLoading,
                      ),
                    ),
                  ),
                  SizedBox(height: context.spacing.lg),
                  Center(
                    child: ClickableText(
                      'auth.have_account'.tr(),
                      'common.login'.tr(),
                      () {
                        _clearDraft();
                        Navigator.pushReplacement(
                          context,
                          AppPageRoute.slideFade(page: SignInScreen()),
                        );
                      },
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
