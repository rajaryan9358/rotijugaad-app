import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/common/widgets/toolbar.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/masters/models/location_dtos.dart';
import 'package:rotijugaad/masters/models/misc_dtos.dart';

import '../../common/dialogs/primary_dialog.dart';
import '../../common/models/id_name.dart';
import '../../common/widgets/app_dropdown.dart';
import '../../common/widgets/app_button_child.dart';
import '../../common/widgets/app_loading_indicator.dart';
import '../../common/widgets/app_shimmer_placeholders.dart';
import '../../common/widgets/labeled_form_field.dart';
import '../../employers/providers/employers_provider.dart';
import '../../masters/providers/masters_provider.dart';
import '../../utils/shared_pref.dart';
import '../../verifyidentity/screens/employer_verify_identity_screen.dart';
import '../../employerjobs/screens/add_job_screen.dart';
import '../../profile/utils/employer_profile_action_guard.dart';

class EditEmployerProfileOutcome {
  static const String openVerify = 'open_verify';
  static const String openVerifyAndAddJob = 'open_verify_and_add_job';

  static bool shouldOpenVerify(Object? value) {
    return value == openVerify || value == openVerifyAndAddJob;
  }

  static bool shouldOpenAddJob(Object? value) {
    return value == openVerifyAndAddJob;
  }
}

Future<void> handleEditEmployerProfileOutcome(
  BuildContext context,
  Object? outcome,
) async {
  if (!EditEmployerProfileOutcome.shouldOpenVerify(outcome)) return;

  final shouldOpenAddJob = EditEmployerProfileOutcome.shouldOpenAddJob(outcome);

  final goToAddJob = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) =>
          EmployerVerifyIdentityScreen(goToAddJobOnExit: shouldOpenAddJob),
    ),
  );

  if (!context.mounted) return;

  if (shouldOpenAddJob && goToAddJob == true) {
    if (!context.mounted) return;
    if (!await EmployerProfileActionGuard.ensureHasAdCredit(context)) return;
    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const AddJobScreen(clearStackToEmployerHomeOnSuccess: true),
      ),
    );
  }
}

class EditEmployerProfileScreen extends StatefulWidget {
  final bool goToVerifyIdentityOnSuccess;
  final bool goToAddJobAfterVerification;

  const EditEmployerProfileScreen({
    super.key,
    this.goToVerifyIdentityOnSuccess = true,
    this.goToAddJobAfterVerification = false,
  });

  @override
  State<StatefulWidget> createState() => _EditEmployerProfileScreenState();
}

class _EditEmployerProfileScreenState extends State<EditEmployerProfileScreen> {
  String _organizationType = 'firm';

  final _nameController = TextEditingController();
  final _orgNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _assistedByController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isInitLoading = true;
  bool _isCitiesLoading = false;

  List<IdName> _businessCategories = const [];
  List<IdName> _states = const [];
  List<IdName> _cities = const [];

  String? _businessCategoryId;
  String? _stateId;
  String? _cityId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitial();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _orgNameController.dispose();
    _addressController.dispose();
    _assistedByController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  String? _asId(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  void _prefillFromProfile(Map<String, dynamic>? profile) {
    final p = profile ?? const <String, dynamic>{};

    final userJson = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_USER_JSON);
    final fallbackName = (userJson?['name'] ?? '').toString().trim();

    final profileName = (p['name'] ?? '').toString().trim();
    _nameController.text = profileName.isNotEmpty ? profileName : fallbackName;

    final orgType = (p['organization_type'] ?? p['organizationType'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    if (orgType == 'domestic' || orgType == 'firm') {
      _organizationType = orgType;
    }

    _orgNameController.text =
        (p['organization_name'] ?? p['organizationName'] ?? '')
            .toString()
            .trim();
    _addressController.text = (p['address'] ?? '').toString().trim();
    _assistedByController.text = (p['assisted_by'] ?? p['assistedBy'] ?? '')
        .toString()
        .trim();
    _emailController.text = (p['email'] ?? '').toString().trim();

    _businessCategoryId = _asId(
      p['business_category_id'] ?? p['businessCategoryId'],
    );
    _stateId = _asId(p['state_id'] ?? p['stateId']);
    _cityId = _asId(p['city_id'] ?? p['cityId']);
  }

  String _pickLang(String? en, String? hi) {
    final isHindi =
        SharedPrefUtils.readStr(SharedPrefUtils.APP_LANGUAGE).trim() == 'hi';
    final primary = (isHindi ? hi : en)?.trim() ?? '';
    if (primary.isNotEmpty) return primary;
    return (en ?? hi ?? '').trim();
  }

  List<IdName> _statesToItems(List<StateDto> list) {
    return list
        .map(
          (s) => IdName(
            id: s.id.toString(),
            name: _pickLang(s.stateEnglish, s.stateHindi),
          ),
        )
        .where((e) => e.name.trim().isNotEmpty)
        .toList();
  }

  List<IdName> _citiesToItems(List<CityDto> list) {
    return list
        .map(
          (c) => IdName(
            id: c.id.toString(),
            name: _pickLang(c.cityEnglish, c.cityHindi),
          ),
        )
        .where((e) => e.name.trim().isNotEmpty)
        .toList();
  }

  List<IdName> _businessCategoriesToItems(List<BusinessCategoryDto> list) {
    return list
        .map(
          (c) => IdName(
            id: c.id.toString(),
            name: _pickLang(c.categoryEnglish, c.categoryHindi),
          ),
        )
        .where((e) => e.name.trim().isNotEmpty)
        .toList();
  }

  Future<void> _loadCitiesForState(int? stateId) async {
    if (!mounted) return;

    if (stateId == null || stateId <= 0) {
      setState(() {
        _cities = const [];
        _cityId = null;
      });
      return;
    }

    setState(() {
      _isCitiesLoading = true;
      _cities = const [];
    });

    final masters = context.read<MastersProvider>();
    final cities = await masters.getCitiesFromDb(stateId: stateId);

    if (!mounted) return;
    setState(() {
      _cities = _citiesToItems(cities);
      _isCitiesLoading = false;

      final currentCity = _cityId;
      if (currentCity == null) return;
      final ok = _cities.any((e) => e.id == currentCity);
      if (!ok) _cityId = null;
    });
  }

  Future<void> _loadInitial() async {
    final profile = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_PROFILE_JSON);

    setState(() {
      _isInitLoading = true;
    });

    try {
      final masters = context.read<MastersProvider>();
      await masters.loadMasters();

      final states = await masters.getStatesFromDb();
      final categories = await masters.getBusinessCategoriesFromDb();

      if (!mounted) return;
      setState(() {
        _states = _statesToItems(states);
        _businessCategories = _businessCategoriesToItems(categories);
      });

      _prefillFromProfile(profile);

      final stateId = _asInt(_stateId);
      await _loadCitiesForState(stateId > 0 ? stateId : null);
    } catch (_) {
      // keep screen usable even if masters load fails
    }

    if (!mounted) return;
    setState(() {
      _isInitLoading = false;
    });
  }

  Widget _radio(String label, String value) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _organizationType = value;
          });
        },
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _organizationType,
              splashRadius: 0,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _organizationType = v;
                });
              },
            ),
            Flexible(
              child: Text(
                label,
                style: context.text.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final employers = context.watch<EmployersProvider>();
    final isFirm = _organizationType == 'firm';
    final canEditOrganizationName = _orgNameController.text.trim().isEmpty;

    Future<void> submit() async {
      final userJson = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_USER_JSON);
      final userId = _asInt(userJson?['id']);
      if (userId <= 0) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('errors.unable_to_load_user_id'.tr())),
        );
        return;
      }

      final name = _nameController.text.trim();
      if (name.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Name is required')));
        return;
      }

      final address = _addressController.text.trim();
      if (address.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('profile.update.address_required'.tr())),
        );
        return;
      }

      final email = _emailController.text.trim();
      if (email.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('profile.update.email_required'.tr())),
        );
        return;
      }

      final orgName = _orgNameController.text.trim();
      if (isFirm && orgName.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('profile.update.org_required'.tr())),
        );
        return;
      }

      if (isFirm && (_businessCategoryId == null || _asInt(_businessCategoryId) <= 0)) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a business category')),
        );
        return;
      }

      if (_stateId == null || _asInt(_stateId) <= 0) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a state')),
        );
        return;
      }

      if (_cityId == null || _asInt(_cityId) <= 0) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a city')),
        );
        return;
      }

      final body = <String, dynamic>{
        'name': name,
        'organization_type': _organizationType,
        'state_id': _asInt(_stateId) > 0 ? _asInt(_stateId) : null,
        'city_id': _asInt(_cityId) > 0 ? _asInt(_cityId) : null,
        'address': address,
        'assisted_by': _assistedByController.text.trim(),
        'email': email,
      };

      if (isFirm) {
        body['organization_name'] = orgName;
        body['business_category_id'] = _asInt(_businessCategoryId) > 0
            ? _asInt(_businessCategoryId)
            : null;
      }

      final ok = await context
          .read<EmployersProvider>()
          .saveEmployerPersonalInfo(userId, body);

      if (!context.mounted) return;

      if (ok) {
        await showDialog(
          context: context,
          builder: (_) => PrimaryDialog('profile.update.success'.tr()),
        );
        if (!context.mounted) return;
        if (widget.goToVerifyIdentityOnSuccess) {
          final prevStatus = (SharedPrefUtils.readJson(
                    SharedPrefUtils.AUTH_PROFILE_JSON,
                  )?['verification_status'] ??
                  '')
              .toString()
              .trim()
              .toLowerCase();
          final wasRejected = prevStatus == 'rejected';
          Navigator.of(context).pop(
            widget.goToAddJobAfterVerification && !wasRejected
                ? EditEmployerProfileOutcome.openVerifyAndAddJob
                : EditEmployerProfileOutcome.openVerify,
          );
          return;
        } else {
          Navigator.of(context).pop();
        }
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            employers.lastError?.message ?? 'profile.update.unable'.tr(),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.colors.onPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Toolbar('profile.actions.update_profile'.tr(), () {
              Navigator.of(context).pop();
            }),
            Divider(color: context.xcolors.stroke, height: 1),
            Expanded(
              child: _isInitLoading
                  ? AppFormShimmer(padding: EdgeInsets.all(context.spacing.md))
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(context.spacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LabeledFormField(
                            title: 'profile.employer.name'.tr(),
                            controller: _nameController,
                            enabled: false,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'profile.employer.organization_type'.tr(),
                            style: context.text.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.colors.primary,
                            ),
                          ),
                          Row(
                            children: [
                              _radio(
                                'profile.employer.organization_type_firm'.tr(),
                                'firm',
                              ),
                              _radio(
                                'profile.employer.organization_type_domestic'
                                    .tr(),
                                'domestic',
                              ),
                            ],
                          ),
                          if (isFirm) ...[
                            const SizedBox(height: 8),
                            LabeledFormField(
                              title: 'profile.employer.organization_name'.tr(),
                              controller: _orgNameController,
                              enabled: isFirm && canEditOrganizationName,
                            ),
                            const SizedBox(height: 8),
                            AppDropdown(
                              title: 'profile.employer.business_category'.tr(),
                              items: _businessCategories,
                              valueId: _businessCategoryId,
                              hint: 'profile.employer.select_business_category'
                                  .tr(),
                              enabled: isFirm,
                              searchable: true,
                              onChanged: (v) {
                                setState(() {
                                  _businessCategoryId = v?.id;
                                });
                              },
                            ),
                          ],
                          const SizedBox(height: 8),
                          AppDropdown(
                            title: 'profile.employer.state'.tr(),
                            items: _states,
                            valueId: _stateId,
                            searchable: true,
                            hint: 'profile.employer.select_state'.tr(),
                            onChanged: (v) {
                              setState(() {
                                _stateId = v?.id;
                                _cityId = null;
                              });
                              _loadCitiesForState(_asInt(v?.id));
                            },
                          ),
                          const SizedBox(height: 8),
                          if (_isCitiesLoading)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const AppLoadingIndicator.inline(
                                    size: 16,
                                    strokeWidth: 2,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'profile.employer.loading_cities'.tr(),
                                    style: context.text.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          AppDropdown(
                            title: 'profile.employer.city'.tr(),
                            items: _cities,
                            valueId: _cityId,
                            searchable: true,
                            hint: _stateId == null
                                ? 'profile.employer.select_state_first'.tr()
                                : 'profile.employer.select_city'.tr(),
                            enabled: !_isCitiesLoading && (_stateId != null),
                            onChanged: (v) {
                              setState(() {
                                _cityId = v?.id;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          LabeledFormField(
                            title: 'profile.employer.address'.tr(),
                            controller: _addressController,
                            maxLines: 2,
                            height: 72,
                          ),
                          const SizedBox(height: 8),
                          LabeledFormField(
                            title: 'profile.employer.email'.tr(),
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            optional: false,
                          ),
                          const SizedBox(height: 8),
                          LabeledFormField(
                            title: 'profile.employer.assisted_by'.tr(),
                            controller: _assistedByController,
                            optional: true,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: employers.isLoading ? null : submit,
                              child: AppButtonChild(
                                isLoading: employers.isLoading,
                                label: 'profile.actions.update_profile'.tr(),
                                loaderColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
