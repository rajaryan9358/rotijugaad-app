import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/settings/providers/app_settings_provider.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/utils/shared_pref.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/widgets/toolbar.dart';

class HelpSupportScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  Future<void> _openPhone(String phone) async {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('support.phone_unavailable'.tr())));
      return;
    }

    final uri = Uri(scheme: 'tel', path: trimmed);
    try {
      final ok = await launchUrl(uri);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('support.could_not_open_dialer'.tr())),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('support.could_not_open_dialer'.tr())),
      );
    }
  }

  Future<void> _openEmail(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('support.email_unavailable'.tr())));
      return;
    }

    final uri = Uri(scheme: 'mailto', path: trimmed);
    try {
      final ok = await launchUrl(uri);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('support.could_not_open_email'.tr())),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('support.could_not_open_email'.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>().settings;
    final userType = SharedPrefUtils.readStr(SharedPrefUtils.USER_TYPE);
    final supportPhone = settings.supportMobileFor(userType);
    final supportEmail = settings.supportEmailFor(userType);

    return Scaffold(
      backgroundColor: context.colors.onPrimary,
      body: Column(
        children: [
          Container(
            color: context.colors.onPrimary,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).viewPadding.top,
            ),
            child: Toolbar('support.screen.title'.tr(), () {
              Navigator.of(context).pop();
            }),
          ),
          SizedBox(height: context.spacing.md),
          Container(
            margin: EdgeInsets.symmetric(horizontal: context.spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'support.call_us'.tr(),
                  style: context.text.bodyMedium!.copyWith(
                    color: context.colors.onPrimaryContainer,
                  ),
                ),
                SizedBox(height: context.spacing.xs),
                GestureDetector(
                  onTap: () => _openPhone(supportPhone),
                  child: Text(
                    supportPhone.trim().isEmpty
                        ? 'common.not_available'.tr()
                        : "+91 $supportPhone",
                    style: context.text.bodySmall!.copyWith(
                      color: context.colors.onSurface,
                      decoration: supportPhone.trim().isEmpty
                          ? TextDecoration.none
                          : TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(height: context.spacing.xs),
                Divider(color: context.colors.onSurface.withValues(alpha: 0.2)),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: context.spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'support.write_to_us'.tr(),
                  style: context.text.bodyMedium!.copyWith(
                    color: context.colors.onPrimaryContainer,
                  ),
                ),
                SizedBox(height: context.spacing.xs),
                GestureDetector(
                  onTap: () => _openEmail(supportEmail),
                  child: Text(
                    supportEmail.trim().isEmpty
                        ? 'common.not_available'.tr()
                        : supportEmail,
                    style: context.text.bodySmall!.copyWith(
                      color: context.colors.onSurface,
                      decoration: supportEmail.trim().isEmpty
                          ? TextDecoration.none
                          : TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(height: context.spacing.xs),
                Divider(color: context.colors.onSurface.withValues(alpha: 0.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
