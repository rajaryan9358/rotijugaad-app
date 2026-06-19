import "package:flutter/foundation.dart";
import "package:flutter/scheduler.dart";
import "package:flutter/widgets.dart";

import "../../utils/custom_exception.dart";
import "../../utils/result.dart";
import "../models/masters_bundle.dart";
import "../models/location_dtos.dart";
import "../models/work_dtos.dart";
import "../models/job_profile_dtos.dart";
import "../models/document_dtos.dart";
import "../models/misc_dtos.dart";
import "../services/masters_service.dart";
import "../storage/masters_db.dart";

class MastersProvider extends ChangeNotifier {
  final MastersService _service;
  final MastersDb _db;

  MastersBundle? masters;
  bool isLoading = false;
  CustomException? lastError;

  MastersProvider({MastersService? service})
    : _service = service ?? MastersService(),
      _db = MastersDb();

  void _notifySafely() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!hasListeners) return;
        notifyListeners();
      });
      return;
    }
    notifyListeners();
  }

  Future<void> loadMasters({bool force = false}) async {
    if (!force && masters != null) return;

    isLoading = true;
    lastError = null;
    _notifySafely();

    final result = await _service.getAllMasters();

    switch (result) {
      case Success(value: final bundle):
        masters = bundle;
        await _db.saveBundle(bundle);
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isLoading = false;
    _notifySafely();
  }

  Future<List<StateDto>> getStatesFromDb() => _db.getStates();
  Future<List<CityDto>> getCitiesFromDb({int? stateId}) =>
      _db.getCities(stateId: stateId);

  Future<Result<List<CityDto>, CustomException>> getCitiesByStateFromApi(
    int stateId,
  ) => _service.getCitiesByState(stateId);
  Future<List<SkillDto>> getSkillsFromDb() => _db.getSkills();
  Future<List<QualificationDto>> getQualificationsFromDb() =>
      _db.getQualifications();
  Future<List<ShiftDto>> getShiftsFromDb() => _db.getShifts();
  Future<List<JobProfileDto>> getJobProfilesFromDb() => _db.getJobProfiles();
  Future<List<DocumentTypeDto>> getDocumentTypesFromDb() =>
      _db.getDocumentTypes();
  Future<List<DocumentTypeDto>> getAdditionalDocumentTypesFromDb() =>
      _db.getAdditionalDocumentTypes();
  Future<List<WorkNatureDto>> getWorkNaturesFromDb() => _db.getWorkNatures();
  Future<List<BusinessCategoryDto>> getBusinessCategoriesFromDb() =>
      _db.getBusinessCategories();
  Future<List<ExperienceDto>> getExperiencesFromDb() => _db.getExperiences();
  Future<List<SalaryTypeDto>> getSalaryTypesFromDb() => _db.getSalaryTypes();
  Future<List<SalaryRangeDto>> getSalaryRangesFromDb() => _db.getSalaryRanges();
  Future<List<DistanceDto>> getDistancesFromDb() => _db.getDistances();
  Future<List<CallExperienceDto>> getEmployeeCallExperiencesFromDb() =>
      _db.getEmployeeCallExperiences();
  Future<List<ReportReasonDto>> getEmployeeReportReasonsFromDb() =>
      _db.getEmployeeReportReasons();
  Future<List<CallExperienceDto>> getEmployerCallExperiencesFromDb() =>
      _db.getEmployerCallExperiences();
  Future<List<ReportReasonDto>> getEmployerReportReasonsFromDb() =>
      _db.getEmployerReportReasons();

  Future<List<VacancyNumberDto>> getVacancyNumbersFromDb() =>
      _db.getVacancyNumbers();

  Future<List<JobBenefitDto>> getJobBenefitsFromDb() => _db.getJobBenefits();

  void reset() {
    masters = null;
    isLoading = false;
    lastError = null;
    _notifySafely();
  }
}
