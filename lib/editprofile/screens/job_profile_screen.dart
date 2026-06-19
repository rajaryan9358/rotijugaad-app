import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/auth/utils/account_status_guard.dart';
import 'package:rotijugaad/employees/providers/employees_provider.dart';
import 'package:rotijugaad/masters/models/job_profile_dtos.dart';
import 'package:rotijugaad/masters/providers/masters_provider.dart';
import 'package:rotijugaad/network/api_client.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/utils/shared_pref.dart';

import '../../common/widgets/app_button_child.dart';
import '../../common/widgets/app_shimmer_placeholders.dart';
import '../../preferences/widgets/update_preference_item.dart';

class JobProfileScreen extends StatefulWidget {
  final int employeeId;
  final VoidCallback onButtonClicked;
  final String submitButtonText;
  final bool showBackButtonOnLoading;

  const JobProfileScreen({
    super.key,
    required this.employeeId,
    required this.onButtonClicked,
    this.submitButtonText = 'Next',
    this.showBackButtonOnLoading = true,
  });

  @override
  State<StatefulWidget> createState() => _JobProfileScreenState();
}

class _JobProfileScreenState extends State<JobProfileScreen> {
  bool _futureInitialized = false;
  bool _prefilled = false;

  bool _initialLoading = true;
  bool _initialRequestSent = false;
  bool _isSaving = false;

  late Future<List<JobProfileDto>> _jobProfilesFuture;
  Set<String> _selectedIds = const {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialRequestSent = true;
      context.read<EmployeesProvider>().fetchJobProfiles(widget.employeeId);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_futureInitialized) return;
    _futureInitialized = true;

    final masters = context.read<MastersProvider>();
    masters.loadMasters();
    _jobProfilesFuture = masters.getJobProfilesFromDb();
  }

  void _toggle(String id) {
    setState(() {
      final next = {..._selectedIds};
      if (next.contains(id)) {
        next.remove(id);
      } else {
        if (next.length >= 3) return;
        next.add(id);
      }
      _selectedIds = next;
    });
  }

  String? _resolveImageUrl(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) return value;
    if (value.startsWith('/')) return '${ApiClient.baseUrl}$value';
    return '${ApiClient.baseUrl}/$value';
  }

  String _pickLang(String? en, String? hi) {
    final isHindi = context.locale.languageCode.toLowerCase() == 'hi';
    final primary = (isHindi ? hi : en)?.trim() ?? '';
    if (primary.isNotEmpty) return primary;
    return ((isHindi ? en : hi) ?? '').trim();
  }

  String get _submitButtonLabel {
    switch (widget.submitButtonText) {
      case 'Next':
        return 'common.next'.tr();
      case 'Save':
        return 'common.save'.tr();
      default:
        return widget.submitButtonText;
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
            (provider.isLoading && !_prefilled && !_isSaving)) {
          return SafeArea(
            child: Stack(
              children: [
                const AppFormShimmer(),
                if (widget.showBackButtonOnLoading)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
              ],
            ),
          );
        }

        if (!_prefilled &&
            _initialRequestSent &&
            !_initialLoading &&
            !provider.isLoading) {
          _prefilled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              _selectedIds = provider.jobProfiles
                  .map((p) => p.id.toString())
                  .toSet();
            });
          });
        }

        return Column(
          children: [
            SizedBox(height: context.spacing.xs),
            Text(
              'profile.flow.select_upto_three_job_profiles'.tr(),
              style: context.text.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.spacing.md),
            Expanded(
              child: FutureBuilder<List<JobProfileDto>>(
                future: _jobProfilesFuture,
                builder: (context, snapshot) {
                  final profiles = snapshot.data ?? const <JobProfileDto>[];

                  return GridView.builder(
                    shrinkWrap: true,
                    itemCount: profiles.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                    itemBuilder: (context, index) {
                      final p = profiles[index];
                      final id = p.id.toString();
                      final selected = _selectedIds.contains(id);

                      return GestureDetector(
                        onTap: () => _toggle(id),
                        child: UpdatePreferenceItem(
                          selected,
                          title: _pickLang(p.profileEnglish, p.profileHindi),
                          imageUrl: _resolveImageUrl(p.profileImage),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: context.spacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : () async {
                        if (_selectedIds.isEmpty) {
                          _snack(
                            'profile.flow.select_at_least_one_job_profile'.tr(),
                          );
                          return;
                        }

                        setState(() => _isSaving = true);
                        try {
                          final ids = _selectedIds
                              .map((e) => int.tryParse(e))
                              .whereType<int>()
                              .toList();

                          await context
                              .read<EmployeesProvider>()
                              .saveJobProfiles(
                                employeeId: widget.employeeId,
                                jobProfileIds: ids,
                              );

                          if (!context.mounted) return;
                          await AccountStatusGuard.handleIfInactive(context);

                          if (!context.mounted) return;
                          final stillLoggedIn = SharedPrefUtils.readBool(
                            SharedPrefUtils.AUTH_LOGGED_IN,
                          );
                          if (!stillLoggedIn) return;

                          widget.onButtonClicked();
                        } finally {
                          if (mounted) {
                            setState(() => _isSaving = false);
                          }
                        }
                      },
                child: AppButtonChild(
                  label: _submitButtonLabel,
                  isLoading: _isSaving,
                ),
              ),
            ),
            SizedBox(height: context.spacing.md),
          ],
        );
      },
    );
  }
}
