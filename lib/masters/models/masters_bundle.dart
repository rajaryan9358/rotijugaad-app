import "json_helpers.dart";
import "location_dtos.dart";
import "work_dtos.dart";
import "job_profile_dtos.dart";
import "document_dtos.dart";
import "misc_dtos.dart";

class MastersBundle {
  final List<StateDto> states;
  final List<CityDto> cities;
  final List<SkillDto> skills;
  final List<QualificationDto> qualifications;
  final List<ShiftDto> shifts;
  final List<JobProfileDto> jobProfiles;
  final List<DocumentTypeDto> documentTypes;
  final List<DocumentTypeDto> additionalDocumentTypes;
  final List<WorkNatureDto> workNatures;
  final List<ExperienceDto> experiences;
  final List<SalaryTypeDto> salaryTypes;
  final List<DistanceDto> distances;
  final List<CallExperienceDto> employeeCallExperiences;
  final List<ReportReasonDto> employeeReportReasons;
  final List<CallExperienceDto> employerCallExperiences;
  final List<ReportReasonDto> employerReportReasons;
  final List<VacancyNumberDto> vacancyNumbers;
  final List<JobBenefitDto> jobBenefits;

  /// Entire backend payload for forward-compat with new master keys.
  final Map<String, dynamic> raw;

  const MastersBundle({
    required this.states,
    required this.cities,
    required this.skills,
    required this.qualifications,
    required this.shifts,
    required this.jobProfiles,
    required this.documentTypes,
    required this.additionalDocumentTypes,
    required this.workNatures,
    required this.experiences,
    required this.salaryTypes,
    required this.distances,
    required this.employeeCallExperiences,
    required this.employeeReportReasons,
    required this.employerCallExperiences,
    required this.employerReportReasons,
    required this.vacancyNumbers,
    required this.jobBenefits,
    required this.raw,
  });

  factory MastersBundle.fromJson(Map<String, dynamic>? json) {
    final payload = json ?? const <String, dynamic>{};

    return MastersBundle(
      states: asMapList(payload["states"]).map(StateDto.fromJson).toList(),
      cities: asMapList(payload["cities"]).map(CityDto.fromJson).toList(),
      skills: asMapList(payload["skills"]).map(SkillDto.fromJson).toList(),
      qualifications: asMapList(
        payload["qualifications"],
      ).map(QualificationDto.fromJson).toList(),
      shifts: asMapList(payload["shifts"]).map(ShiftDto.fromJson).toList(),
      jobProfiles: asMapList(
        payload["job_profiles"],
      ).map(JobProfileDto.fromJson).toList(),
      documentTypes: asMapList(
        payload["document_types"],
      ).map(DocumentTypeDto.fromJson).toList(),
      additionalDocumentTypes: asMapList(
        payload["additional_document_types"],
      ).map(DocumentTypeDto.fromJson).toList(),
      workNatures: asMapList(
        payload["work_natures"],
      ).map(WorkNatureDto.fromJson).toList(),
      experiences: asMapList(
        payload["experiences"],
      ).map(ExperienceDto.fromJson).toList(),
      salaryTypes: asMapList(
        payload["salary_types"],
      ).map(SalaryTypeDto.fromJson).toList(),
      distances: asMapList(
        payload["distances"],
      ).map(DistanceDto.fromJson).toList(),
      employeeCallExperiences: asMapList(
        payload["employee_call_experiences"],
      ).map(CallExperienceDto.fromJson).toList(),
      employeeReportReasons: asMapList(
        payload["employee_report_reasons"],
      ).map(ReportReasonDto.fromJson).toList(),
      employerCallExperiences: asMapList(
        payload["employer_call_experiences"],
      ).map(CallExperienceDto.fromJson).toList(),
      employerReportReasons: asMapList(
        payload["employer_report_reasons"],
      ).map(ReportReasonDto.fromJson).toList(),
      vacancyNumbers: asMapList(
        payload["vacancy_numbers"],
      ).map(VacancyNumberDto.fromJson).toList(),
      jobBenefits: asMapList(
        payload["job_benefits"],
      ).map(JobBenefitDto.fromJson).toList(),
      raw: payload,
    );
  }
}
