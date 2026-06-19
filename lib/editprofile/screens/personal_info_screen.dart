import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/common/models/id_name.dart';
import 'package:rotijugaad/common/widgets/app_dropdown.dart';
import 'package:rotijugaad/common/widgets/app_button_child.dart';
import 'package:rotijugaad/common/widgets/app_shimmer_placeholders.dart';
import 'package:rotijugaad/common/widgets/chips_selector.dart';
import 'package:rotijugaad/common/widgets/expected_salary_field.dart';
import 'package:rotijugaad/common/widgets/gender_selector.dart';
import 'package:rotijugaad/common/widgets/labeled_form_field.dart';
import 'package:rotijugaad/common/widgets/xicon.dart';
import 'package:rotijugaad/auth/utils/account_status_guard.dart';
import 'package:rotijugaad/utils/shared_pref.dart';
import 'package:rotijugaad/employees/models/employee_dtos.dart';
import 'package:rotijugaad/employees/providers/employees_provider.dart';
import 'package:rotijugaad/masters/models/location_dtos.dart';
import 'package:rotijugaad/masters/models/misc_dtos.dart';
import 'package:rotijugaad/masters/models/work_dtos.dart';
import 'package:rotijugaad/masters/providers/masters_provider.dart';
import 'package:rotijugaad/theme/app_icons.dart';
import 'package:rotijugaad/common/widgets/places_autocomplete_field.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class PersonalInfoScreen extends StatefulWidget {
  final int userId;
  final ValueChanged<int> onContinue;
  final String submitButtonText;
  final bool showBackButtonOnLoading;

  const PersonalInfoScreen({
    super.key,
    required this.userId,
    required this.onContinue,
    this.submitButtonText = 'Continue to Job Profile',
    this.showBackButtonOnLoading = true,
  });

  @override
  State<StatefulWidget> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  bool _futuresInitialized = false;
  bool _prefilled = false;

  bool _initialLoading = true;
  bool _initialRequestSent = false;
  bool _isSaving = false;

  late Future<List<StateDto>> _statesFuture;
  late Future<List<SkillDto>> _skillsFuture;
  late Future<List<QualificationDto>> _qualificationsFuture;
  late Future<List<SalaryTypeDto>> _salaryTypesFuture;
  late Future<List<ShiftDto>> _shiftsFuture;

  Future<List<CityDto>> _citiesFuture = Future.value(const []);
  Future<List<CityDto>> _preferredCitiesFuture = Future.value(const []);

  String? _stateId;
  String? _cityId;

  bool _sameAsCurrentState = true;
  bool _sameAsCurrentCity = true;

  String? _preferredStateId;
  String? _preferredCityId;

  final TextEditingController _preferredLocationController = TextEditingController();
  double? _lat;
  double? _lng;

  Set<String> _selectedSkillIds = const {};
  bool _skillsTouched = false;
  String _skillsSignature = "";
  String? _qualificationId;

  final TextEditingController _salaryAmountController = TextEditingController();
  int? _salaryTypeId;
  String? _salaryFrequency;

  String? _shiftId;

  Gender? _gender;

  final TextEditingController _nameController = TextEditingController();

  String get _submitButtonLabel {
    switch (widget.submitButtonText) {
      case 'Continue to Job Profile':
        return 'profile.employee.continue_to_job_profile'.tr();
      case 'Update Profile':
        return 'profile.actions.update_profile'.tr();
      default:
        return widget.submitButtonText;
    }
  }

  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _assistantCodeController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  bool get _isEditProfile => widget.submitButtonText == 'Update Profile';

  int? _asInt(String? v) => v == null ? null : int.tryParse(v);

  String _pickLang(String? en, String? hi) {
    final isHindi = context.locale.languageCode.toLowerCase() == 'hi';
    final primary = (isHindi ? hi : en)?.trim() ?? '';
    if (primary.isNotEmpty) return primary;
    return ((isHindi ? en : hi) ?? '').trim();
  }

  String _normalizeSalaryFrequency(String? raw) {
    final value = (raw ?? '').trim().toLowerCase();
    switch (value) {
      case 'month':
      case 'monthly':
      case 'per month':
      case '/month':
      case '/months':
        return 'month';
      case 'week':
      case 'weekly':
      case 'per week':
      case '/week':
      case '/weeks':
        return 'week';
      case 'day':
      case 'daily':
      case 'per day':
      case '/day':
      case '/days':
        return 'day';
      default:
        return value;
    }
  }

  String _salaryTypeKey(SalaryTypeDto item) {
    final fromEnglish = _normalizeSalaryFrequency(item.typeEnglish);
    if (fromEnglish.isNotEmpty) return fromEnglish;
    return _normalizeSalaryFrequency(item.typeHindi);
  }

  String _salaryTypeDisplayLabel(SalaryTypeDto item) {
    switch (_salaryTypeKey(item)) {
      case 'month':
        return 'Month';
      case 'week':
        return 'Week';
      case 'day':
        return 'Day';
      default:
        final fallback = _pickLang(item.typeEnglish, item.typeHindi).trim();
        if (fallback.isEmpty) return '';
        return fallback[0].toUpperCase() + fallback.substring(1);
    }
  }

  List<SalaryTypeDto> _salaryTypeOptions(List<SalaryTypeDto> list) {
    const order = <String>['month', 'week', 'day'];
    final byKey = <String, SalaryTypeDto>{};

    for (final item in list) {
      final key = _salaryTypeKey(item);
      if (order.contains(key) && !byKey.containsKey(key)) {
        byKey[key] = item;
      }
    }

    return [
      for (final key in order)
        if (byKey.containsKey(key)) byKey[key]!,
    ];
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

  List<IdName> _skillsToItems(List<SkillDto> list) {
    return list
        .map(
          (s) => IdName(
            id: s.id.toString(),
            name: _pickLang(s.skillEnglish, s.skillHindi),
          ),
        )
        .where((e) => e.name.trim().isNotEmpty)
        .toList();
  }

  List<IdName> _qualificationsToItems(List<QualificationDto> list) {
    return list
        .map(
          (q) => IdName(
            id: q.id.toString(),
            name: _pickLang(q.qualificationEnglish, q.qualificationHindi),
          ),
        )
        .where((e) => e.name.trim().isNotEmpty)
        .toList();
  }

  List<IdName> _shiftsToItems(List<ShiftDto> list) {
    return list
        .map(
          (s) => IdName(
            id: s.id.toString(),
            name: _pickLang(s.shiftEnglish, s.shiftHindi),
          ),
        )
        .where((e) => e.name.trim().isNotEmpty)
        .toList();
  }

  SalaryTypeDto? _selectedSalaryType(List<SalaryTypeDto> options) {
    final id = _salaryTypeId;
    if (id == null) return null;

    for (final it in options) {
      if (it.id == id) return it;
    }

    return null;
  }

  void _refreshCitiesFutures() {
    final masters = context.read<MastersProvider>();
    _citiesFuture = masters.getCitiesFromDb(stateId: _asInt(_stateId));
    _preferredCitiesFuture = masters.getCitiesFromDb(
      stateId: _asInt(_preferredStateId),
    );
  }

  Gender? _genderFromRaw(String? raw) {
    final g = (raw ?? '').trim().toLowerCase();
    switch (g) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      default:
        return null;
    }
  }

  String? _rawFromGender(Gender? g) {
    switch (g) {
      case Gender.male:
        return 'male';
      case Gender.female:
        return 'female';
      default:
        return null;
    }
  }

  Set<String> _skillIdsFromEmployee(EmployeeDto emp) {
    final skillIds = emp.skillIds.isNotEmpty
        ? emp.skillIds
        : emp.selectedSkills.map((e) => e.id).where((id) => id > 0).toList();
    return skillIds.map((e) => e.toString()).toSet();
  }

  String _signatureFor(Set<String> ids) {
    if (ids.isEmpty) return '';
    final list = ids.toList()..sort();
    return list.join(',');
  }

  void _prefill(EmployeeDto emp) {
    if (_prefilled) return;
    _prefilled = true;

    final incomingName = (emp.name ?? '').trim();
    if (incomingName.isNotEmpty) {
      _nameController.text = incomingName;
    }

    final rawDob = (emp.dob ?? '').trim();
    if (rawDob.isNotEmpty) {
      final parsed = DateTime.tryParse(rawDob);
      _dobController.text = parsed != null
          ? DateFormat('dd-MMM-yyyy').format(parsed)
          : rawDob;
    }
    _gender = _genderFromRaw(emp.gender);

    _stateId = emp.stateId?.toString();
    _cityId = emp.cityId?.toString();

    _preferredStateId = emp.preferredStateId?.toString();
    _preferredCityId = emp.preferredCityId?.toString();

    final loc = (emp.preferredLocation ?? '').trim();
    if (loc.isNotEmpty) _preferredLocationController.text = loc;
    _lat = double.tryParse(emp.raw['lat']?.toString() ?? '');
    _lng = double.tryParse(emp.raw['lng']?.toString() ?? '');

    _sameAsCurrentState =
        (_preferredStateId == null || _preferredStateId == _stateId);
    _sameAsCurrentCity =
        (_preferredCityId == null || _preferredCityId == _cityId);

    _selectedSkillIds = _skillIdsFromEmployee(emp);
    _skillsSignature = _signatureFor(_selectedSkillIds);
    _qualificationId = emp.qualificationId?.toString();

    if (emp.expectedSalary != null) {
      final s = emp.expectedSalary!;
      _salaryAmountController.text = s % 1 == 0
          ? s.toInt().toString()
          : s.toString();
    }

    _salaryFrequency = _normalizeSalaryFrequency(emp.expectedSalaryFrequency);

    _shiftId = emp.preferredShiftId?.toString();

    _assistantCodeController.text = (emp.assistantCode ?? '').trim();
    _emailController.text = (emp.email ?? '').trim();
    _aboutController.text = (emp.aboutUser ?? '').trim();

    _refreshCitiesFutures();
  }

  @override
  void initState() {
    super.initState();

    final userJson = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_USER_JSON);
    final initialName = (userJson?['name'] ?? '').toString().trim();
    if (initialName.isNotEmpty) {
      _nameController.text = initialName;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialRequestSent = true;
      context.read<EmployeesProvider>().fetchPersonalInfo(widget.userId);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_futuresInitialized) return;
    _futuresInitialized = true;

    final masters = context.read<MastersProvider>();
    masters.loadMasters();

    _statesFuture = masters.getStatesFromDb();
    _skillsFuture = masters.getSkillsFromDb();
    _qualificationsFuture = masters.getQualificationsFromDb();
    _salaryTypesFuture = masters.getSalaryTypesFromDb();
    _shiftsFuture = masters.getShiftsFromDb();

    _refreshCitiesFutures();
  }

  void _onStateChanged(IdName? v) {
    setState(() {
      _stateId = (v?.id.isNotEmpty ?? false) ? v!.id : null;
      _cityId = null;

      if (_sameAsCurrentState) {
        _preferredStateId = _stateId;
        _preferredCityId = null;
        _sameAsCurrentCity = true;
      }

      _refreshCitiesFutures();
    });
  }

  void _onCityChanged(IdName? v) {
    setState(() {
      _cityId = (v?.id.isNotEmpty ?? false) ? v!.id : null;
      if (_sameAsCurrentCity) {
        _preferredCityId = _cityId;
      }
    });
  }

  void _onPreferredStateChanged(IdName? v) {
    setState(() {
      _preferredStateId = (v?.id.isNotEmpty ?? false) ? v!.id : null;
      _preferredCityId = null;
      _refreshCitiesFutures();
    });
  }

  void _onPreferredCityChanged(IdName? v) {
    setState(() {
      _preferredCityId = (v?.id.isNotEmpty ?? false) ? v!.id : null;
    });
  }

  void _toggleSameAsCurrentState(bool? checked) {
    setState(() {
      _sameAsCurrentState = checked ?? false;

      if (_sameAsCurrentState) {
        _preferredStateId = _stateId;
        _sameAsCurrentCity = true;
        _preferredCityId = _cityId;
      } else {
        _preferredStateId = null;
        _preferredCityId = null;
        _sameAsCurrentCity = false;
      }

      _refreshCitiesFutures();
    });
  }

  void _toggleSameAsCurrentCity(bool? checked) {
    setState(() {
      _sameAsCurrentCity = checked ?? false;

      if (_sameAsCurrentCity) {
        _sameAsCurrentState = true;
        _preferredStateId = _stateId;
        _preferredCityId = _cityId;
      } else {
        _preferredCityId = null;
      }

      _refreshCitiesFutures();
    });
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  double? _parseAmount(String s) {
    final raw = s.replaceAll(',', '').trim();
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  DateTime? _parseDob(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return null;
    // Try display format first (dd-MMM-yyyy), then ISO fallback
    try {
      return DateFormat('dd-MMM-yyyy').parseStrict(raw);
    } catch (_) {}
    return DateTime.tryParse(raw);
  }

  bool _isAtLeast18YearsOld(String value) {
    final dob = _parseDob(value);
    if (dob == null) return false;

    final today = DateTime.now();
    var age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age -= 1;
    }
    return age >= 18;
  }

  DateTime get _latestAllowedDob {
    final now = DateTime.now();
    return DateTime(now.year - 18, now.month, now.day);
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _snack('profile.employee.name_required'.tr());
      return;
    }

    if (_dobController.text.trim().isEmpty) {
      _snack('profile.employee.dob_required'.tr());
      return;
    }

    if (!_isAtLeast18YearsOld(_dobController.text.trim())) {
      _snack('profile.employee.dob_minimum_age'.tr());
      return;
    }

    if (_gender == null) {
      _snack('profile.employee.gender_required'.tr());
      return;
    }

    if ((_stateId ?? '').isEmpty) {
      _snack('profile.employee.state_required'.tr());
      return;
    }

    if ((_cityId ?? '').isEmpty) {
      _snack('profile.employee.city_required'.tr());
      return;
    }

    final effectivePreferredStateId = _sameAsCurrentState
        ? _stateId
        : _preferredStateId;
    if ((effectivePreferredStateId ?? '').isEmpty) {
      _snack('profile.employee.preferred_state_required'.tr());
      return;
    }

    final effectivePreferredCityId = _sameAsCurrentCity
        ? _cityId
        : _preferredCityId;
    if ((effectivePreferredCityId ?? '').isEmpty) {
      _snack('profile.employee.preferred_city_required'.tr());
      return;
    }

    if (_preferredLocationController.text.trim().isEmpty) {
      _snack('profile.employee.preferred_location_required'.tr());
      return;
    }

    if ((_qualificationId ?? '').isEmpty) {
      _snack('profile.employee.qualification_required'.tr());
      return;
    }

    if (_parseAmount(_salaryAmountController.text) == null) {
      _snack('profile.employee.expected_salary_required'.tr());
      return;
    }

    if ((_shiftId ?? '').isEmpty) {
      _snack('profile.employee.shift_required'.tr());
      return;
    }

    final gender = _rawFromGender(_gender);

    final body = <String, dynamic>{
      'name': name,
      'dob': () {
        final raw = _dobController.text.trim();
        if (raw.isEmpty) return null;
        final parsed = _parseDob(raw);
        return parsed != null ? DateFormat('yyyy-MM-dd').format(parsed) : null;
      }(),
      'gender': gender,
      'state_id': _asInt(_stateId),
      'city_id': _asInt(_cityId),
      'preferred_state_id': _asInt(effectivePreferredStateId),
      'preferred_city_id': _asInt(effectivePreferredCityId),
      'preferred_location': _preferredLocationController.text.trim().isEmpty ? null : _preferredLocationController.text.trim(),
      if (_lat != null) 'lat': _lat,
      if (_lng != null) 'lng': _lng,
      'qualification_id': _asInt(_qualificationId),
      'expected_salary': _parseAmount(_salaryAmountController.text),
      'expected_salary_frequency': (_salaryFrequency ?? '').trim().isEmpty
          ? null
          : _normalizeSalaryFrequency(_salaryFrequency),
      'preferred_shift_id': _asInt(_shiftId),
      'assistant_code': _assistantCodeController.text.trim().isEmpty
          ? null
          : _assistantCodeController.text.trim(),
      'email': _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      'about_user': _aboutController.text.trim().isEmpty
          ? null
          : _aboutController.text.trim(),
      'is_edit_profile': _isEditProfile,
      'skill_ids': _selectedSkillIds
          .map((e) => int.tryParse(e))
          .whereType<int>()
          .toList(),
    };

    final updated = await context.read<EmployeesProvider>().savePersonalInfo(
      userId: widget.userId,
      body: body,
    );

    if (!mounted) return;

    if (updated == null) {
      final msg =
          context.read<EmployeesProvider>().lastError?.message ??
          'profile.employee.failed_to_save'.tr();
      _snack(msg);
      return;
    }

    await AccountStatusGuard.handleIfInactive(context);

    if (!mounted) return;
    final stillLoggedIn = SharedPrefUtils.readBool(
      SharedPrefUtils.AUTH_LOGGED_IN,
    );
    if (!stillLoggedIn) return;

    widget.onContinue(updated.id);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _salaryAmountController.dispose();
    _dobController.dispose();
    _assistantCodeController.dispose();
    _emailController.dispose();
    _aboutController.dispose();
    _preferredLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateSelected = (_stateId ?? '').isNotEmpty;
    final preferredStateSelected = (_preferredStateId ?? '').isNotEmpty;

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

        final info = provider.personalInfo;
        if (info != null) {
          final incoming = _skillIdsFromEmployee(info);
          final incomingSig = _signatureFor(incoming);

          if (!_prefilled) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() => _prefill(info));
            });
          } else if (!_skillsTouched && incomingSig != _skillsSignature) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              if (_skillsTouched) return;
              if (incomingSig == _skillsSignature) return;
              setState(() {
                _selectedSkillIds = incoming;
                _skillsSignature = incomingSig;
              });
            });
          }
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabeledFormField(
                      title: 'profile.employee.name'.tr(),
                      hintText: 'profile.employee.enter_name'.tr(),
                      controller: _nameController,
                      enabled: !_isEditProfile,
                    ),
                    SizedBox(height: context.spacing.sm),
                    LabeledFormField(
                      title: 'profile.employee.date_of_birth'.tr(),
                      hintText: 'profile.employee.select_date_of_birth'.tr(),
                      controller: _dobController,
                      enabled: !_isEditProfile,
                      prefixIcon: XIcon(AppIcon.date),
                      pickerMode: _isEditProfile
                          ? FieldPickerMode.none
                          : FieldPickerMode.date,
                      dateFormat: DateFormat('dd-MMM-yyyy'),
                      lastDate: _latestAllowedDob,
                      readOnly: _isEditProfile,
                    ),
                    SizedBox(height: context.spacing.sm),
                    GenderSelector(
                      title: 'profile.employee.gender'.tr(),
                      value: _gender,
                      enabled: !_isEditProfile,
                      onChanged: (gender) => setState(() => _gender = gender),
                    ),
                    SizedBox(height: context.spacing.sm),
                    FutureBuilder<List<StateDto>>(
                      future: _statesFuture,
                      builder: (context, snapshot) {
                        final items = _statesToItems(snapshot.data ?? const []);
                        return AppDropdown(
                          title: 'profile.employee.state'.tr(),
                          items: items,
                          valueId: _stateId,
                          searchable: true,
                          hint: 'profile.employee.select_state'.tr(),
                          onChanged: _onStateChanged,
                        );
                      },
                    ),
                    SizedBox(height: context.spacing.sm),
                    FutureBuilder<List<CityDto>>(
                      future: _citiesFuture,
                      builder: (context, snapshot) {
                        final items = _citiesToItems(snapshot.data ?? const []);
                        return AppDropdown(
                          title: 'profile.employee.city'.tr(),
                          items: items,
                          valueId: _cityId,
                          searchable: true,
                          enabled: stateSelected,
                          hint: stateSelected
                              ? 'profile.employee.select_city'.tr()
                              : 'profile.employee.select_state_first'.tr(),
                          onChanged: _onCityChanged,
                        );
                      },
                    ),
                    SizedBox(height: context.spacing.sm),
                    FutureBuilder<List<StateDto>>(
                      future: _statesFuture,
                      builder: (context, snapshot) {
                        final items = _statesToItems(snapshot.data ?? const []);
                        final effectivePreferredStateId = _sameAsCurrentState
                            ? _stateId
                            : _preferredStateId;

                        return AppDropdown(
                          title: 'profile.employee.preferred_state'.tr(),
                          hint: 'profile.employee.select_preferred_state'.tr(),
                          items: items,
                          valueId: effectivePreferredStateId,
                          searchable: true,
                          enabled: !_sameAsCurrentState,
                          onChanged: _onPreferredStateChanged,
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: _sameAsCurrentState,
                          onChanged: _toggleSameAsCurrentState,
                          visualDensity: const VisualDensity(
                            horizontal: -4,
                            vertical: -4,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'profile.employee.same_as_current_state'.tr(),
                          style: context.text.bodyMedium!.copyWith(
                            color: context.colors.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.spacing.md),
                    FutureBuilder<List<CityDto>>(
                      future: _sameAsCurrentState
                          ? _citiesFuture
                          : _preferredCitiesFuture,
                      builder: (context, snapshot) {
                        final items = _citiesToItems(snapshot.data ?? const []);
                        final effectivePreferredCityId = _sameAsCurrentCity
                            ? _cityId
                            : _preferredCityId;

                        final enablePreferredCity =
                            !_sameAsCurrentCity &&
                            (_sameAsCurrentState
                                ? stateSelected
                                : preferredStateSelected);

                        return AppDropdown(
                          title: 'profile.employee.preferred_city'.tr(),
                          hint: enablePreferredCity
                              ? 'profile.employee.select_preferred_city'.tr()
                              : 'profile.employee.select_preferred_state_first'
                                    .tr(),
                          items: items,
                          valueId: effectivePreferredCityId,
                          searchable: true,
                          enabled: enablePreferredCity,
                          onChanged: _onPreferredCityChanged,
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: _sameAsCurrentCity,
                          onChanged: _toggleSameAsCurrentCity,
                          visualDensity: const VisualDensity(
                            horizontal: -4,
                            vertical: -4,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'profile.employee.same_as_current_city'.tr(),
                          style: context.text.bodyMedium!.copyWith(
                            color: context.colors.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.spacing.md),
                    PlacesAutocompleteField(
                      title: 'profile.employee.preferred_location'.tr(),
                      hintText: 'profile.employee.preferred_location_hint'.tr(),
                      controller: _preferredLocationController,
                      onPlaceSelected: (address, lat, lng) {
                        setState(() {
                          _lat = lat;
                          _lng = lng;
                        });
                      },
                    ),
                    SizedBox(height: context.spacing.md),
                    FutureBuilder<List<QualificationDto>>(
                      future: _qualificationsFuture,
                      builder: (context, snapshot) {
                        final items = _qualificationsToItems(
                          snapshot.data ?? const [],
                        );
                        return AppDropdown(
                          title: 'profile.employee.qualification'.tr(),
                          hint: 'profile.employee.select_qualification'.tr(),
                          items: items,
                          valueId: _qualificationId,
                          onChanged: (v) =>
                              setState(() => _qualificationId = v?.id),
                        );
                      },
                    ),
                    SizedBox(height: context.spacing.sm),
                    FutureBuilder<List<SkillDto>>(
                      future: _skillsFuture,
                      builder: (context, snapshot) {
                        final options = _skillsToItems(
                          snapshot.data ?? const [],
                        );
                        return ChipsSelector(
                          title: 'profile.employee.skills'.tr(),
                          optional: true,
                          options: options,
                          selectedIds: _selectedSkillIds,
                          onChanged: (next) => setState(() {
                            _skillsTouched = true;
                            _selectedSkillIds = next;
                            _skillsSignature = _signatureFor(next);
                          }),
                        );
                      },
                    ),
                    SizedBox(height: context.spacing.sm),
                    FutureBuilder<List<SalaryTypeDto>>(
                      future: _salaryTypesFuture,
                      builder: (context, snapshot) {
                        final options = _salaryTypeOptions(
                          snapshot.data ?? const <SalaryTypeDto>[],
                        );

                        if (_salaryTypeId == null &&
                            (_salaryFrequency ?? '').trim().isNotEmpty) {
                          final freq = _normalizeSalaryFrequency(
                            _salaryFrequency,
                          );
                          for (final o in options) {
                            if (_salaryTypeKey(o) == freq) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!mounted) return;
                                setState(() => _salaryTypeId = o.id);
                              });
                              break;
                            }
                          }
                        }

                        if (_salaryTypeId == null && options.isNotEmpty) {
                          final first = options.first;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted || _salaryTypeId != null) return;
                            setState(() {
                              _salaryTypeId = first.id;
                              _salaryFrequency = _salaryTypeKey(first);
                            });
                          });
                        }

                        return Padding(
                          padding: EdgeInsets.only(left: context.spacing.xs),
                          child: ExpectedSalaryField<SalaryTypeDto>(
                            title: 'profile.employee.expected_salary'.tr(),
                            hintText: 'profile.employee.expected_salary_hint'
                                .tr(),
                            amountController: _salaryAmountController,
                            selectedValue: _selectedSalaryType(options),
                            onChanged: (salaryType) => setState(() {
                              _salaryTypeId = salaryType.id;
                              _salaryFrequency = _salaryTypeKey(salaryType);
                            }),
                            options: options,
                            labelBuilder: _salaryTypeDisplayLabel,
                            maxLength: 5,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: context.spacing.sm),
                    FutureBuilder<List<ShiftDto>>(
                      future: _shiftsFuture,
                      builder: (context, snapshot) {
                        final items = _shiftsToItems(snapshot.data ?? const []);
                        return AppDropdown(
                          title: 'profile.employee.preferred_shift'.tr(),
                          hint: 'profile.employee.select_shift'.tr(),
                          items: items,
                          valueId: _shiftId,
                          onChanged: (v) => setState(() => _shiftId = v?.id),
                        );
                      },
                    ),
                    SizedBox(height: context.spacing.sm),
                    LabeledFormField(
                      title: 'profile.employee.assistant_code'.tr(),
                      hintText: 'profile.employee.enter_assistant_code'.tr(),
                      optional: true,
                      controller: _assistantCodeController,
                    ),
                    SizedBox(height: context.spacing.sm),
                    LabeledFormField(
                      title: 'profile.employee.email'.tr(),
                      hintText: 'profile.employee.enter_email'.tr(),
                      optional: true,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: context.spacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'profile.employee.about_me'.tr(),
                          style: context.text.bodyMedium!.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'common.optional'.tr(),
                          style: context.text.labelMedium?.copyWith(
                            color: context.colors.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.spacing.sm),
                    TextFormField(
                      controller: _aboutController,
                      minLines: 4,
                      maxLines: 6,
                      keyboardType: TextInputType.multiline,
                      style: context.text.bodyMedium!.copyWith(
                        color: context.colors.onPrimaryContainer,
                      ),
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: 'profile.employee.about_hint'.tr(),
                        hintStyle: context.text.bodyMedium!.copyWith(
                          color: context.colors.onPrimaryContainer,
                        ),
                        filled: true,
                        fillColor: context.colors.surface,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: context.spacing.md,
                          vertical: context.spacing.md,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(context.radii.md),
                          borderSide: BorderSide(color: context.colors.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(context.radii.md),
                          borderSide: BorderSide(
                            color: context.colors.primary,
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: context.spacing.xxxl),
                  ],
                ),
              ),
            ),
            SizedBox(height: context.spacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : () async {
                        setState(() => _isSaving = true);
                        try {
                          await _submit();
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
