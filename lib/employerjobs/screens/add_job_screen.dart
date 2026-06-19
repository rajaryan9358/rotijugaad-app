import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/common/dialogs/primary_dialog.dart';
import 'package:rotijugaad/common/widgets/toolbar.dart';
import 'package:rotijugaad/employerjobs/sheets/verify_interviewer_mobile_sheet.dart';
import 'package:rotijugaad/employerjobs/widgets/shift_day_item.dart';
import 'package:rotijugaad/theme/context_ext.dart';

import '../../common/models/id_name.dart';
import '../../common/widgets/app_dropdown.dart';
import '../../common/widgets/app_button_child.dart';
import '../../common/widgets/app_loading_indicator.dart';
import '../../common/widgets/app_shimmer_placeholders.dart';
import '../../common/widgets/chips_selector.dart';
import '../../common/widgets/labeled_form_field.dart';
import '../../common/widgets/places_autocomplete_field.dart';
import '../../employers/providers/employers_provider.dart';
import '../../masters/models/job_profile_dtos.dart';
import '../../masters/models/location_dtos.dart';
import '../../masters/models/misc_dtos.dart';
import '../../masters/models/work_dtos.dart';
import '../../masters/providers/masters_provider.dart';
import '../../profile/utils/employer_profile_action_guard.dart';
import '../../utils/shared_pref.dart';
import '../../jobs/services/jobs_service.dart';
import '../../utils/location_service.dart';
import '../../utils/result.dart';

class AddJobScreen extends StatefulWidget {
  final bool isEdit;
  final int? jobId;
  final int? repostJobId;
  final bool clearStackToEmployerHomeOnSuccess;

  const AddJobScreen({
    super.key,
    this.isEdit = false,
    this.jobId,
    this.repostJobId,
    this.clearStackToEmployerHomeOnSuccess = false,
  });

  @override
  State<StatefulWidget> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  static const String _defaultWorkingFromTime = '9:00 AM';
  static const String _defaultWorkingToTime = '7:00 PM';

  final JobsService _jobsService = JobsService();

  bool _isPosting = false;

  // Firm info fields — shown when job is not a household help job.
  final TextEditingController _firmNameController = TextEditingController();
  String? _firmBusinessCategoryId;
  List<IdName> _businessCategories = const [];
  double? _currentLat;
  double? _currentLng;
  double? _jobLat;
  double? _jobLng;

  final TextEditingController mobileController = TextEditingController();
  final TextEditingController salaryFromController = TextEditingController();
  final TextEditingController salaryToController = TextEditingController();
  final TextEditingController workingFromController = TextEditingController();
  final TextEditingController workingToController = TextEditingController();

  final TextEditingController jobDescriptionController =
      TextEditingController();
  final TextEditingController jobDesignationController =
      TextEditingController();
  final TextEditingController jobLocationController = TextEditingController();
  final FocusNode _jobLocationFocusNode = FocusNode();
  final TextEditingController jobAddressController = TextEditingController();

  final DateFormat _apiTimeFmt = DateFormat('HH:mm:ss');
  late final List<DateFormat> _inputTimeFmts = [
    DateFormat('hh:mm a'),
    DateFormat('h:mm a'),
    DateFormat('HH:mm'),
    DateFormat('H:mm'),
    DateFormat('HH:mm:ss'),
    DateFormat('H:mm:ss'),
  ];

  bool _isHouseholdHelpJob = false;
  bool _sameAsCurrentNumber = false;
  bool _isInterviewerMobileVerified = false;
  bool _isInterviewerMobileEditable = true;
  bool _isSendingInterviewerOtp = false;
  String _verifiedInterviewerMobile = '';
  bool _sameAsCurrentState = false;
  bool _sameAsCurrentCity = false;
  bool _sameAsEmployerAddress = false;

  final Set<int> _selectedWorkingDays = <int>{0, 1, 2, 3, 4, 5};

  List<IdName> _salaryTypes = const [];
  String? _salaryTypeId;

  String _employerMobile = "";
  String _employerAddress = "";
  String? _employerStateId;
  String? _employerCityId;

  final days = const [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  bool _isInitLoading = true;
  bool _isCitiesLoading = false;

  List<IdName> _jobTitles = const [];
  List<IdName> _vacancyNumbers = const [];
  List<IdName> _skills = const [];
  List<IdName> _experiences = const [];
  List<IdName> _qualifications = const [];
  List<IdName> _jobBenefits = const [];
  List<IdName> _shifts = const [];
  List<IdName> _genders = const [];

  List<IdName> _states = const [];
  List<IdName> _cities = const [];

  String? _jobTitleId;
  String? _vacancyNumberId;
  String? _stateId;
  String? _cityId;

  Set<String> _selectedSkills = <String>{};
  Set<String> _selectedExperiences = <String>{};
  Set<String> _selectedGenders = <String>{};
  Set<String> _selectedQualifications = <String>{};
  Set<String> _selectedJobBenefits = <String>{};
  Set<String> _selectedShifts = <String>{};

  bool _viewAllSkills = false;
  bool _viewAllExperiences = false;
  bool _viewAllQualifications = false;
  bool _viewAllBenefits = false;

  @override
  void initState() {
    super.initState();
    _isInterviewerMobileEditable = !widget.isEdit;
    _applyDefaultWorkingHours();
    _loadEmployerDefaults();
    mobileController.addListener(_handleInterviewerMobileChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitial();
      _loadCurrentLocation();
    });
  }

  @override
  void dispose() {
    mobileController.removeListener(_handleInterviewerMobileChanged);
    mobileController.dispose();
    salaryFromController.dispose();
    salaryToController.dispose();
    workingFromController.dispose();
    workingToController.dispose();
    jobDescriptionController.dispose();
    jobDesignationController.dispose();
    jobLocationController.dispose();
    _jobLocationFocusNode.dispose();
    jobAddressController.dispose();
    _firmNameController.dispose();
    super.dispose();
  }

  String? _normalizeTimeForApi(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;

    for (final fmt in _inputTimeFmts) {
      try {
        final dt = fmt.parseStrict(text);
        return _apiTimeFmt.format(dt);
      } catch (_) {}
    }

    final m = RegExp(r'^(\d{1,2}):(\d{2})\s*([AaPp][Mm])$').firstMatch(text);
    if (m != null) {
      final hh = int.tryParse(m.group(1) ?? '');
      final mm = int.tryParse(m.group(2) ?? '');
      final ap = (m.group(3) ?? '').toUpperCase();
      if (hh == null || mm == null) return null;
      if (hh < 1 || hh > 12 || mm < 0 || mm > 59) return null;

      var hour24 = hh % 12;
      if (ap == 'PM') hour24 += 12;

      return '${hour24.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}:00';
    }

    final m2 = RegExp(r'^(\d{1,2}):(\d{2})(?::(\d{2}))?$').firstMatch(text);
    if (m2 != null) {
      final hh = int.tryParse(m2.group(1) ?? '');
      final mm = int.tryParse(m2.group(2) ?? '');
      final ss = int.tryParse(m2.group(3) ?? '0');
      if (hh == null || mm == null || ss == null) return null;
      if (hh < 0 || hh > 23 || mm < 0 || mm > 59 || ss < 0 || ss > 59)
        return null;

      return '${hh.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}:${ss.toString().padLeft(2, '0')}';
    }

    return null;
  }

  String _pickLang(String? en, String? hi) {
    final isHindi =
        SharedPrefUtils.readStr(SharedPrefUtils.APP_LANGUAGE).trim() == 'hi';
    final primary = (isHindi ? hi : en)?.trim() ?? '';
    if (primary.isNotEmpty) return primary;
    return (en ?? hi ?? '').trim();
  }

  void _applyDefaultWorkingHours() {
    if (workingFromController.text.trim().isEmpty) {
      workingFromController.text = _defaultWorkingFromTime;
    }
    if (workingToController.text.trim().isEmpty) {
      workingToController.text = _defaultWorkingToTime;
    }
  }

  List<IdName> _jobProfilesToItems(List<JobProfileDto> list) {
    return list
        .map(
          (e) => IdName(
            id: e.id.toString(),
            name: _pickLang(e.profileEnglish, e.profileHindi),
          ),
        )
        .where((e) => e.name.trim().isNotEmpty)
        .toList();
  }

  List<IdName> _vacancyNumbersToItems(List<VacancyNumberDto> list) {
    return list
        .map(
          (e) => IdName(
            id: e.id.toString(),
            name: _pickLang(e.numberEnglish, e.numberHindi),
          ),
        )
        .where((e) => e.name.trim().isNotEmpty)
        .toList();
  }

  List<IdName> _skillsToItems(List<SkillDto> list) {
    return list
        .map(
          (e) => IdName(
            id: e.id.toString(),
            name: _pickLang(e.skillEnglish, e.skillHindi),
          ),
        )
        .where((e) => e.name.trim().isNotEmpty)
        .toList();
  }

  List<IdName> _experiencesToItems(List<ExperienceDto> list) {
    return list
        .map(
          (e) => IdName(
            id: e.id.toString(),
            name: _pickLang(e.titleEnglish, e.titleHindi),
          ),
        )
        .where((e) => e.name.trim().isNotEmpty)
        .toList();
  }

  List<IdName> _qualificationsToItems(List<QualificationDto> list) {
    return list
        .map(
          (e) => IdName(
            id: e.id.toString(),
            name: _pickLang(e.qualificationEnglish, e.qualificationHindi),
          ),
        )
        .where((e) => e.name.trim().isNotEmpty)
        .toList();
  }

  List<IdName> _benefitsToItems(List<JobBenefitDto> list) {
    return list
        .map(
          (e) => IdName(
            id: e.id.toString(),
            name: _pickLang(e.benefitEnglish, e.benefitHindi),
          ),
        )
        .where((e) => e.name.trim().isNotEmpty)
        .toList();
  }

  List<IdName> _shiftsToItems(List<ShiftDto> list) {
    return list
        .map(
          (e) => IdName(
            id: e.id.toString(),
            name: _pickLang(e.shiftEnglish, e.shiftHindi),
          ),
        )
        .where((e) => e.name.trim().isNotEmpty)
        .toList();
  }

  List<IdName> _statesToItems(List<StateDto> list) {
    return list
        .map(
          (e) => IdName(
            id: e.id.toString(),
            name: _pickLang(e.stateEnglish, e.stateHindi),
          ),
        )
        .where((e) => e.name.trim().isNotEmpty)
        .toList();
  }

  List<IdName> _citiesToItems(List<CityDto> list) {
    return list
        .map(
          (e) => IdName(
            id: e.id.toString(),
            name: _pickLang(e.cityEnglish, e.cityHindi),
          ),
        )
        .where((e) => e.name.trim().isNotEmpty)
        .toList();
  }

  List<IdName> _gendersFromRaw(dynamic raw) {
    if (raw is! List) return const [];

    final items = <IdName>[];
    for (final it in raw) {
      if (it is! Map) continue;
      final m = Map<String, dynamic>.from(it);

      final id = (m['id'] ?? m['value'] ?? '').toString().trim();
      if (id.isEmpty) continue;

      final name = _pickLang(
        (m['gender_english'] ?? m['title_english'] ?? m['name_english'])
            ?.toString(),
        (m['gender_hindi'] ?? m['title_hindi'] ?? m['name_hindi'])?.toString(),
      );
      if (name.trim().isEmpty) continue;

      items.add(IdName(id: id, name: name));
    }

    return items;
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _asString(dynamic v) {
    if (v == null) return '';
    return v.toString().trim();
  }

  String? _asId(dynamic v) {
    final s = _asString(v);
    return s.isEmpty ? null : s;
  }

  int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  void _loadEmployerDefaults() {
    final profile = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_PROFILE_JSON);
    final user = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_USER_JSON);

    final userMobile = _asString(user?['mobile']);
    _employerMobile = userMobile.isNotEmpty
        ? userMobile
        : _asString(profile?['mobile']).isNotEmpty
        ? _asString(profile?['mobile'])
        : _asString(profile?['phone']).isNotEmpty
        ? _asString(profile?['phone'])
        : _asString(profile?['contact_number']).isNotEmpty
        ? _asString(profile?['contact_number'])
        : _asString(profile?['contactNumber']).isNotEmpty
        ? _asString(profile?['contactNumber'])
        : _asString(profile?['mobile_number']);

    _employerAddress = _asString(profile?['address']);
    _employerStateId = _asId(profile?['state_id'] ?? profile?['stateId']);
    _employerCityId = _asId(profile?['city_id'] ?? profile?['cityId']);

    _firmNameController.text = _asString(
      profile?['organization_name'] ?? profile?['organizationName'],
    );
    _firmBusinessCategoryId = _asId(
      profile?['business_category_id'] ?? profile?['businessCategoryId'],
    );
  }

  List<IdName> _salaryTypesToItems(List<SalaryTypeDto> list) {
    return list
        .map(
          (e) => IdName(
            id: e.id.toString(),
            name: _pickLang(e.typeEnglish, e.typeHindi),
          ),
        )
        .where((e) => e.name.trim().isNotEmpty)
        .toList();
  }

  List<IdName> _businessCategoriesToItems(List<BusinessCategoryDto> list) {
    return list
        .map(
          (e) => IdName(
            id: e.id.toString(),
            name: _pickLang(e.categoryEnglish, e.categoryHindi),
          ),
        )
        .where((e) => e.name.trim().isNotEmpty)
        .toList();
  }

  void _onSameAsCurrentNumberChanged(bool checked) {
    setState(() => _sameAsCurrentNumber = checked);

    if (!checked) {
      _setInterviewerMobileVerified(false);
      return;
    }

    final mobile = _employerMobile.trim();
    if (mobile.isEmpty) {
      _snack('job.form.errors.unable_to_load_employer_mobile'.tr());
      setState(() => _sameAsCurrentNumber = false);
      return;
    }

    mobileController.text = mobile;
    _setInterviewerMobileVerified(true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _jobLocationFocusNode.requestFocus();
    });
  }

  void _setInterviewerMobileVerified(bool value) {
    setState(() {
      _isInterviewerMobileVerified = value;
      _verifiedInterviewerMobile = value ? mobileController.text.trim() : '';
    });
  }

  void _handleInterviewerMobileChanged() {
    if (!_isInterviewerMobileVerified) return;
    final current = mobileController.text.trim();
    if (current == _verifiedInterviewerMobile) return;

    setState(() {
      _isInterviewerMobileVerified = false;
      _verifiedInterviewerMobile = '';
    });
  }

  void _enableInterviewerMobileEditing() {
    setState(() {
      _isInterviewerMobileEditable = true;
      _sameAsCurrentNumber = false;
    });
  }

  void _onSameAsEmployerAddressChanged(bool checked) {
    setState(() => _sameAsEmployerAddress = checked);

    if (!checked) {
      jobAddressController.clear();
      return;
    }

    final addr = _employerAddress.trim();
    if (addr.isEmpty) {
      _snack('job.form.errors.unable_to_load_employer_address'.tr());
      setState(() => _sameAsEmployerAddress = false);
      return;
    }

    jobAddressController.text = addr;
  }

  Future<void> _onSameAsCurrentStateChanged(bool checked) async {
    setState(() => _sameAsCurrentState = checked);

    if (!checked) return;

    final stateId = _asInt(_employerStateId);
    if (stateId <= 0) {
      _snack('job.form.errors.unable_to_load_employer_state'.tr());
      setState(() => _sameAsCurrentState = false);
      return;
    }

    setState(() {
      _stateId = stateId.toString();
      _cityId = null;
    });

    await _loadCitiesForState(stateId);

    if (!mounted) return;

    if (_sameAsCurrentCity) {
      final cityId = _asInt(_employerCityId);
      if (cityId > 0) {
        setState(() => _cityId = cityId.toString());
      }
    }
  }

  Future<void> _onSameAsCurrentCityChanged(bool checked) async {
    if (!checked) {
      setState(() => _sameAsCurrentCity = false);
      return;
    }

    final stateId = _asInt(_employerStateId);
    final cityId = _asInt(_employerCityId);

    if (stateId <= 0 || cityId <= 0) {
      _snack('job.form.errors.unable_to_load_employer_city'.tr());
      setState(() => _sameAsCurrentCity = false);
      return;
    }

    setState(() {
      _sameAsCurrentCity = true;
      _sameAsCurrentState = true;
      _stateId = stateId.toString();
      _cityId = null;
    });

    await _loadCitiesForState(stateId);

    if (!mounted) return;
    setState(() => _cityId = cityId.toString());
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
      _cityId = null;
    });

    final masters = context.read<MastersProvider>();
    final cities = await masters.getCitiesFromDb(stateId: stateId);

    if (!mounted) return;
    setState(() {
      _cities = _citiesToItems(cities);
      _isCitiesLoading = false;
    });
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isInitLoading = true;
    });

    try {
      final masters = context.read<MastersProvider>();
      await masters.loadMasters();

      final jobProfiles = await masters.getJobProfilesFromDb();
      final vacancyNumbers = await masters.getVacancyNumbersFromDb();
      final skills = await masters.getSkillsFromDb();
      final experiences = await masters.getExperiencesFromDb();
      final qualifications = await masters.getQualificationsFromDb();
      final benefits = await masters.getJobBenefitsFromDb();
      final shifts = await masters.getShiftsFromDb();
      final salaryTypes = await masters.getSalaryTypesFromDb();
      final businessCategories = await masters.getBusinessCategoriesFromDb();

      final states = await masters.getStatesFromDb();

      if (!mounted) return;
      setState(() {
        _jobTitles = _jobProfilesToItems(jobProfiles);
        _vacancyNumbers = _vacancyNumbersToItems(vacancyNumbers);
        _skills = _skillsToItems(skills);
        _experiences = _experiencesToItems(experiences);
        _qualifications = _qualificationsToItems(qualifications);
        _jobBenefits = _benefitsToItems(benefits);
        _shifts = _shiftsToItems(shifts);
        _salaryTypes = _salaryTypesToItems(salaryTypes);
        _salaryTypeId ??= _salaryTypes.isNotEmpty
            ? _salaryTypes.first.id
            : null;
        _genders = _gendersFromRaw(masters.masters?.raw['job_genders']);
        _businessCategories = _businessCategoriesToItems(businessCategories);

        _states = _statesToItems(states);
      });

      // If state already selected (edit-mode future use), load cities.
      final stateId = int.tryParse(_stateId ?? '') ?? 0;
      if (stateId > 0) {
        await _loadCitiesForState(stateId);
      }

      await _loadEditJobDetail();
    } catch (_) {
      // Keep screen usable even if masters load fails.
    }

    if (!mounted) return;
    setState(() {
      _isInitLoading = false;
    });
  }

  double? _asDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  Set<String> _asStringSet(dynamic raw) {
    if (raw is! List) return <String>{};
    final out = <String>{};
    for (final it in raw) {
      final s = (it ?? '').toString().trim();
      if (s.isEmpty) continue;
      out.add(s);
    }
    return out;
  }

  Set<int> _dayIndexesFromApi(dynamic raw) {
    if (raw is! List) return <int>{};

    final map = <String, int>{
      'monday': 0,
      'tuesday': 1,
      'wednesday': 2,
      'thursday': 3,
      'friday': 4,
      'saturday': 5,
      'sunday': 6,
    };

    final out = <int>{};
    for (final it in raw) {
      final key = (it ?? '').toString().trim().toLowerCase();
      final idx = map[key];
      if (idx == null) continue;
      out.add(idx);
    }
    return out;
  }

  String? _vacancyIdForNo(int? noVacancy) {
    final n = noVacancy ?? 0;
    if (n <= 0) return null;

    for (final it in _vacancyNumbers) {
      final txt = it.name.trim();
      final digits = RegExp(r'\d+').firstMatch(txt)?.group(0) ?? '';
      final parsed = int.tryParse(digits) ?? 0;
      if (parsed == n) return it.id;
    }

    return null;
  }

  String _formatApiTimeForUi(dynamic raw) {
    final s = _asString(raw);
    if (s.isEmpty) return '';

    final outFmt = DateFormat('hh:mm a');
    final inFmts = <DateFormat>[DateFormat('HH:mm:ss'), DateFormat('HH:mm')];

    for (final fmt in inFmts) {
      try {
        return outFmt.format(fmt.parseStrict(s));
      } catch (_) {}
    }

    return s;
  }

  Future<void> _loadEditJobDetail() async {
    final isRepost = !widget.isEdit && widget.repostJobId != null;
    if (!widget.isEdit && !isRepost) return;

    final jobId = widget.isEdit ? widget.jobId : widget.repostJobId;
    if (jobId == null || jobId <= 0) return;

    final employerId = SharedPrefUtils.readInt('auth_employer_id');
    if (employerId <= 0) return;

    final result = await _jobsService.getEmployerJobDetailRaw(
      employerId: employerId,
      jobId: jobId,
    );

    if (!mounted) return;

    switch (result) {
      case Success(value: final job):
        final jobProfileId = _asId(
          job['job_profile_id'] ?? job['jobProfileId'],
        );
        final noVacancy = _asInt(job['no_vacancy'] ?? job['noVacancy']);

        final interviewer = _asString(
          job['interviewer_contact'] ?? job['interviewerContact'],
        );

        final jobLocation = _asString(
          job['job_location'] ?? job['jobLocation'],
        );
        final address = _asString(
          job['job_address_english'] ??
              job['jobAddressEnglish'] ??
              job['job_address'],
        );

        final stateId = _asInt(job['job_state_id'] ?? job['jobStateId']);
        final cityId = _asInt(job['job_city_id'] ?? job['jobCityId']);

        final salaryTypeId = _asId(
          job['salary_type_id'] ?? job['salaryTypeId'],
        );
        final salaryMin = _asDouble(job['salary_min'] ?? job['salaryMin']);
        final salaryMax = _asDouble(job['salary_max'] ?? job['salaryMax']);

        final workStart = _formatApiTimeForUi(
          job['work_start_time'] ?? job['workStartTime'],
        );
        final workEnd = _formatApiTimeForUi(
          job['work_end_time'] ?? job['workEndTime'],
        );

        final description = _asString(
          job['description_english'] ??
              job['descriptionEnglish'] ??
              job['description'],
        );
        final designation = _asString(
          job['job_designation_english'] ??
              job['jobDesignationEnglish'] ??
              job['job_designation'] ??
              job['jobDesignation'],
        );
        final designationHindi = _asString(
          job['job_designation_hindi'] ?? job['jobDesignationHindi'],
        );

        final selectedSkills = _asStringSet(
          job['skill_ids'] ?? job['skillIds'],
        );
        final selectedExp = _asStringSet(
          job['experience_ids'] ?? job['experienceIds'],
        );
        final selectedQual = _asStringSet(
          job['qualification_ids'] ?? job['qualificationIds'],
        );
        final selectedBenefits = _asStringSet(
          job['job_benefit_ids'] ?? job['jobBenefitIds'],
        );
        final selectedShifts = _asStringSet(
          job['shift_ids'] ?? job['shiftIds'],
        );

        final gendersRaw =
            job['genders'] ?? job['gender'] ?? job['job_genders'];
        final selectedGenders = _asStringSet(gendersRaw);

        final selectedDays = _dayIndexesFromApi(
          job['job_days'] ?? job['jobDays'],
        );

        final lat = _asDouble(job['lat'] ?? job['latitude']);
        final lng = _asDouble(job['lng'] ?? job['longitude']);

        jobDescriptionController.text = description;
        jobDesignationController.text = _pickLang(
          designation,
          designationHindi,
        );
        jobLocationController.text = jobLocation;
        jobAddressController.text = address;
        mobileController.text = interviewer;
        salaryFromController.text = salaryMin?.round().toString() ?? '';
        salaryToController.text = salaryMax?.round().toString() ?? '';
        workingFromController.text = workStart.isNotEmpty
            ? workStart
            : _defaultWorkingFromTime;
        workingToController.text = workEnd.isNotEmpty
            ? workEnd
            : _defaultWorkingToTime;

        setState(() {
          _jobTitleId = jobProfileId;
          _vacancyNumberId = _vacancyIdForNo(noVacancy);

          _isHouseholdHelpJob = (job['is_household'] ?? false) == true;

          _salaryTypeId = salaryTypeId;

          _stateId = stateId > 0 ? stateId.toString() : null;
          _cityId = null;

          _selectedSkills = selectedSkills;
          _selectedExperiences = selectedExp;
          _selectedQualifications = selectedQual;
          _selectedJobBenefits = selectedBenefits;
          _selectedShifts = selectedShifts;
          _selectedGenders = selectedGenders;

          if (selectedDays.isNotEmpty) {
            _selectedWorkingDays
              ..clear()
              ..addAll(selectedDays);
          }

          if (lat != null && lng != null) {
            _jobLat = lat;
            _jobLng = lng;
          }

          _sameAsCurrentNumber = false;
          _sameAsCurrentState = false;
          _sameAsCurrentCity = false;
          _isInterviewerMobileEditable =
              isRepost || interviewer.trim().isEmpty;
        });

        if (stateId > 0) {
          await _loadCitiesForState(stateId);
        }

        if (!mounted) return;

        if (cityId > 0) {
          setState(() => _cityId = cityId.toString());
        }

        if (!isRepost && interviewer.trim().isNotEmpty) {
          _setInterviewerMobileVerified(true);
        }

        break;
      case Failure(exception: final e):
        _snack(e.message);
        break;
    }
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final point = await LocationService.getCurrentLatLng();
      if (!mounted) return;
      setState(() {
        _currentLat = point?.lat;
        _currentLng = point?.lng;
      });
    } catch (_) {
      // Ignore location failures.
    }
  }

  List<IdName> _selectedFirst(List<IdName> options, Set<String> selectedIds) {
    final selected = <IdName>[];
    final rest = <IdName>[];
    for (final o in options) {
      if (selectedIds.contains(o.id)) {
        selected.add(o);
      } else {
        rest.add(o);
      }
    }
    return [...selected, ...rest];
  }

  List<IdName> _preview(
    List<IdName> options,
    Set<String> selectedIds, {
    int unselectedLimit = 6,
  }) {
    final selected = <IdName>[];
    final rest = <IdName>[];

    for (final o in options) {
      if (selectedIds.contains(o.id)) {
        selected.add(o);
      } else {
        rest.add(o);
      }
    }

    if (unselectedLimit <= 0) return selected;
    return [...selected, ...rest.take(unselectedLimit)];
  }

  Widget _chipsWithViewAll({
    required String title,
    required bool optional,
    required List<IdName> options,
    required Set<String> selectedIds,
    required ValueChanged<Set<String>> onChanged,
    required bool viewAll,
    required VoidCallback onViewAll,
    int previewLimit = 6,
  }) {
    final ordered = _selectedFirst(options, selectedIds);
    final visible = viewAll
        ? ordered
        : _preview(ordered, selectedIds, unselectedLimit: previewLimit);

    return Column(
      children: [
        ChipsSelector(
          title: title,
          optional: optional,
          options: visible,
          selectedIds: selectedIds,
          onChanged: onChanged,
        ),
        if (!viewAll && ordered.length > visible.length)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Center(
              child: InkWell(
                onTap: onViewAll,
                child: Text(
                  'common.view_all'.tr(),
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _salaryRangeField() {
    final borderColor = context.colors.primary;

    InputDecoration deco(String hint) {
      return InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: Colors.transparent,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'job.form.salary_range.label'.tr(),
          style: context.text.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: salaryFromController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: deco('Min'),
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onPrimaryContainer,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  '-',
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: salaryToController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: deco('Max'),
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onPrimaryContainer,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: context.spacing.sm),
                child: _salaryTypes.isEmpty
                    ? Text(
                        'terms.month'.tr(),
                        style: context.text.bodyMedium?.copyWith(
                          color: context.colors.onPrimaryContainer,
                        ),
                      )
                    : SizedBox(
                        width: 96,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value:
                                (_salaryTypeId != null &&
                                    _salaryTypes.any(
                                      (e) => e.id == _salaryTypeId,
                                    ))
                                ? _salaryTypeId
                                : _salaryTypes.first.id,
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: context.colors.onPrimaryContainer,
                            ),
                            items: _salaryTypes
                                .map(
                                  (e) => DropdownMenuItem<String>(
                                    value: e.id,
                                    child: Text(
                                      e.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.text.bodyMedium?.copyWith(
                                        color:
                                            context.colors.onPrimaryContainer,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => _salaryTypeId = v);
                            },
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _workingHoursField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'job.form.working_hours.label'.tr(),
          style: context.text.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: LabeledFormField(
                title: '',
                hintText: 'common.from'.tr(),
                controller: workingFromController,
                pickerMode: FieldPickerMode.time,
              ),
            ),
            SizedBox(width: context.spacing.sm),
            Expanded(
              child: LabeledFormField(
                title: '',
                hintText: 'common.to'.tr(),
                controller: workingToController,
                pickerMode: FieldPickerMode.time,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final genders = _genders.isNotEmpty
        ? _genders
        : <IdName>[
            IdName(id: 'male', name: 'terms.male'.tr()),
            IdName(id: 'female', name: 'terms.female'.tr()),
            IdName(id: 'any', name: 'terms.any'.tr()),
          ];

    return Scaffold(
      backgroundColor: context.colors.onPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Toolbar(
              widget.isEdit
                  ? 'job.form.screen_title.edit'.tr()
                  : 'job.form.screen_title.add'.tr(),
              () {
                Navigator.of(context).pop();
              },
            ),
            Divider(
              color: context.xcolors.stroke.withValues(alpha: 0.5),
              height: 1,
            ),
            Expanded(
              child: _isInitLoading
                  ? AppFormShimmer(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing.md,
                        vertical: context.spacing.md,
                      ),
                    )
                  : SingleChildScrollView(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: context.spacing.md,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: context.spacing.xl),
                            AppDropdown(
                              title: 'job.form.job_title.label'.tr(),
                              enabled: !widget.isEdit,
                              searchable: true,
                              items: _jobTitles,
                              valueId: _jobTitleId,
                              hint: 'job.form.job_title.hint'.tr(),
                              onChanged: (idName) {
                                setState(() {
                                  _jobTitleId = idName?.id;
                                });
                              },
                            ),
                            SizedBox(height: context.spacing.md),
                            LabeledFormField(
                              title: 'job.form.job_designation.label'.tr(),
                              optional: true,
                              controller: jobDesignationController,
                              hintText: 'job.form.job_designation.hint'.tr(),
                              textInputAction: TextInputAction.next,
                            ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: _isHouseholdHelpJob,
                                    onChanged: (checked) {
                                      setState(() {
                                        _isHouseholdHelpJob = checked ?? false;
                                        _sameAsEmployerAddress = false;
                                        jobAddressController.clear();
                                      });
                                    },
                                    visualDensity: const VisualDensity(
                                      horizontal: -4,
                                      vertical: -4,
                                    ),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'job.form.household_help_job'.tr(),
                                    style: context.text.bodyMedium!.copyWith(
                                      color: context.colors.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            if (!_isHouseholdHelpJob && !widget.isEdit) ...[
                              SizedBox(height: context.spacing.md),
                              LabeledFormField(
                                title: 'job.form.org_name.label'.tr(),
                                hintText: 'job.form.org_name.hint'.tr(),
                                controller: _firmNameController,
                                textInputAction: TextInputAction.next,
                              ),
                              SizedBox(height: context.spacing.md),
                              AppDropdown(
                                title: 'job.form.business_category.label'.tr(),
                                searchable: true,
                                items: _businessCategories,
                                valueId: _firmBusinessCategoryId,
                                hint: 'job.form.business_category.hint'.tr(),
                                onChanged: (idName) {
                                  setState(() {
                                    _firmBusinessCategoryId = idName?.id;
                                  });
                                },
                              ),
                            ],
                            SizedBox(height: context.spacing.md),
                            Row(
                              children: [
                                Text(
                                  'job.form.job_description.label'.tr(),
                                  style: context.text.bodyMedium!.copyWith(
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'common.optional'.tr(),
                                  style: context.text.labelMedium?.copyWith(
                                    color: context.colors.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: context.spacing.md),
                            TextFormField(
                              controller: jobDescriptionController,
                              minLines: 4,
                              maxLines: 6,
                              keyboardType: TextInputType.multiline,
                              enabled: true,
                              style: context.text.bodyMedium!.copyWith(
                                color: context.colors.onPrimaryContainer,
                              ),
                              textInputAction: TextInputAction.newline,
                              decoration: InputDecoration(
                                hintText: 'job.form.job_description.hint'.tr(),
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
                                  borderRadius: BorderRadius.circular(
                                    context.radii.md,
                                  ),
                                  borderSide: BorderSide(
                                    color: context.colors.outline,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    context.radii.md,
                                  ),
                                  borderSide: BorderSide(
                                    color: context.colors.primary,
                                    width: 1.4,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: context.spacing.md),
                            AppDropdown(
                              title: 'job.form.vacancies.label'.tr(),
                              enabled: true,
                              items: _vacancyNumbers,
                              valueId: _vacancyNumberId,
                              hint: 'job.form.vacancies.hint'.tr(),
                              onChanged: (idName) {
                                setState(() {
                                  _vacancyNumberId = idName?.id;
                                });
                              },
                            ),
                            SizedBox(height: context.spacing.xs),
                            _chipsWithViewAll(
                              title: 'job.form.skills'.tr(),
                              optional: true,
                              options: _skills,
                              selectedIds: _selectedSkills,
                              onChanged: (next) {
                                setState(() {
                                  _selectedSkills = next;
                                });
                              },
                              viewAll: _viewAllSkills,
                              onViewAll: () {
                                setState(() {
                                  _viewAllSkills = true;
                                });
                              },
                            ),
                            SizedBox(height: context.spacing.xs),
                            _chipsWithViewAll(
                              title: 'job.form.experience'.tr(),
                              optional: false,
                              options: _experiences,
                              selectedIds: _selectedExperiences,
                              onChanged: (next) {
                                setState(() {
                                  _selectedExperiences = next;
                                });
                              },
                              viewAll: _viewAllExperiences,
                              onViewAll: () {
                                setState(() {
                                  _viewAllExperiences = true;
                                });
                              },
                            ),
                            SizedBox(height: context.spacing.xs),
                            ChipsSelector(
                              title: 'job.form.gender'.tr(),
                              optional: false,
                              options: genders,
                              selectedIds: _selectedGenders,
                              onChanged: (next) {
                                setState(() {
                                  _selectedGenders = next;
                                });
                              },
                            ),
                            SizedBox(height: context.spacing.xs),
                            _chipsWithViewAll(
                              title: 'job.form.qualifications'.tr(),
                              optional: false,
                              options: _qualifications,
                              selectedIds: _selectedQualifications,
                              onChanged: (next) {
                                setState(() {
                                  _selectedQualifications = next;
                                });
                              },
                              viewAll: _viewAllQualifications,
                              onViewAll: () {
                                setState(() {
                                  _viewAllQualifications = true;
                                });
                              },
                            ),
                            SizedBox(height: context.spacing.xs),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'job.form.interviewer_contact.label'
                                            .tr(),
                                        style: context.text.labelLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: context.colors.primary,
                                            ),
                                      ),
                                    ),
                                    if (_sameAsCurrentNumber ||
                                        (widget.isEdit &&
                                            !_isInterviewerMobileEditable))
                                      TextButton(
                                        onPressed:
                                            _enableInterviewerMobileEditing,
                                        child: Text('common.change'.tr()),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        controller: mobileController,
                                        enabled:
                                            !_sameAsCurrentNumber &&
                                            _isInterviewerMobileEditable,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(10),
                                        ],
                                        style: context.text.bodyMedium,
                                        decoration: InputDecoration(
                                          hintText:
                                              'job.form.interviewer_contact.hint'
                                                  .tr(),
                                          isDense: true,
                                          contentPadding: const EdgeInsets.only(
                                            left: 12,
                                            bottom: 12,
                                            top: 4,
                                          ),
                                          suffixIcon: Container(
                                            height: 36,
                                            margin: const EdgeInsets.only(
                                              right: 4,
                                            ),
                                            width: 120,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child:
                                                  (_sameAsCurrentNumber ||
                                                      _isInterviewerMobileVerified)
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            right: 12,
                                                          ),
                                                      child: Icon(
                                                        Icons.check_circle,
                                                        color: context
                                                            .colors
                                                            .primary,
                                                      ),
                                                    )
                                                  : _isInterviewerMobileEditable
                                                  ? ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 0,
                                                            ),
                                                      ),
                                                      onPressed: _isSendingInterviewerOtp ? null : () async {
                                                        final employerId =
                                                            SharedPrefUtils.readInt(
                                                              'auth_employer_id',
                                                            );
                                                        if (employerId <= 0) {
                                                          _snack(
                                                            'job.form.validation.complete_profile_first'
                                                                .tr(),
                                                          );
                                                          return;
                                                        }

                                                        final mobile =
                                                            mobileController
                                                                .text
                                                                .trim();
                                                        if (mobile.isEmpty) {
                                                          _snack(
                                                            'job.form.validation.enter_contact_number'
                                                                .tr(),
                                                          );
                                                          return;
                                                        }

                                                        setState(() => _isSendingInterviewerOtp = true);
                                                        final otpResult = await _jobsService
                                                            .sendInterviewerContactOtp(
                                                              employerId: employerId,
                                                              interviewerContact: mobile,
                                                            );

                                                        if (!mounted) return;
                                                        setState(() => _isSendingInterviewerOtp = false);

                                                        int? verificationId;
                                                        switch (otpResult) {
                                                          case Success(value: final json):
                                                            final dynamic v = json['verification_id'] ?? json['verificationId'];
                                                            if (v is int) {
                                                              verificationId = v;
                                                            } else if (v != null) {
                                                              verificationId = int.tryParse(v.toString());
                                                            }
                                                          case Failure(exception: final e):
                                                            _snack(e.message);
                                                            return;
                                                        }

                                                        if (verificationId == null || verificationId <= 0) {
                                                          _snack('Failed to send OTP');
                                                          return;
                                                        }

                                                        final ok = await showModalBottomSheet<bool>(
                                                          context: context,
                                                          isScrollControlled:
                                                              true,
                                                          shape: const RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.vertical(
                                                                  top:
                                                                      Radius.circular(
                                                                        20,
                                                                      ),
                                                                ),
                                                          ),
                                                          builder: (context) {
                                                            return VerifyInterviewerMobileSheet(
                                                              employerId:
                                                                  employerId,
                                                              interviewerContact:
                                                                  mobile,
                                                              initialVerificationId:
                                                                  verificationId,
                                                            );
                                                          },
                                                        );

                                                        if (!mounted) return;
                                                        if (ok == true) {
                                                          _setInterviewerMobileVerified(
                                                            true,
                                                          );
                                                          showDialog(
                                                            context: context,
                                                            barrierDismissible:
                                                                true,
                                                            builder: (context) =>
                                                                PrimaryDialog(
                                                                  'job.form.interviewer_contact.verified_success'
                                                                      .tr(),
                                                                ),
                                                          );
                                                        }
                                                      },
                                                      child: AppButtonChild(
                                                        label: 'common.verify'.tr(),
                                                        isLoading: _isSendingInterviewerOtp,
                                                      ),
                                                    )
                                                  : const SizedBox.shrink(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: context.spacing.sm),
                            if (!_isInterviewerMobileVerified &&
                                _isInterviewerMobileEditable)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: _sameAsCurrentNumber,
                                    onChanged: (checked) {
                                      _onSameAsCurrentNumberChanged(
                                        checked ?? false,
                                      );
                                    },
                                    visualDensity: const VisualDensity(
                                      horizontal: -4,
                                      vertical: -4,
                                    ),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'job.form.same_as_current_number'.tr(),
                                    style: context.text.bodyMedium!.copyWith(
                                      color: context.colors.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            SizedBox(height: context.spacing.md),
                            PlacesAutocompleteField(
                              title: 'job.form.job_location.label'.tr(),
                              hintText: 'job.form.job_location.hint'.tr(),
                              controller: jobLocationController,
                              focusNode: _jobLocationFocusNode,
                              onPlaceSelected: (address, lat, lng) {
                                setState(() {
                                  _jobLat = lat;
                                  _jobLng = lng;
                                });
                              },
                            ),
                            SizedBox(height: context.spacing.sm),
                            LabeledFormField(
                              title: 'job.form.job_address.label'.tr(),
                              hintText: 'job.form.job_address.hint'.tr(),
                              controller: jobAddressController,
                              maxLines: 2,
                              enabled: !_sameAsEmployerAddress,
                            ),
                            SizedBox(height: context.spacing.xs),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: _sameAsEmployerAddress,
                                  onChanged: (checked) {
                                    _onSameAsEmployerAddressChanged(
                                      checked ?? false,
                                    );
                                  },
                                  visualDensity: const VisualDensity(
                                    horizontal: -4,
                                    vertical: -4,
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isHouseholdHelpJob
                                      ? 'job.form.same_as_household_address'.tr()
                                      : 'job.form.same_as_firm_address'.tr(),
                                  style: context.text.bodyMedium!.copyWith(
                                    color: context.colors.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: context.spacing.md),
                            AppDropdown(
                              title: 'job.form.job_state.label'.tr(),
                              items: _states,
                              valueId: _stateId,
                              searchable: true,
                              enabled:
                                  !_sameAsCurrentState && !_sameAsCurrentCity,
                              hint: 'job.form.job_state.hint'.tr(),
                              onChanged: (idName) async {
                                setState(() {
                                  _stateId = idName?.id;
                                  _cityId = null;
                                });
                                final id = int.tryParse(idName?.id ?? '') ?? 0;
                                if (id > 0) {
                                  await _loadCitiesForState(id);
                                }
                              },
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: _sameAsCurrentState,
                                  onChanged: (checked) async {
                                    await _onSameAsCurrentStateChanged(
                                      checked ?? false,
                                    );
                                  },
                                  visualDensity: const VisualDensity(
                                    horizontal: -4,
                                    vertical: -4,
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'job.form.same_as_current_state'.tr(),
                                  style: context.text.bodyMedium,
                                ),
                              ],
                            ),
                            SizedBox(height: context.spacing.md),
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
                                      'job.form.job_city.loading'.tr(),
                                      style: context.text.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            AppDropdown(
                              title: 'job.form.job_city.label'.tr(),
                              items: _cities,
                              valueId: _cityId,
                              searchable: true,
                              enabled:
                                  !_sameAsCurrentCity &&
                                  !_isCitiesLoading &&
                                  _stateId != null,
                              hint: _stateId == null
                                  ? 'job.form.job_city.select_state_first'.tr()
                                  : 'job.form.job_city.hint'.tr(),
                              onChanged: (idName) {
                                setState(() {
                                  _cityId = idName?.id;
                                });
                              },
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: _sameAsCurrentCity,
                                  onChanged: (checked) async {
                                    await _onSameAsCurrentCityChanged(
                                      checked ?? false,
                                    );
                                  },
                                  visualDensity: const VisualDensity(
                                    horizontal: -4,
                                    vertical: -4,
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'job.form.same_as_current_city'.tr(),
                                  style: context.text.bodyMedium,
                                ),
                              ],
                            ),
                            SizedBox(height: context.spacing.md),
                            _chipsWithViewAll(
                              title: 'job.form.job_benefits'.tr(),
                              optional: true,
                              options: _jobBenefits,
                              selectedIds: _selectedJobBenefits,
                              onChanged: (next) {
                                setState(() {
                                  _selectedJobBenefits = next;
                                });
                              },
                              viewAll: _viewAllBenefits,
                              onViewAll: () {
                                setState(() {
                                  _viewAllBenefits = true;
                                });
                              },
                            ),
                            SizedBox(height: context.spacing.xs),
                            LabeledFormField(
                              title: 'job.form.other_benefits.label'.tr(),
                              hintText: 'job.form.other_benefits.hint'.tr(),
                              optional: true,
                            ),
                            SizedBox(height: context.spacing.md),
                            _salaryRangeField(),
                            SizedBox(height: context.spacing.md),
                            ChipsSelector(
                              title: 'job.form.shift_type'.tr(),
                              optional: false,
                              options: _shifts,
                              selectedIds: _selectedShifts,
                              onChanged: (next) {
                                setState(() {
                                  _selectedShifts = next;
                                });
                              },
                            ),
                            SizedBox(height: context.spacing.xs),
                            _workingHoursField(),
                            SizedBox(height: context.spacing.md),
                            Text(
                              'job.form.working_days.label'.tr(),
                              style: context.text.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: context.colors.primary,
                              ),
                            ),
                            ListView.builder(
                              itemCount: days.length,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return ShiftDayItem(
                                  'terms.${days.elementAt(index)}'.tr(),
                                  _selectedWorkingDays.contains(index),
                                  (checked) {
                                    setState(() {
                                      if (checked) {
                                        _selectedWorkingDays.add(index);
                                      } else {
                                        _selectedWorkingDays.remove(index);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                            SizedBox(height: context.spacing.xxxl),
                          ],
                        ),
                      ),
                    ),
            ),
            Divider(
              color: context.xcolors.stroke.withValues(alpha: 0.5),
              height: 1,
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(
                horizontal: context.spacing.md,
                vertical: context.spacing.sm,
              ),
              child: ElevatedButton(
                onPressed: (_isInitLoading || _isPosting)
                    ? null
                    : () async {
                        final employerId = SharedPrefUtils.readInt(
                          'auth_employer_id',
                        );
                        if (employerId <= 0) {
                          _snack(
                            'job.form.validation.complete_profile_first'.tr(),
                          );
                          return;
                        }

                        if (!_isHouseholdHelpJob && !widget.isEdit) {
                          final firmName = _firmNameController.text.trim();
                          if (firmName.isEmpty) {
                            _snack('job.form.validation.enter_org_name'.tr());
                            return;
                          }
                          if (_firmBusinessCategoryId == null) {
                            _snack(
                              'job.form.validation.select_business_category'
                                  .tr(),
                            );
                            return;
                          }
                        }

                        final jobProfileId =
                            int.tryParse(_jobTitleId ?? '') ?? 0;
                        if (jobProfileId <= 0) {
                          _snack('job.form.validation.select_job_title'.tr());
                          return;
                        }

                        if (_selectedExperiences.isEmpty) {
                          _snack(
                            'job.form.validation.select_experience'.tr(),
                          );
                          return;
                        }

                        if (_selectedGenders.isEmpty) {
                          _snack('job.form.validation.select_gender'.tr());
                          return;
                        }

                        if (_selectedQualifications.isEmpty) {
                          _snack(
                            'job.form.validation.select_qualification'.tr(),
                          );
                          return;
                        }

                        final interviewerMobile = mobileController.text.trim();
                        if (!_isInterviewerMobileVerified ||
                            interviewerMobile.isEmpty) {
                          _snack(
                            'job.form.validation.verify_interviewer_contact_number'
                                .tr(),
                          );
                          return;
                        }

                        final jobLocation = jobLocationController.text.trim();
                        if (jobLocation.isEmpty) {
                          _snack('job.form.validation.enter_job_location'.tr());
                          return;
                        }
                        final jobAddress = jobAddressController.text.trim();
                        if (jobAddress.isEmpty) {
                          _snack('job.form.validation.enter_job_address'.tr());
                          return;
                        }

                        final jobStateId = int.tryParse(_stateId ?? '') ?? 0;
                        final jobCityId = int.tryParse(_cityId ?? '') ?? 0;
                        if (jobStateId <= 0) {
                          _snack('job.form.validation.select_job_state'.tr());
                          return;
                        }
                        if (jobCityId <= 0) {
                          _snack('job.form.validation.select_job_city'.tr());
                          return;
                        }

                        final salaryTypeId =
                            int.tryParse(_salaryTypeId ?? '') ?? 0;
                        if (salaryTypeId <= 0) {
                          _snack('job.form.validation.select_salary_type'.tr());
                          return;
                        }

                        final salaryMin =
                            double.tryParse(salaryFromController.text.trim()) ??
                            0;
                        final salaryMax =
                            double.tryParse(salaryToController.text.trim()) ??
                            0;
                        if (salaryMin <= 0 ||
                            salaryMax <= 0 ||
                            salaryMax < salaryMin) {
                          _snack(
                            'job.form.validation.enter_valid_salary_range'.tr(),
                          );
                          return;
                        }

                        if (_selectedShifts.isEmpty) {
                          _snack(
                            'job.form.validation.select_shift_type'.tr(),
                          );
                          return;
                        }

                        final workStartUi = workingFromController.text.trim();
                        final workEndUi = workingToController.text.trim();
                        if (workStartUi.isEmpty || workEndUi.isEmpty) {
                          _snack(
                            'job.form.validation.select_working_hours'.tr(),
                          );
                          return;
                        }

                        final workStart = _normalizeTimeForApi(workStartUi);
                        final workEnd = _normalizeTimeForApi(workEndUi);
                        if (workStart == null || workEnd == null) {
                          _snack(
                            'job.form.validation.invalid_working_hours'.tr(),
                          );
                          return;
                        }

                        if (_selectedWorkingDays.isEmpty) {
                          _snack(
                            'job.form.validation.select_working_days'.tr(),
                          );
                          return;
                        }

                        if (_vacancyNumberId == null) {
                          _snack('job.form.validation.select_vacancies'.tr());
                          return;
                        }

                        final vacancyItem = _vacancyNumbers.firstWhere(
                          (e) => e.id == _vacancyNumberId,
                          orElse: () => const IdName(id: '', name: ''),
                        );
                        final vacancyText = vacancyItem.name.trim();
                        final vacancyDigits =
                            RegExp(r'\d+').firstMatch(vacancyText)?.group(0) ??
                            '';
                        final noVacancy =
                            int.tryParse(vacancyDigits) ??
                            (int.tryParse(_vacancyNumberId ?? '') ?? 1);

                        double? lat = _jobLat ?? _currentLat;
                        double? lng = _jobLng ?? _currentLng;
                        if (lat == null || lng == null) {
                          try {
                            final point =
                                await LocationService.getCurrentLatLng();
                            lat = point?.lat;
                            lng = point?.lng;
                          } catch (_) {}
                        }

                        final skillIds = _selectedSkills
                            .map((e) => int.tryParse(e) ?? 0)
                            .where((e) => e > 0)
                            .toList(growable: false);
                        final experienceIds = _selectedExperiences
                            .map((e) => int.tryParse(e) ?? 0)
                            .where((e) => e > 0)
                            .toList(growable: false);
                        final qualificationIds = _selectedQualifications
                            .map((e) => int.tryParse(e) ?? 0)
                            .where((e) => e > 0)
                            .toList(growable: false);
                        final benefitIds = _selectedJobBenefits
                            .map((e) => int.tryParse(e) ?? 0)
                            .where((e) => e > 0)
                            .toList(growable: false);
                        final shiftIds = _selectedShifts
                            .map((e) => int.tryParse(e) ?? 0)
                            .where((e) => e > 0)
                            .toList(growable: false);

                        final genders = _selectedGenders.toList(
                          growable: false,
                        );

                        final jobDays = _selectedWorkingDays
                            .where((i) => i >= 0 && i < days.length)
                            .map((i) => days[i].toLowerCase())
                            .toList(growable: false);

                        final description = jobDescriptionController.text
                            .trim();
                        final jobDesignation = jobDesignationController.text
                            .trim();
                        final isHindi =
                            SharedPrefUtils.readStr(
                              SharedPrefUtils.APP_LANGUAGE,
                            ).trim() ==
                            'hi';

                        final payload = <String, dynamic>{
                          'job_profile_id': jobProfileId,
                          if (isHindi)
                            'job_designation_hindi': jobDesignation
                          else
                            'job_designation_english': jobDesignation,
                          'description_english': description,
                          'no_vacancy': noVacancy,
                          'is_household': _isHouseholdHelpJob,
                          'interviewer_contact': interviewerMobile,
                          'job_location': jobLocation,
                          if (jobAddress.isNotEmpty) 'job_address_english': jobAddress,
                          'job_state_id': jobStateId,
                          'job_city_id': jobCityId,
                          'salary_type_id': salaryTypeId,
                          'salary_min': salaryMin,
                          'salary_max': salaryMax,
                          'work_start_time': workStart,
                          'work_end_time': workEnd,
                          'skill_ids': skillIds,
                          'experience_ids': experienceIds,
                          'qualification_ids': qualificationIds,
                          'job_benefit_ids': benefitIds,
                          'shift_ids': shiftIds,
                          'genders': genders,
                          'job_days': jobDays,
                        };
                        if (lat != null && lng != null) {
                          payload['lat'] = lat;
                          payload['lng'] = lng;
                        }

                        if (widget.isEdit && widget.jobId != null) {
                          payload['id'] = widget.jobId;
                        }

                        setState(() => _isPosting = true);

                        if (!_isHouseholdHelpJob && !widget.isEdit) {
                          final userJson = SharedPrefUtils.readJson(
                            SharedPrefUtils.AUTH_USER_JSON,
                          );
                          final userId = _asInt(userJson?['id']);
                          if (userId > 0) {
                            final catId =
                                int.tryParse(_firmBusinessCategoryId ?? '') ?? 0;
                            await context
                                .read<EmployersProvider>()
                                .saveEmployerPersonalInfo(userId, {
                              'organization_name':
                                  _firmNameController.text.trim(),
                                if (catId > 0) 'business_category_id': catId,
                              'organization_type': 'firm',
                            });
                          }
                        }

                        if (!mounted) return;

                        final result = await _jobsService.saveEmployerJob(
                          employerId: employerId,
                          body: payload,
                        );
                        if (!mounted) return;

                        setState(() => _isPosting = false);

                        switch (result) {
                          case Success(value: _):
                            // ApiService already validates the response envelope
                            // (status/success) and only returns Success when the
                            // request succeeded. For POST saves, `resp` is usually
                            // the inner `data` object.
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (context) => PrimaryDialog(
                                widget.isEdit
                                    ? 'job.form.success.updated'.tr()
                                    : 'job.form.success.added'.tr(),
                              ),
                            ).whenComplete(() {
                              if (!mounted) return;
                              if (!widget.isEdit &&
                                  widget.clearStackToEmployerHomeOnSuccess) {
                                Navigator.of(
                                  context,
                                ).popUntil((route) => route.isFirst);
                                return;
                              }

                              Navigator.of(context).pop(true);
                            });
                            break;
                          case Failure(exception: final e):
                            if (e.code == 'NO_AD_CREDIT') {
                              if (!mounted) break;
                              await EmployerProfileActionGuard
                                  .showNoAdCreditDialog(
                                    context,
                                    'subscriptions.dialog.no_job_post_credits'
                                        .tr(),
                                  );
                              break;
                            }

                            _snack(e.message);
                            break;
                        }
                      },
                child: AppButtonChild(
                  label: _isPosting
                      ? (widget.isEdit
                            ? 'common.updating'.tr()
                            : 'common.posting'.tr())
                      : (widget.isEdit
                            ? 'common.update'.tr()
                            : 'common.post'.tr()),
                  isLoading: _isPosting,
                  loaderColor: context.colors.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
