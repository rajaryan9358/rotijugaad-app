import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rotijugaad/auth/screens/auth_screen.dart';
import 'package:rotijugaad/common/widgets/language_selector.dart';
import 'package:rotijugaad/navigation/app_page_route.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class LanguageScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.onPrimary,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: context.spacing.md),
          child: Column(
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'auth.select_language'.tr(),
                    style: context.text.bodyLarge,
                  ),
                  SizedBox(height: context.spacing.md),
                  LanguageSelector(),
                  SizedBox(height: context.spacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          AppPageRoute.slideFade(page: AuthScreen()),
                        );
                      },
                      child: Text('common.save'.tr()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
