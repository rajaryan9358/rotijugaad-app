import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import '../../settings/providers/language_provider.dart';
import '../../theme/app_icons.dart';
import '../../theme/context_ext.dart';
import 'xicon.dart';

class LanguageSelector extends StatelessWidget {
  /// When non-null, this overrides the provider's current language for display.
  /// When null, the widget reads from [LanguageProvider] and applies changes
  /// immediately (original behaviour, used on onboarding/auth screens).
  final AppLanguage? selectedLanguage;

  /// Called when the user taps an option in controlled mode ([selectedLanguage] != null).
  /// In uncontrolled mode this is ignored.
  final ValueChanged<AppLanguage>? onLanguageChanged;

  const LanguageSelector({
    super.key,
    this.selectedLanguage,
    this.onLanguageChanged,
  });

  bool get _isControlled => selectedLanguage != null;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LanguageProvider>();
    final current = _isControlled ? selectedLanguage! : provider.language;

    void select(AppLanguage lang) {
      if (_isControlled) {
        onLanguageChanged?.call(lang);
      } else {
        provider.setLanguage(lang);
        context.setLocale(lang == AppLanguage.hi ? const Locale('hi') : const Locale('en'));
      }
    }

    return Row(
      children: [
        SizedBox(width: context.spacing.sm),
        Expanded(
          child: GestureDetector(
            onTap: () => select(AppLanguage.en),
            child: LanguageSelectOption(
              'Hello',
              'English',
              current == AppLanguage.en,
            ),
          ),
        ),
        SizedBox(width: context.spacing.md),
        Expanded(
          child: GestureDetector(
            onTap: () => select(AppLanguage.hi),
            child: LanguageSelectOption(
              'नमस्ते',
              'हिंदी',
              current == AppLanguage.hi,
            ),
          ),
        ),
        SizedBox(width: context.spacing.sm),
      ],
    );
  }
}

class LanguageSelectOption extends StatelessWidget {
  final String title;
  final String language;
  final bool isSelected;

  const LanguageSelectOption(
    this.title,
    this.language,
    this.isSelected, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.13,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: context.colors.secondaryContainer,
                    border: Border.all(
                      color: isSelected
                          ? context.colors.outline
                          : context.colors.secondaryContainer,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(context.radii.sm),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      title,
                      style: context.text.bodyMedium!.copyWith(
                        color: context.colors.onSecondaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  top: context.spacing.sm,
                  right: context.spacing.sm,
                  child: XIcon(
                    AppIcon.success,
                    size: context.spacing.lg,
                    color: context.colors.primary,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: context.spacing.xs),
        Text(
          language,
          style: context.text.bodyMedium!.copyWith(
            color: isSelected
                ? context.colors.primary
                : context.colors.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}
