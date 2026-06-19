import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../storage/app_database.dart';
import '../models/document_dtos.dart';
import '../models/job_profile_dtos.dart';
import '../models/location_dtos.dart';
import '../models/masters_bundle.dart';
import '../models/misc_dtos.dart';
import '../models/work_dtos.dart';

class MastersDb {
  Future<Database> get _db async => AppDatabase.instance();

  static const List<String> _masterTables = [
    'masters_states',
    'masters_cities',
    'masters_skills',
    'masters_qualifications',
    'masters_shifts',
    'masters_job_profiles',
    'masters_document_types',
    'masters_additional_document_types',
    'masters_work_natures',
    'masters_business_categories',
    'masters_experiences',
    'masters_salary_types',
    'masters_salary_ranges',
    'masters_distances',
    'masters_employee_call_experiences',
    'masters_employee_report_reasons',
    'masters_employer_call_experiences',
    'masters_employer_report_reasons',
    'masters_vacancy_numbers',
    'masters_job_benefits',
  ];

  Future<void> saveBundle(MastersBundle bundle) async {
    final db = await _db;
    final batch = db.batch();

    for (final table in _masterTables) {
      batch.delete(table);
    }

    void upsertList(
      String table,
      List<dynamic> items, {
      String idKey = 'id',
      String? sequenceKey = 'sequence',
      Map<String, dynamic> Function(Map<String, dynamic> item)? extra,
    }) {
      for (final it in items) {
        if (it is! Map) continue;
        final item = Map<String, dynamic>.from(it);
        final id = item[idKey];
        if (id is! num) continue;

        final row = <String, Object?>{
          'id': id.toInt(),
          if (sequenceKey != null)
            'sequence': (item[sequenceKey] as num?)?.toInt(),
          'json': jsonEncode(item),
          ...?extra?.call(item),
        };

        batch.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }

    upsertList('masters_states', bundle.raw['states'] as List? ?? const []);
    upsertList(
      'masters_cities',
      bundle.raw['cities'] as List? ?? const [],
      extra: (m) => {'state_id': (m['state_id'] as num?)?.toInt()},
    );
    upsertList('masters_skills', bundle.raw['skills'] as List? ?? const []);
    upsertList(
      'masters_qualifications',
      bundle.raw['qualifications'] as List? ?? const [],
    );
    upsertList('masters_shifts', bundle.raw['shifts'] as List? ?? const []);
    upsertList(
      'masters_job_profiles',
      bundle.raw['job_profiles'] as List? ?? const [],
    );
    upsertList(
      'masters_document_types',
      bundle.raw['document_types'] as List? ?? const [],
    );
    upsertList(
      'masters_additional_document_types',
      bundle.raw['additional_document_types'] as List? ?? const [],
    );
    upsertList(
      'masters_work_natures',
      bundle.raw['work_natures'] as List? ?? const [],
    );
    upsertList(
      'masters_business_categories',
      bundle.raw['business_categories'] as List? ?? const [],
    );
    upsertList(
      'masters_experiences',
      bundle.raw['experiences'] as List? ?? const [],
    );
    upsertList(
      'masters_salary_types',
      bundle.raw['salary_types'] as List? ?? const [],
    );
    upsertList(
      'masters_salary_ranges',
      bundle.raw['salary_ranges'] as List? ?? const [],
    );
    upsertList(
      'masters_distances',
      bundle.raw['distances'] as List? ?? const [],
    );
    upsertList(
      'masters_employee_call_experiences',
      bundle.raw['employee_call_experiences'] as List? ?? const [],
    );
    upsertList(
      'masters_employee_report_reasons',
      bundle.raw['employee_report_reasons'] as List? ?? const [],
    );
    upsertList(
      'masters_employer_call_experiences',
      bundle.raw['employer_call_experiences'] as List? ?? const [],
    );
    upsertList(
      'masters_employer_report_reasons',
      bundle.raw['employer_report_reasons'] as List? ?? const [],
    );
    upsertList(
      'masters_vacancy_numbers',
      bundle.raw['vacancy_numbers'] as List? ?? const [],
    );
    upsertList(
      'masters_job_benefits',
      bundle.raw['job_benefits'] as List? ?? const [],
    );

    await batch.commit(noResult: true);
  }

  Future<List<T>> _readAll<T>(
    String table,
    T Function(Map<String, dynamic>? json) fromJson, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await _db;
    final rows = await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'sequence IS NULL, sequence ASC, id ASC',
    );

    return rows
        .map((r) {
          final raw = r['json'];
          if (raw is! String) return null;
          try {
            final decoded = jsonDecode(raw);
            return decoded is Map<String, dynamic> ? fromJson(decoded) : null;
          } catch (_) {
            return null;
          }
        })
        .whereType<T>()
        .toList();
  }

  Future<List<StateDto>> getStates() =>
      _readAll('masters_states', StateDto.fromJson);

  Future<List<CityDto>> getCities({int? stateId}) {
    return _readAll(
      'masters_cities',
      CityDto.fromJson,
      where: stateId == null ? null : 'state_id = ?',
      whereArgs: stateId == null ? null : [stateId],
    );
  }

  Future<List<SkillDto>> getSkills() =>
      _readAll('masters_skills', SkillDto.fromJson);

  Future<List<QualificationDto>> getQualifications() =>
      _readAll('masters_qualifications', QualificationDto.fromJson);

  Future<List<ShiftDto>> getShifts() =>
      _readAll('masters_shifts', ShiftDto.fromJson);

  Future<List<JobProfileDto>> getJobProfiles() =>
      _readAll('masters_job_profiles', JobProfileDto.fromJson);

  Future<List<DocumentTypeDto>> getDocumentTypes() =>
      _readAll('masters_document_types', DocumentTypeDto.fromJson);

  Future<List<DocumentTypeDto>> getAdditionalDocumentTypes() =>
      _readAll('masters_additional_document_types', DocumentTypeDto.fromJson);

  Future<List<WorkNatureDto>> getWorkNatures() =>
      _readAll('masters_work_natures', WorkNatureDto.fromJson);

  Future<List<BusinessCategoryDto>> getBusinessCategories() =>
      _readAll('masters_business_categories', BusinessCategoryDto.fromJson);

  Future<List<ExperienceDto>> getExperiences() =>
      _readAll('masters_experiences', ExperienceDto.fromJson);

  Future<List<SalaryTypeDto>> getSalaryTypes() =>
      _readAll('masters_salary_types', SalaryTypeDto.fromJson);

  Future<List<SalaryRangeDto>> getSalaryRanges() =>
      _readAll('masters_salary_ranges', SalaryRangeDto.fromJson);

  Future<List<DistanceDto>> getDistances() =>
      _readAll('masters_distances', DistanceDto.fromJson);

  Future<List<CallExperienceDto>> getEmployeeCallExperiences() =>
      _readAll('masters_employee_call_experiences', CallExperienceDto.fromJson);

  Future<List<ReportReasonDto>> getEmployeeReportReasons() =>
      _readAll('masters_employee_report_reasons', ReportReasonDto.fromJson);

  Future<List<CallExperienceDto>> getEmployerCallExperiences() =>
      _readAll('masters_employer_call_experiences', CallExperienceDto.fromJson);

  Future<List<ReportReasonDto>> getEmployerReportReasons() =>
      _readAll('masters_employer_report_reasons', ReportReasonDto.fromJson);

  Future<List<VacancyNumberDto>> getVacancyNumbers() =>
      _readAll('masters_vacancy_numbers', VacancyNumberDto.fromJson);

  Future<List<JobBenefitDto>> getJobBenefits() =>
      _readAll('masters_job_benefits', JobBenefitDto.fromJson);
}
