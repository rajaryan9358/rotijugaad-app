import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/auth/utils/account_status_guard.dart';
import 'package:rotijugaad/common/widgets/app_shimmer_placeholders.dart';
import 'package:rotijugaad/utils/shared_pref.dart';
import 'package:rotijugaad/common/widgets/xicon.dart';
import 'package:rotijugaad/employees/providers/employees_provider.dart';
import 'package:rotijugaad/experiences/widgets/update_experience_item.dart';
import 'package:rotijugaad/theme/app_icons.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/utils/i18n_terms.dart';

class ExperiencesScreen extends StatefulWidget {
  final int employeeId;
  final VoidCallback onButtonClicked;
  final VoidCallback onAddClicked;
  final ValueChanged<int> onEditClicked;

  const ExperiencesScreen({
    super.key,
    required this.employeeId,
    required this.onButtonClicked,
    required this.onAddClicked,
    required this.onEditClicked,
  });

  @override
  State<StatefulWidget> createState() => _ExperiencesScreenState();
}

class _ExperiencesScreenState extends State<ExperiencesScreen> {
  bool _initialLoading = true;
  bool _initialRequestSent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialRequestSent = true;
      context.read<EmployeesProvider>().fetchExperiences(widget.employeeId);
    });
  }

  String _pickLang(String? en, String? hi) {
    final isHindi = context.locale.languageCode.toLowerCase() == 'hi';
    final primary = (isHindi ? hi : en)?.trim() ?? '';
    if (primary.isNotEmpty) return primary;
    return ((isHindi ? en : hi) ?? '').trim();
  }

  String? _formatDuration(double? duration, String? frequency) {
    final d = duration;
    if (d == null) return null;
    final n = d % 1 == 0 ? d.toInt().toString() : d.toString();
    final f = I18nTerms.fromRaw(context, (frequency ?? '').trim());
    if (f.isEmpty) return n;
    return '$n $f';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmployeesProvider>(
      builder: (context, provider, _) {
        if (_initialLoading && _initialRequestSent && !provider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            if (!_initialLoading) return;
            setState(() => _initialLoading = false);
          });
        }

        if (_initialLoading ||
            (provider.isLoading && provider.experiences.isEmpty)) {
          return const SafeArea(child: AppListShimmer());
        }

        final items = provider.experiences;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListView.builder(
                      itemCount: items.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final exp = items[index];
                        final title = _pickLang(
                          exp.workNature?.natureEnglish,
                          exp.workNature?.natureHindi,
                        );
                        final safeTitle = title.isEmpty
                            ? 'profile.flow.experience'.tr()
                            : title;
                        final subtitle = _pickLang(
                          exp.documentType?.typeEnglish,
                          exp.documentType?.typeHindi,
                        );
                        final firmName = (exp.previousFirm ?? '').trim();

                        return UpdateExperienceItem(
                          title: safeTitle,
                          subtitle: subtitle.isEmpty ? null : subtitle,
                          firmName: firmName.isNotEmpty ? firmName : null,
                          durationText: _formatDuration(
                            exp.workDuration,
                            exp.workDurationFrequency,
                          ),
                          onEdit: () => widget.onEditClicked(exp.id),
                          onDelete: () async {
                            await context
                                .read<EmployeesProvider>()
                                .deleteExperience(
                                  exp.id,
                                  employeeId: widget.employeeId,
                                );
                            await AccountStatusGuard.handleIfInactive(context);

                            if (!mounted) return;
                            final stillLoggedIn = SharedPrefUtils.readBool(
                              SharedPrefUtils.AUTH_LOGGED_IN,
                            );
                            if (!stillLoggedIn) return;
                          },
                        );
                      },
                    ),
                    SizedBox(height: context.spacing.md),
                    InkWell(
                      onTap: widget.onAddClicked,
                      child: Row(
                        children: [
                          XIcon(
                            AppIcon.addMore,
                            color: context.colors.secondary,
                            size: 20,
                          ),
                          SizedBox(width: context.spacing.xs),
                          Text(
                            'profile.flow.add_more_experience'.tr(),
                            style: context.text.bodyMedium!.copyWith(
                              color: context.colors.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: context.spacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onButtonClicked,
                child: Text('common.next'.tr()),
              ),
            ),
            SizedBox(height: context.spacing.md),
          ],
        );
      },
    );
  }
}
