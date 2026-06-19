import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/auth/utils/account_status_guard.dart';
import 'package:rotijugaad/employees/providers/employees_provider.dart';
import 'package:rotijugaad/experiences/screens/add_new_experience_screen.dart';
import 'package:rotijugaad/experiences/widgets/update_experience_item.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/utils/i18n_terms.dart';
import 'package:rotijugaad/utils/shared_pref.dart';

import '../../common/widgets/app_shimmer_placeholders.dart';
import '../../common/widgets/toolbar.dart';

class UpdateExperienceScreen extends StatefulWidget {
  const UpdateExperienceScreen({super.key});

  @override
  State<StatefulWidget> createState() => _UpdateExperienceScreenState();
}

class _UpdateExperienceScreenState extends State<UpdateExperienceScreen> {
  int? _employeeId;

  bool _initialLoading = true;
  bool _initialRequestSent = false;

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  String _pickLang(String? en, String? hi) {
    final isHindi = context.locale.languageCode.toLowerCase() == 'hi';
    final primary = (isHindi ? hi : en)?.trim() ?? '';
    if (primary.isNotEmpty) return primary;
    return ((isHindi ? en : hi) ?? '').trim();
  }

  String _formatDuration(double? duration, String? frequency) {
    final d = duration;
    if (d == null) return '-';
    final n = d % 1 == 0 ? d.toInt().toString() : d.toString();
    final f = I18nTerms.fromRaw(context, (frequency ?? '').trim());
    if (f.isEmpty) return n;
    return '$n $f';
  }

  @override
  void initState() {
    super.initState();

    final profile = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_PROFILE_JSON);
    _employeeId = _asInt(profile?['id'] ?? profile?['employeeId']);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final employeeId = _employeeId;
      if (employeeId == null) return;

      _initialRequestSent = true;
      context.read<EmployeesProvider>().fetchExperiences(employeeId);
    });
  }

  Future<void> _openExperienceForm({int? experienceId}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddNewExperienceScreen(experienceId: experienceId),
      ),
    );

    if (!mounted) return;
    final employeeId = _employeeId;
    if (employeeId == null) return;

    await context.read<EmployeesProvider>().fetchExperiences(employeeId);
  }

  Future<void> _confirmDelete({
    required int employeeId,
    required int experienceId,
  }) async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('profile.flow.delete_experience_title'.tr()),
              content: Text('profile.flow.delete_experience_message'.tr()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('common.cancel'.tr()),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('common.delete'.tr()),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!ok) return;

    if (!mounted) return;

    await context.read<EmployeesProvider>().deleteExperience(
      experienceId,
      employeeId: employeeId,
    );

    if (!mounted) return;
    await AccountStatusGuard.handleIfInactive(context);

    if (!mounted) return;
    final stillLoggedIn = SharedPrefUtils.readBool(
      SharedPrefUtils.AUTH_LOGGED_IN,
    );
    if (!stillLoggedIn) return;
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = _employeeId;

    return Scaffold(
      backgroundColor: context.colors.onPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Toolbar('profile.actions.update_experiences'.tr(), () {
              Navigator.of(context).pop();
            }),
            Divider(color: context.xcolors.stroke),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: context.spacing.md),
                child: employeeId == null
                    ? Center(
                        child: Text(
                          'profile.flow.unable_to_load_employee_details'.tr(),
                          style: context.text.bodyMedium,
                        ),
                      )
                    : Consumer<EmployeesProvider>(
                        builder: (context, provider, _) {
                          if (_initialLoading &&
                              _initialRequestSent &&
                              !provider.isLoading) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!mounted) return;
                              if (!_initialLoading) return;
                              setState(() => _initialLoading = false);
                            });
                          }

                          final isBusy =
                              _initialLoading ||
                              (provider.isLoading &&
                                  provider.experiences.isEmpty);

                          if (isBusy) {
                            return const AppListShimmer();
                          }

                          final items = provider.experiences;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: items.isEmpty
                                    ? Center(
                                        child: Text(
                                          provider.lastError?.message ??
                                              'profile.flow.no_experiences_added_yet'
                                                  .tr(),
                                          style: context.text.bodyMedium,
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: items.length,
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
                                          final firmName =
                                              (exp.previousFirm ?? '').trim();

                                          return UpdateExperienceItem(
                                            title: safeTitle,
                                            subtitle: subtitle.isEmpty
                                                ? '-'
                                                : subtitle,
                                            firmName: firmName.isNotEmpty
                                                ? firmName
                                                : null,
                                            durationText: _formatDuration(
                                              exp.workDuration,
                                              exp.workDurationFrequency,
                                            ),
                                            onEdit: () => _openExperienceForm(
                                              experienceId: exp.id,
                                            ),
                                            onDelete: () => _confirmDelete(
                                              employeeId: employeeId,
                                              experienceId: exp.id,
                                            ),
                                          );
                                        },
                                      ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _openExperienceForm(),
                                  child: Text(
                                    'profile.flow.add_new_experience'.tr(),
                                  ),
                                ),
                              ),
                              SizedBox(height: context.spacing.md),
                            ],
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
