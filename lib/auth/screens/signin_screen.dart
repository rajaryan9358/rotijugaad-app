import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/auth/dialogs/not_registered_dialog.dart';
import 'package:rotijugaad/auth/providers/auth_provider.dart';
import 'package:rotijugaad/auth/screens/auth_screen.dart';
import 'package:rotijugaad/auth/screens/user_type_screen.dart';
import 'package:rotijugaad/auth/screens/verify_otp_screen.dart';
import 'package:rotijugaad/common/dialogs/message_dialog.dart';
import 'package:rotijugaad/common/widgets/app_button_child.dart';
import 'package:rotijugaad/common/widgets/clickable_text.dart';
import 'package:rotijugaad/common/widgets/heading_subheading.dart';
import 'package:rotijugaad/common/widgets/labeled_form_field.dart';
import 'package:rotijugaad/common/widgets/toolbar.dart';
import 'package:rotijugaad/jobs/screens/help_support_screen.dart';
import 'package:rotijugaad/navigation/app_page_route.dart';
import 'package:rotijugaad/settings/providers/language_provider.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class SignInScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _mobileController = TextEditingController();
  final _mobileFocusNode = FocusNode();

  void _clearDraft() {
    final auth = context.read<AuthProvider>();
    auth.clearAuthDraft(keepUserType: false);
    _mobileController.clear();
  }

  Future<void> _openVerifyOtpScreen() async {
    FocusScope.of(context).unfocus();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      AppPageRoute.slideFade(
        page: const VerifyOtpScreen(flow: OtpFlow.login),
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

  @override
  void initState() {
    super.initState();
    _mobileController.text = context.read<AuthProvider>().mobile;
  }

  Future<void> _showNotRegisteredDialog(BuildContext context, String message) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => NotRegisteredDialog(
        message: message,
        onSignup: () {
          Navigator.of(dialogContext).pop();
          Navigator.pushReplacement(
            context,
            AppPageRoute.slideFade(page: UserTypeScreen()),
          );
        },
      ),
    );
  }

  Future<void> _showErrorDialog(String message, {bool showContactSupport = false}) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => MessageDialog(
        title: 'common.unable_to_continue'.tr(),
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

  @override
  void dispose() {
    _mobileController.dispose();
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
                  Center(child: Image.asset("assets/images/img_signin.png")),
                  SizedBox(height: context.spacing.lg),
                  HeadingSubheading(
                    'auth.signin.title'.tr(),
                    'auth.signin.subtitle'.tr(),
                  ),
                  SizedBox(height: context.spacing.lg),
                  LabeledFormField(
                    title: 'auth.signin.mobile_title'.tr(),
                    hintText: 'auth.signin.mobile_hint'.tr(),
                    keyboardType: TextInputType.phone,
                    focusNode: _mobileFocusNode,
                    enabled: !auth.isLoading,
                    maxLength: 10,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    controller: _mobileController,
                    onChanged: (v) {
                      context.read<AuthProvider>().mobile = v;
                      if (v.length == 10) {
                        _mobileFocusNode.unfocus();
                      }
                    },
                  ),
                  SizedBox(height: context.spacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.isLoading || !isValidMobile
                          ? null
                          : () async {
                              final auth = context.read<AuthProvider>();
                              auth.mobile = _mobileController.text.trim();

                              try {
                                await auth.sendLoginOtp();
                                if (!context.mounted) return;
                                await _openVerifyOtpScreen();
                              } catch (e) {
                                if (!context.mounted) return;
                                if (auth.lastError?.code == 'FC_02') {
                                  await _showNotRegisteredDialog(
                                    context,
                                    auth.lastError?.message ??
                                        'auth.signin.not_registered_message'
                                            .tr(),
                                  );
                                  return;
                                }
                                await _showErrorDialog(
                                  auth.lastError?.message ?? e.toString(),
                                  showContactSupport:
                                      auth.lastError?.code == 'FC_03',
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
                      'auth.signin.no_account'.tr(),
                      'common.sign_up'.tr(),
                      () {
                        _clearDraft();
                        Navigator.pushReplacement(
                          context,
                          AppPageRoute.slideFade(page: UserTypeScreen()),
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
