import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/utils/shared_pref.dart';
import 'package:rotijugaad/network/api_client.dart';

class ReferSheet extends StatefulWidget {
  const ReferSheet({super.key});

  @override
  State<StatefulWidget> createState() => _ReferSheetState();
}

class _ReferSheetState extends State<ReferSheet> {
  final Map<_DirectShareApp, bool> _installedApps = {
    _DirectShareApp.whatsapp: false,
    _DirectShareApp.facebook: false,
    _DirectShareApp.linkedin: false,
    _DirectShareApp.telegram: false,
  };

  String get _referralCode {
    final user = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_USER_JSON);
    final raw = (user?['referral_code'] ?? user?['referralCode'] ?? '')
        .toString()
        .trim();
    return raw.isNotEmpty ? raw : '—';
  }

  Map<String, dynamic>? _authProfileJson() {
    return SharedPrefUtils.readJson(SharedPrefUtils.AUTH_PROFILE_JSON);
  }

  Map<String, dynamic>? _authUserJson() {
    return SharedPrefUtils.readJson(SharedPrefUtils.AUTH_USER_JSON);
  }

  String _shareOwnerName(BuildContext context) {
    String? pick(Map<String, dynamic>? map) {
      if (map == null) return null;
      final hi = (map['name_hindi'] ?? map['nameHindi'])?.toString().trim();
      final en = (map['name_english'] ?? map['nameEnglish'] ?? map['name'])
          ?.toString()
          .trim();
      final primary = en;
      final fallback = hi;
      final value = (primary?.isNotEmpty == true ? primary : fallback) ?? '';
      return value.trim().isEmpty ? null : value.trim();
    }

    return pick(_authProfileJson()) ?? pick(_authUserJson()) ?? 'Dost';
  }

  String _referralShareMessage(BuildContext context, String referralLink) {
    final ownerName = _shareOwnerName(context);
    final code = _referralCode.trim();
    return [
      '$ownerName ne aapko RotiJugaad join karne ke liye invite kiya hai.',
      'App download karke referral code $code use karo:',
      referralLink,
    ].join('\n');
  }

  @override
  void initState() {
    super.initState();
    _refreshInstalledApps();
  }

  Future<void> _refreshInstalledApps() async {
    final checks = <_DirectShareApp, Uri>{
      _DirectShareApp.whatsapp: Uri.parse('whatsapp://send?text=test'),
      _DirectShareApp.telegram: Uri.parse('tg://msg?text=test'),
      _DirectShareApp.facebook: Uri.parse(
        'fb://facewebmodal/f?href=https%3A%2F%2Fwww.facebook.com',
      ),
      _DirectShareApp.linkedin: Uri.parse('linkedin://'),
    };

    final results = <_DirectShareApp, bool>{};
    for (final entry in checks.entries) {
      try {
        results[entry.key] = await canLaunchUrl(entry.value);
      } catch (_) {
        results[entry.key] = false;
      }
    }

    if (!mounted) return;
    setState(() {
      for (final entry in results.entries) {
        _installedApps[entry.key] = entry.value;
      }
    });
  }

  Future<void> _shareDirect({
    required BuildContext context,
    required _DirectShareApp app,
    required String referralCode,
    required String referralLink,
  }) async {
    final code = referralCode.trim();
    if (code.isEmpty || code == '—') return;

    final link = referralLink.trim();
    if (link.isEmpty) return;

    final message = _referralShareMessage(context, link);

    late final Uri uri;
    switch (app) {
      case _DirectShareApp.whatsapp:
        uri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(message)}');
        break;
      case _DirectShareApp.telegram:
        uri = Uri.parse('tg://msg?text=${Uri.encodeComponent(message)}');
        break;
      case _DirectShareApp.facebook:
        final shareUrl =
            'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(link)}&quote=${Uri.encodeComponent(message)}';
        uri = Uri.parse(
          'fb://facewebmodal/f?href=${Uri.encodeComponent(shareUrl)}',
        );
        break;
      case _DirectShareApp.linkedin:
        uri = Uri.parse(
          'linkedin://shareArticle?mini=true&url=${Uri.encodeComponent(link)}&summary=${Uri.encodeComponent(message)}',
        );
        break;
    }
    final ok = await canLaunchUrl(uri);
    if (!ok) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final referralLink = _referralCode.trim().isEmpty || _referralCode == '—'
        ? ''
        : '${ApiClient.baseUrl}/app/referral/${_referralCode.trim()}';

    Future<void> copyCode() async {
      final code = _referralCode.trim();
      if (code.isEmpty || code == '—') return;
      final messenger = ScaffoldMessenger.of(context);
      await Clipboard.setData(ClipboardData(text: code));
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Copied')));
    }

    Future<void> shareViaSheet() async {
      if (referralLink.isEmpty) return;
      await Share.share(_referralShareMessage(context, referralLink));
    }

    Future<void> shareToApp(_DirectShareApp app) async {
      await _shareDirect(
        context: context,
        app: app,
        referralCode: _referralCode,
        referralLink: referralLink,
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: context.spacing.lg,
        right: context.spacing.lg,
        top: context.spacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + context.spacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'profile.refer_sheet.title'.tr(),
                style: context.text.titleMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacing.xs,
                    vertical: context.spacing.sm,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: context.spacing.xxl,
                    color: context.colors.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing.md),
          Text(
            'profile.refer_sheet.tagline'.tr(),
            style: context.text.bodyMedium!.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.spacing.xs),
          Text(
            'profile.refer_sheet.how_it_works'.tr(),
            style: context.text.bodyMedium!.copyWith(
              color: context.colors.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: context.spacing.md),
          Column(
            children:
                [
                      'profile.refer_sheet.points.1'.tr(),
                      'profile.refer_sheet.points.2'.tr(),
                      'profile.refer_sheet.points.3'.tr(),
                    ]
                    .map(
                      (points) => Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: context.colors.onPrimaryContainer,
                              shape: BoxShape.circle,
                            ),
                            width: 5,
                            height: 5,
                          ),
                          SizedBox(width: context.spacing.sm),
                          Text(
                            points,
                            style: context.text.bodySmall!.copyWith(
                              color: context.colors.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
          ),
          SizedBox(height: context.spacing.md),
          DottedBorder(
            borderType: BorderType.Rect,
            color: Theme.of(context).colorScheme.primary,
            dashPattern: const [6, 3],
            radius: Radius.circular(context.radii.md),
            strokeWidth: 2,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.sm,
                vertical: context.spacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _referralCode,
                    style: context.text.titleMedium!.copyWith(
                      color: context.colors.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: context.spacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: copyCode,
                            child: Text('profile.refer_sheet.copy'.tr()),
                          ),
                        ),
                      ),
                      SizedBox(width: context.spacing.sm),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colors.secondary,
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: shareViaSheet,
                            child: Text('profile.refer_sheet.share'.tr()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: context.spacing.md),
          Text(
            'profile.refer_sheet.share_your_code'.tr(),
            style: context.text.titleMedium!.copyWith(
              color: context.colors.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: context.spacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_installedApps[_DirectShareApp.whatsapp] == true)
                InkWell(
                  onTap: () => shareToApp(_DirectShareApp.whatsapp),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacing.sm,
                      vertical: context.spacing.sm,
                    ),
                    child: SvgPicture.asset(
                      "assets/icons/ic_share_whatsapp.svg",
                    ),
                  ),
                ),
              if (_installedApps[_DirectShareApp.facebook] == true)
                InkWell(
                  onTap: () => shareToApp(_DirectShareApp.facebook),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacing.sm,
                      vertical: context.spacing.sm,
                    ),
                    child: SvgPicture.asset(
                      "assets/icons/ic_share_facebook.svg",
                    ),
                  ),
                ),
              if (_installedApps[_DirectShareApp.linkedin] == true)
                InkWell(
                  onTap: () => shareToApp(_DirectShareApp.linkedin),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacing.sm,
                      vertical: context.spacing.sm,
                    ),
                    child: SvgPicture.asset(
                      "assets/icons/ic_share_linkedin.svg",
                    ),
                  ),
                ),
              if (_installedApps[_DirectShareApp.telegram] == true)
                InkWell(
                  onTap: () => shareToApp(_DirectShareApp.telegram),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacing.sm,
                      vertical: context.spacing.sm,
                    ),
                    child: SvgPicture.asset(
                      "assets/icons/ic_share_telegram.svg",
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _DirectShareApp { whatsapp, facebook, linkedin, telegram }
