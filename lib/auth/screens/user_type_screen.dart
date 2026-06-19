import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/auth/providers/auth_provider.dart';
import 'package:rotijugaad/auth/screens/signin_screen.dart';
import 'package:rotijugaad/auth/screens/signup_screen.dart';
import 'package:rotijugaad/navigation/app_page_route.dart';
import 'package:rotijugaad/settings/providers/language_provider.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/utils/shared_pref.dart';

class UserTypeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserTypeScreenState();
}

class _UserTypeScreenState extends State<UserTypeScreen> {
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: context.colors.onPrimary,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: context.spacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: context.spacing.md),
                      Text(
                        'auth.welcome_to_app'.tr(),
                        style: context.text.bodyLarge!.copyWith(
                          color: context.colors.onSurface,
                        ),
                      ),
                      SizedBox(height: context.spacing.xs),
                      Text(
                        'auth.welcome_headline'.tr(),
                        style: context.text.titleLarge!.copyWith(
                          color: context.colors.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),

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
                        onChanged: (bool value) async {
                          await lang.setLanguage(
                            value ? AppLanguage.hi : AppLanguage.en,
                          );
                          if (!context.mounted) return;
                          await context.setLocale(
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

              Image.asset("assets/images/img_welcome.png"),

              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        SharedPrefUtils.saveStr(
                          SharedPrefUtils.USER_TYPE,
                          'employee',
                        );
                        context.read<AuthProvider>().userType = 'employee';
                        Navigator.pushAndRemoveUntil(
                          context,
                          AppPageRoute.slideFade(page: SignupScreen()),
                          (route) => false,
                        );
                      },
                      child: Text('auth.user_type.employee_button'.tr()),
                    ),
                  ),
                  SizedBox(height: context.spacing.xs),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        SharedPrefUtils.saveStr(
                          SharedPrefUtils.USER_TYPE,
                          'employer',
                        );
                        context.read<AuthProvider>().userType = 'employer';
                        Navigator.pushAndRemoveUntil(
                          context,
                          AppPageRoute.slideFade(page: SignupScreen()),
                          (route) => false,
                        );
                      },
                      child: Text('auth.user_type.employer_button'.tr()),
                    ),
                  ),
                  SizedBox(height: context.spacing.lg),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'auth.have_account'.tr(),
                        style: context.text.bodyLarge,
                      ),
                      SizedBox(width: context.spacing.xs),
                      InkWell(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            AppPageRoute.slideFade(page: SignInScreen()),
                            (route) => false,
                          );
                        },
                        child: Text(
                          'common.login'.tr(),
                          style: context.text.bodyLarge!.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.spacing.xxl),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
