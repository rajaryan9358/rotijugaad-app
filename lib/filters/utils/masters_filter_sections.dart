import '../models/filter_option.dart';
import '../models/filter_section.dart';
import '../../masters/providers/masters_provider.dart';
import '../../masters/models/job_profile_dtos.dart';
import '../../masters/models/location_dtos.dart';
import '../../masters/models/work_dtos.dart';
import '../../masters/models/misc_dtos.dart';
import 'package:intl/intl.dart';

class MastersFilterSections {
  static String _pickLabel({
    required bool isHindi,
    String? english,
    String? hindi,
  }) {
    final primary = isHindi ? hindi : english;
    final secondary = isHindi ? english : hindi;
    final label = (primary ?? secondary ?? '').trim();
    return label;
  }

  static final NumberFormat _salaryNumberFormat = NumberFormat.decimalPattern(
    'en_IN',
  );

  static List<FilterOption> _optionsFromSalaryRanges(
    List<SalaryRangeDto> items, {
    required bool isHindi,
  }) {
    String fmt(double v) {
      final n = v.round();
      return _salaryNumberFormat.format(n);
    }

    String labelFor(SalaryRangeDto s) {
      final from = s.salaryFrom;
      final to = s.salaryTo;
      if (from != null && to != null) {
        return '${fmt(from)} - ${fmt(to)}';
      }
      if (from != null) {
        return 'Above ${fmt(from)}';
      }
      if (to != null) {
        return 'Up to ${fmt(to)}';
      }
      return '';
    }

    final sorted =
        items
            .where((e) => e.isActive != false)
            .where((e) => e.salaryFrom != null || e.salaryTo != null)
            .toList()
          ..sort((a, b) {
            final af = a.salaryFrom ?? double.negativeInfinity;
            final bf = b.salaryFrom ?? double.negativeInfinity;
            if (af != bf) return af.compareTo(bf);
            final at = a.salaryTo ?? double.infinity;
            final bt = b.salaryTo ?? double.infinity;
            if (at != bt) return at.compareTo(bt);
            return a.id.compareTo(b.id);
          });

    return sorted
        .map((e) => FilterOption(e.id.toString(), labelFor(e)))
        .where((o) => o.label.trim().isNotEmpty)
        .toList();
  }

  static List<FilterOption> _optionsFromBusinessCategories(
    List<BusinessCategoryDto> items, {
    required bool isHindi,
  }) {
    final sorted = [...items]
      ..sort((a, b) {
        final sa = a.sequence ?? 1 << 30;
        final sb = b.sequence ?? 1 << 30;
        if (sa != sb) return sa.compareTo(sb);
        final la = _pickLabel(
          isHindi: isHindi,
          english: a.categoryEnglish,
          hindi: a.categoryHindi,
        );
        final lb = _pickLabel(
          isHindi: isHindi,
          english: b.categoryEnglish,
          hindi: b.categoryHindi,
        );
        return la.compareTo(lb);
      });

    return sorted
        .map(
          (e) => FilterOption(
            e.id.toString(),
            _pickLabel(
              isHindi: isHindi,
              english: e.categoryEnglish,
              hindi: e.categoryHindi,
            ),
          ),
        )
        .where((o) => o.label.trim().isNotEmpty)
        .toList();
  }

  static List<FilterOption> _optionsFromRawGenders(
    dynamic raw, {
    required bool isHindi,
  }) {
    if (raw is! List) return const [];

    final options = <FilterOption>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final value = Map<String, dynamic>.from(item);
      final id = (value['id'] ?? value['value'] ?? '').toString().trim();
      if (id.isEmpty) continue;

      final label = _pickLabel(
        isHindi: isHindi,
        english:
            (value['gender_english'] ??
                    value['title_english'] ??
                    value['name_english'])
                ?.toString(),
        hindi:
            (value['gender_hindi'] ??
                    value['title_hindi'] ??
                    value['name_hindi'])
                ?.toString(),
      );
      if (label.isEmpty) continue;

      options.add(FilterOption(id, label));
    }

    return options;
  }

  static List<FilterOption> _optionsFromJobProfiles(
    List<JobProfileDto> items, {
    required bool isHindi,
  }) {
    final sorted = [...items]
      ..sort((a, b) {
        final sa = a.sequence ?? 1 << 30;
        final sb = b.sequence ?? 1 << 30;
        if (sa != sb) return sa.compareTo(sb);
        final la = _pickLabel(
          isHindi: isHindi,
          english: a.profileEnglish,
          hindi: a.profileHindi,
        );
        final lb = _pickLabel(
          isHindi: isHindi,
          english: b.profileEnglish,
          hindi: b.profileHindi,
        );
        return la.compareTo(lb);
      });

    return sorted
        .map(
          (e) => FilterOption(
            e.id.toString(),
            _pickLabel(
              isHindi: isHindi,
              english: e.profileEnglish,
              hindi: e.profileHindi,
            ),
          ),
        )
        .where((o) => o.label.trim().isNotEmpty)
        .toList();
  }

  static List<FilterOption> _optionsFromStates(
    List<StateDto> items, {
    required bool isHindi,
  }) {
    final sorted = [...items]
      ..sort((a, b) {
        final sa = a.sequence ?? 1 << 30;
        final sb = b.sequence ?? 1 << 30;
        if (sa != sb) return sa.compareTo(sb);
        final la = _pickLabel(
          isHindi: isHindi,
          english: a.stateEnglish,
          hindi: a.stateHindi,
        );
        final lb = _pickLabel(
          isHindi: isHindi,
          english: b.stateEnglish,
          hindi: b.stateHindi,
        );
        return la.compareTo(lb);
      });

    return sorted
        .map(
          (e) => FilterOption(
            e.id.toString(),
            _pickLabel(
              isHindi: isHindi,
              english: e.stateEnglish,
              hindi: e.stateHindi,
            ),
          ),
        )
        .where((o) => o.label.trim().isNotEmpty)
        .toList();
  }

  static List<FilterOption> _optionsFromCities(
    List<CityDto> items, {
    required bool isHindi,
  }) {
    final sorted = [...items]
      ..sort((a, b) {
        final sa = a.sequence ?? 1 << 30;
        final sb = b.sequence ?? 1 << 30;
        if (sa != sb) return sa.compareTo(sb);
        final la = _pickLabel(
          isHindi: isHindi,
          english: a.cityEnglish,
          hindi: a.cityHindi,
        );
        final lb = _pickLabel(
          isHindi: isHindi,
          english: b.cityEnglish,
          hindi: b.cityHindi,
        );
        return la.compareTo(lb);
      });

    return sorted
        .map(
          (e) => FilterOption(
            e.id.toString(),
            _pickLabel(
              isHindi: isHindi,
              english: e.cityEnglish,
              hindi: e.cityHindi,
            ),
          ),
        )
        .where((o) => o.label.trim().isNotEmpty)
        .toList();
  }

  static List<FilterOption> _optionsFromSkills(
    List<SkillDto> items, {
    required bool isHindi,
  }) {
    final sorted = [...items]
      ..sort((a, b) {
        final sa = a.sequence ?? 1 << 30;
        final sb = b.sequence ?? 1 << 30;
        if (sa != sb) return sa.compareTo(sb);
        final la = _pickLabel(
          isHindi: isHindi,
          english: a.skillEnglish,
          hindi: a.skillHindi,
        );
        final lb = _pickLabel(
          isHindi: isHindi,
          english: b.skillEnglish,
          hindi: b.skillHindi,
        );
        return la.compareTo(lb);
      });

    return sorted
        .map(
          (e) => FilterOption(
            e.id.toString(),
            _pickLabel(
              isHindi: isHindi,
              english: e.skillEnglish,
              hindi: e.skillHindi,
            ),
          ),
        )
        .where((o) => o.label.trim().isNotEmpty)
        .toList();
  }

  static List<FilterOption> _optionsFromQualifications(
    List<QualificationDto> items, {
    required bool isHindi,
  }) {
    final sorted = [...items]
      ..sort((a, b) {
        final sa = a.sequence ?? 1 << 30;
        final sb = b.sequence ?? 1 << 30;
        if (sa != sb) return sa.compareTo(sb);
        final la = _pickLabel(
          isHindi: isHindi,
          english: a.qualificationEnglish,
          hindi: a.qualificationHindi,
        );
        final lb = _pickLabel(
          isHindi: isHindi,
          english: b.qualificationEnglish,
          hindi: b.qualificationHindi,
        );
        return la.compareTo(lb);
      });

    return sorted
        .map(
          (e) => FilterOption(
            e.id.toString(),
            _pickLabel(
              isHindi: isHindi,
              english: e.qualificationEnglish,
              hindi: e.qualificationHindi,
            ),
          ),
        )
        .where((o) => o.label.trim().isNotEmpty)
        .toList();
  }

  static List<FilterOption> _optionsFromExperiences(
    List<ExperienceDto> items, {
    required bool isHindi,
  }) {
    final sorted = [...items]
      ..sort((a, b) {
        final sa = a.sequence ?? 1 << 30;
        final sb = b.sequence ?? 1 << 30;
        if (sa != sb) return sa.compareTo(sb);
        final la = _pickLabel(
          isHindi: isHindi,
          english: a.titleEnglish,
          hindi: a.titleHindi,
        );
        final lb = _pickLabel(
          isHindi: isHindi,
          english: b.titleEnglish,
          hindi: b.titleHindi,
        );
        return la.compareTo(lb);
      });

    return sorted
        .map(
          (e) => FilterOption(
            e.id.toString(),
            _pickLabel(
              isHindi: isHindi,
              english: e.titleEnglish,
              hindi: e.titleHindi,
            ),
          ),
        )
        .where((o) => o.label.trim().isNotEmpty)
        .toList();
  }

  static List<FilterOption> _optionsFromSalaryTypes(
    List<SalaryTypeDto> items, {
    required bool isHindi,
  }) {
    final sorted = [...items]
      ..sort((a, b) {
        final sa = a.sequence ?? 1 << 30;
        final sb = b.sequence ?? 1 << 30;
        if (sa != sb) return sa.compareTo(sb);
        final la = _pickLabel(
          isHindi: isHindi,
          english: a.typeEnglish,
          hindi: a.typeHindi,
        );
        final lb = _pickLabel(
          isHindi: isHindi,
          english: b.typeEnglish,
          hindi: b.typeHindi,
        );
        return la.compareTo(lb);
      });

    return sorted
        .map(
          (e) => FilterOption(
            e.id.toString(),
            _pickLabel(
              isHindi: isHindi,
              english: e.typeEnglish,
              hindi: e.typeHindi,
            ),
          ),
        )
        .where((o) => o.label.trim().isNotEmpty)
        .toList();
  }

  static List<FilterOption> _jobVerificationOptions({required bool isHindi}) {
    return [
      FilterOption('verified', isHindi ? 'सत्यापित' : 'Verified'),
      FilterOption('not_verified', isHindi ? 'सत्यापित नहीं' : 'Not Verified'),
    ];
  }

  static List<FilterOption> _optionsFromShifts(
    List<ShiftDto> items, {
    required bool isHindi,
  }) {
    final sorted = [...items]
      ..sort((a, b) {
        final sa = a.sequence ?? 1 << 30;
        final sb = b.sequence ?? 1 << 30;
        if (sa != sb) return sa.compareTo(sb);
        final la = _pickLabel(
          isHindi: isHindi,
          english: a.shiftEnglish,
          hindi: a.shiftHindi,
        );
        final lb = _pickLabel(
          isHindi: isHindi,
          english: b.shiftEnglish,
          hindi: b.shiftHindi,
        );
        return la.compareTo(lb);
      });

    return sorted
        .map(
          (e) => FilterOption(
            e.id.toString(),
            _pickLabel(
              isHindi: isHindi,
              english: e.shiftEnglish,
              hindi: e.shiftHindi,
            ),
          ),
        )
        .where((o) => o.label.trim().isNotEmpty)
        .toList();
  }

  static List<FilterOption> _optionsFromDistances(
    List<DistanceDto> items, {
    required bool isHindi,
  }) {
    final sorted = [...items]
      ..sort((a, b) {
        final sa = a.sequence ?? 1 << 30;
        final sb = b.sequence ?? 1 << 30;
        if (sa != sb) return sa.compareTo(sb);
        final la = _pickLabel(
          isHindi: isHindi,
          english: a.titleEnglish,
          hindi: a.titleHindi,
        );
        final lb = _pickLabel(
          isHindi: isHindi,
          english: b.titleEnglish,
          hindi: b.titleHindi,
        );
        return la.compareTo(lb);
      });

    return sorted
        .map(
          (e) => FilterOption(
            e.id.toString(),
            _pickLabel(
              isHindi: isHindi,
              english: e.titleEnglish,
              hindi: e.titleHindi,
            ),
          ),
        )
        .where((o) => o.label.trim().isNotEmpty)
        .toList();
  }

  static Future<List<FilterSection>> buildJobs(
    MastersProvider provider, {
    required bool isHindi,
  }) async {
    try {
      await provider.loadMasters();

      final results = await Future.wait([
        provider.getJobProfilesFromDb(),
        provider.getStatesFromDb(),
        provider.getCitiesFromDb(),
        provider.getSkillsFromDb(),
        provider.getQualificationsFromDb(),
        provider.getBusinessCategoriesFromDb(),
        provider.getExperiencesFromDb(),
        provider.getSalaryTypesFromDb(),
        provider.getSalaryRangesFromDb(),
        provider.getShiftsFromDb(),
        provider.getDistancesFromDb(),
      ]);

      final jobProfiles = results[0] as List<JobProfileDto>;
      final states = results[1] as List<StateDto>;
      final cities = results[2] as List<CityDto>;
      final skills = results[3] as List<SkillDto>;
      final qualifications = results[4] as List<QualificationDto>;
      final businessCategories = results[5] as List<BusinessCategoryDto>;
      final experiences = results[6] as List<ExperienceDto>;
      final salaryTypes = results[7] as List<SalaryTypeDto>;
      final salaryRanges = results[8] as List<SalaryRangeDto>;
      final shifts = results[9] as List<ShiftDto>;
      final distances = results[10] as List<DistanceDto>;
      final genders = _optionsFromRawGenders(
        provider.masters?.raw['job_genders'],
        isHindi: isHindi,
      );

      return [
        FilterSection(
          id: 'job_profile',
          title: 'filters.sections.job_profile',
          options: _optionsFromJobProfiles(jobProfiles, isHindi: isHindi),
        ),
        FilterSection(
          id: 'preferred_state',
          title: 'filters.sections.preferred_state',
          options: _optionsFromStates(states, isHindi: isHindi),
        ),
        FilterSection(
          id: 'preferred_city',
          title: 'filters.sections.preferred_city',
          options: _optionsFromCities(cities, isHindi: isHindi),
        ),
        FilterSection(
          id: 'salary_range',
          title: 'filters.sections.salary_range',
          options: _optionsFromSalaryRanges(salaryRanges, isHindi: isHindi),
        ),
        FilterSection(
          id: 'skill',
          title: 'filters.sections.skill',
          options: _optionsFromSkills(skills, isHindi: isHindi),
        ),
        FilterSection(
          id: 'business_category',
          title: 'filters.sections.business_category',
          options: _optionsFromBusinessCategories(
            businessCategories,
            isHindi: isHindi,
          ),
        ),
        FilterSection(
          id: 'verification_status',
          title: 'filters.sections.verification_status',
          options: _jobVerificationOptions(isHindi: isHindi),
          singleSelect: true,
        ),
        FilterSection(
          id: 'qualification',
          title: 'filters.sections.qualification',
          options: _optionsFromQualifications(qualifications, isHindi: isHindi),
        ),
        FilterSection(
          id: 'experience',
          title: 'filters.sections.experience',
          options: _optionsFromExperiences(experiences, isHindi: isHindi),
        ),
        FilterSection(
          id: 'gender',
          title: 'filters.sections.gender',
          options: genders,
        ),
        FilterSection(
          id: 'salary_type',
          title: 'filters.sections.salary_type',
          options: _optionsFromSalaryTypes(salaryTypes, isHindi: isHindi),
        ),
        FilterSection(
          id: 'shift',
          title: 'filters.sections.shift',
          options: _optionsFromShifts(shifts, isHindi: isHindi),
        ),
        FilterSection(
          id: 'distance',
          title: 'filters.sections.distance',
          options: _optionsFromDistances(distances, isHindi: isHindi),
        ),
      ].where((s) => s.options.isNotEmpty).toList();
    } catch (_) {
      try {
        final salaryRanges = await provider.getSalaryRangesFromDb();
        final businessCategories = await provider.getBusinessCategoriesFromDb();
        return [
          FilterSection(
            id: 'salary_range',
            title: 'filters.sections.salary_range',
            options: _optionsFromSalaryRanges(salaryRanges, isHindi: isHindi),
          ),
          FilterSection(
            id: 'business_category',
            title: 'filters.sections.business_category',
            options: _optionsFromBusinessCategories(
              businessCategories,
              isHindi: isHindi,
            ),
          ),
        ].where((s) => s.options.isNotEmpty).toList();
      } catch (_) {
        return const [];
      }
    }
  }

  static Future<List<FilterSection>> buildCandidates(
    MastersProvider provider, {
    required bool isHindi,
  }) async {
    try {
      await provider.loadMasters();

      final results = await Future.wait([
        provider.getJobProfilesFromDb(),
        provider.getStatesFromDb(),
        provider.getCitiesFromDb(),
        provider.getQualificationsFromDb(),
        provider.getExperiencesFromDb(),
        provider.getShiftsFromDb(),
        provider.getDistancesFromDb(),
        provider.getSkillsFromDb(),
        provider.getSalaryRangesFromDb(),
      ]);

      final jobProfiles = results[0] as List<JobProfileDto>;
      final states = results[1] as List<StateDto>;
      final cities = results[2] as List<CityDto>;
      final qualifications = results[3] as List<QualificationDto>;
      final experiences = results[4] as List<ExperienceDto>;
      final shifts = results[5] as List<ShiftDto>;
      final distances = results[6] as List<DistanceDto>;
      final skills = results[7] as List<SkillDto>;
      final salaryRanges = results[8] as List<SalaryRangeDto>;
      final genders = _optionsFromRawGenders(
        provider.masters?.raw['job_genders'],
        isHindi: isHindi,
      );

      return [
        FilterSection(
          id: 'job_profile',
          title: 'filters.sections.job_profile',
          options: _optionsFromJobProfiles(jobProfiles, isHindi: isHindi),
        ),
        FilterSection(
          id: 'preferred_state',
          title: 'filters.sections.preferred_state',
          options: _optionsFromStates(states, isHindi: isHindi),
        ),
        FilterSection(
          id: 'preferred_city',
          title: 'filters.sections.preferred_city',
          options: _optionsFromCities(cities, isHindi: isHindi),
        ),
        FilterSection(
          id: 'salary_range',
          title: 'filters.sections.salary_range',
          options: _optionsFromSalaryRanges(salaryRanges, isHindi: isHindi),
        ),
        FilterSection(
          id: 'skill',
          title: 'filters.sections.skill',
          options: _optionsFromSkills(skills, isHindi: isHindi),
        ),
        FilterSection(
          id: 'verification_status',
          title: 'filters.sections.verification_status',
          options: _jobVerificationOptions(isHindi: isHindi),
          singleSelect: true,
        ),
        FilterSection(
          id: 'qualification',
          title: 'filters.sections.qualification',
          options: _optionsFromQualifications(qualifications, isHindi: isHindi),
        ),
        FilterSection(
          id: 'experience',
          title: 'filters.sections.experience',
          options: _optionsFromExperiences(experiences, isHindi: isHindi),
        ),
        FilterSection(
          id: 'gender',
          title: 'filters.sections.gender',
          options: genders,
        ),
        FilterSection(
          id: 'shift',
          title: 'filters.sections.shift',
          options: _optionsFromShifts(shifts, isHindi: isHindi),
        ),
        FilterSection(
          id: 'distance',
          title: 'filters.sections.distance',
          options: _optionsFromDistances(distances, isHindi: isHindi),
        ),
      ].where((s) => s.options.isNotEmpty).toList();
    } catch (_) {
      return const [];
    }
  }
}
