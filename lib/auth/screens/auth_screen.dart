import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/auth/screens/signin_screen.dart';
import 'package:rotijugaad/auth/screens/user_type_screen.dart';
import 'package:rotijugaad/navigation/app_page_route.dart';
import 'package:rotijugaad/settings/providers/language_provider.dart';
import 'package:rotijugaad/settings/providers/app_settings_provider.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  Future<void> _openSocialLink(String url, String label) async {
    final resolved = url.trim();
    if (resolved.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('common.link_unavailable'.tr(args: [label]))),
      );
      return;
    }

    final uri = Uri.tryParse(resolved);
    if (uri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('common.could_not_open_link'.tr(args: [label]))),
      );
      return;
    }

    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('common.could_not_open_link'.tr(args: [label])),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('common.could_not_open_link'.tr(args: [label]))),
      );
    }
  }

  Widget _buildSocialIcon({
    required String asset,
    required String url,
    required String label,
  }) {
    final enabled = url.trim().isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _openSocialLink(url, label),
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SvgPicture.asset(asset),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = context.watch<AppSettingsProvider>().settings;
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

              Image.asset("assets/images/img_welcome.png"),

              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          AppPageRoute.slideFade(page: SignInScreen()),
                        );
                      },
                      child: Text('common.login'.tr()),
                    ),
                  ),
                  SizedBox(height: context.spacing.xs),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          AppPageRoute.slideFade(page: UserTypeScreen()),
                        );
                      },
                      child: Text('common.sign_up'.tr()),
                    ),
                  ),
                  SizedBox(height: context.spacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSocialIcon(
                        asset: "assets/icons/ic_linkedin.svg",
                        url: appSettings.resolvedLinkedinLink,
                        label: 'LinkedIn',
                      ),
                      _buildSocialIcon(
                        asset: "assets/icons/ic_x.svg",
                        url: appSettings.resolvedXlLink,
                        label: 'X',
                      ),
                      _buildSocialIcon(
                        asset: "assets/icons/ic_facebook.svg",
                        url: appSettings.resolvedFacebookLink,
                        label: 'Facebook',
                      ),
                      _buildSocialIcon(
                        asset: "assets/icons/ic_instagram.svg",
                        url: appSettings.resolvedInstagramLink,
                        label: 'Instagram',
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
