import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/theme/context_ext.dart';

import '../../common/widgets/language_selector.dart';
import '../../settings/providers/language_provider.dart';

class UpdateLanguageDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UpdateLanguageDialogState();
}

class _UpdateLanguageDialogState extends State<UpdateLanguageDialog> {
  late AppLanguage _pendingLanguage;

  @override
  void initState() {
    super.initState();
    _pendingLanguage = context.read<LanguageProvider>().language;
  }

  String _t(String en, String hi) =>
      _pendingLanguage == AppLanguage.hi ? hi : en;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colors.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _t('Change Language', 'भाषा बदलें'),
              style: context.text.bodyMedium!.copyWith(
                color: context.colors.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: context.spacing.sm),
            Text(
              _t(
                'Choose your language to personalize your experience',
                'अपना अनुभव बेहतर करने के लिए भाषा चुनें',
              ),
              textAlign: TextAlign.center,
              style: context.text.bodySmall!.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: context.spacing.md),
            LanguageSelector(
              selectedLanguage: _pendingLanguage,
              onLanguageChanged: (lang) => setState(() => _pendingLanguage = lang),
            ),
            SizedBox(height: context.spacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final provider = context.read<LanguageProvider>();
                  provider.setLanguage(_pendingLanguage);
                  context.setLocale(
                    _pendingLanguage == AppLanguage.hi
                        ? const Locale('hi')
                        : const Locale('en'),
                  );
                  Navigator.of(context).pop();
                },
                child: Text(_t('Change Language', 'भाषा बदलें')),
              ),
            ),
            SizedBox(height: context.spacing.xs),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.secondaryContainer,
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  _t('Cancel', 'रद्द करें'),
                  style: context.text.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
