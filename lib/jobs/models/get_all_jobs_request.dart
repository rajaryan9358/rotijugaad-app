import 'dart:convert';

class RangeFilter {
  final double? min;
  final double? max;

  const RangeFilter({this.min, this.max});

  Map<String, dynamic> toJson() {
    return {'min': min, 'max': max};
  }
}

class GetAllJobsRequest {
  final String search;

  final List<int> jobProfileIds;
  final List<int> preferredStateIds;
  final List<int> preferredCityIds;
  final List<int> salaryTypeIds;

  final List<int> skillIds;
  final List<int> qualificationIds;
  final List<int> shiftIds;
  final List<int> businessCategoryIds;

  final List<RangeFilter> salaryRanges;
  final List<RangeFilter> experienceRanges;
  final List<RangeFilter> distanceRanges;

  final String verification;
  final String gender;

  final int? employeeId;
  final double? lat;
  final double? lng;

  final int page;
  final int limit;

  const GetAllJobsRequest({
    this.search = '',
    this.jobProfileIds = const [],
    this.preferredStateIds = const [],
    this.preferredCityIds = const [],
    this.salaryTypeIds = const [],
    this.skillIds = const [],
    this.qualificationIds = const [],
    this.shiftIds = const [],
    this.businessCategoryIds = const [],
    this.salaryRanges = const [],
    this.experienceRanges = const [],
    this.distanceRanges = const [],
    this.verification = '',
    this.gender = '',
    this.employeeId,
    this.lat,
    this.lng,
    this.page = 1,
    this.limit = 10,
  });

  Map<String, dynamic> toJson() {
    return {
      'search': search,
      'job_profile_ids': jobProfileIds,
      'preferred_state_ids': preferredStateIds,
      'preferred_city_ids': preferredCityIds,
      'salary_type_ids': salaryTypeIds,
      'skill_ids': skillIds,
      'qualification_ids': qualificationIds,
      'shift_ids': shiftIds,
      'business_category_ids': businessCategoryIds,
      'salary_ranges': salaryRanges.map((e) => e.toJson()).toList(),
      'experience_ranges': experienceRanges.map((e) => e.toJson()).toList(),
      'distance_ranges': distanceRanges.map((e) => e.toJson()).toList(),
      'verification': verification,
      'gender': gender,
      'employee_id': employeeId,
      'lat': lat,
      'lng': lng,
      'page': page,
      'limit': limit,
    };
  }

  Map<String, String> toQueryParameters() {
    final params = <String, String>{};

    void setIfNotEmpty(String key, String value) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return;
      params[key] = trimmed;
    }

    void setIfPresent(String key, Object? value) {
      if (value == null) return;
      params[key] = value.toString();
    }

    String csv(List<int> values) => values.join(',');

    String jsonRanges(List<RangeFilter> values) {
      return jsonEncode(values.map((e) => e.toJson()).toList());
    }

    setIfNotEmpty('search', search);

    if (jobProfileIds.isNotEmpty) {
      params['job_profile_ids'] = csv(jobProfileIds);
    }
    if (preferredStateIds.isNotEmpty) {
      params['preferred_state_ids'] = csv(preferredStateIds);
    }
    if (preferredCityIds.isNotEmpty) {
      params['preferred_city_ids'] = csv(preferredCityIds);
    }
    if (salaryTypeIds.isNotEmpty) {
      params['salary_type_ids'] = csv(salaryTypeIds);
    }

    if (skillIds.isNotEmpty) params['skill_ids'] = csv(skillIds);
    if (qualificationIds.isNotEmpty) {
      params['qualification_ids'] = csv(qualificationIds);
    }
    if (shiftIds.isNotEmpty) params['shift_ids'] = csv(shiftIds);
    if (businessCategoryIds.isNotEmpty) {
      params['business_category_ids'] = csv(businessCategoryIds);
    }

    if (salaryRanges.isNotEmpty) {
      params['salary_ranges'] = jsonRanges(salaryRanges);
    }
    if (experienceRanges.isNotEmpty) {
      params['experience_ranges'] = jsonRanges(experienceRanges);
    }
    if (distanceRanges.isNotEmpty) {
      params['distance_ranges'] = jsonRanges(distanceRanges);
    }

    setIfNotEmpty('verification', verification);
    setIfNotEmpty('gender', gender);

    setIfPresent('employee_id', employeeId);
    setIfPresent('lat', lat);
    setIfPresent('lng', lng);

    params['page'] = page.toString();
    params['limit'] = limit.toString();

    return params;
  }
}
