import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../utils/custom_exception.dart';
import '../../utils/result.dart';
import '../models/candidate_summary.dart';
import '../services/candidates_service.dart';

class CandidatesProvider extends ChangeNotifier {
  final CandidatesService _service;
  final Set<int> _shortlistUpdatingIds = <int>{};

  bool isLoadingAll = false;
  bool isLoadingRecommended = false;
  CustomException? lastError;

  List<CandidateSummaryDto> allCandidates = const [];
  List<CandidateSummaryDto> recommendedCandidates = const [];

  CandidatesProvider({CandidatesService? service})
    : _service = service ?? CandidatesService();

  void _notifySafely() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!hasListeners) return;
        super.notifyListeners();
      });
      return;
    }

    super.notifyListeners();
  }

  void clearError() {
    lastError = null;
    _notifySafely();
  }

  bool isShortlistUpdating(int candidateId) =>
      _shortlistUpdatingIds.contains(candidateId);

  bool _readShortlisted(Map<String, dynamic> data) {
    final raw = data['is_shortlisted'] ?? data['isShortlisted'];
    if (raw is bool) return raw;
    final s = raw?.toString().trim().toLowerCase();
    return s == 'true' || s == '1';
  }

  String? _readShortlistedAt(Map<String, dynamic> data) {
    final value = (data['shortlisted_at'] ?? data['shortlistedAt'])?.toString();
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }

  void _updateShortlistState({
    required int candidateId,
    required bool isShortlisted,
    String? shortlistedAt,
  }) {
    allCandidates = allCandidates
        .map(
          (candidate) => candidate.id == candidateId
              ? candidate.copyWith(
                  isShortlisted: isShortlisted,
                  shortlistedAt: shortlistedAt,
                )
              : candidate,
        )
        .toList(growable: false);

    recommendedCandidates = recommendedCandidates
        .map(
          (candidate) => candidate.id == candidateId
              ? candidate.copyWith(
                  isShortlisted: isShortlisted,
                  shortlistedAt: shortlistedAt,
                )
              : candidate,
        )
        .toList(growable: false);
  }

  Future<bool> toggleCandidateShortlist({
    required int employerId,
    required int candidateId,
  }) async {
    if (_shortlistUpdatingIds.contains(candidateId)) return false;

    _shortlistUpdatingIds.add(candidateId);
    lastError = null;
    _notifySafely();

    final result = await _service.toggleEmployerCandidateShortlist(
      employerId: employerId,
      candidateId: candidateId,
    );

    var ok = false;
    switch (result) {
      case Success(value: final value):
        final data = (value['data'] is Map<String, dynamic>)
            ? value['data'] as Map<String, dynamic>
            : (value['data'] is Map)
            ? (value['data'] as Map).map((k, v) => MapEntry(k.toString(), v))
            : value;
        _updateShortlistState(
          candidateId: candidateId,
          isShortlisted: _readShortlisted(data),
          shortlistedAt: _readShortlistedAt(data),
        );
        ok = true;
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    _shortlistUpdatingIds.remove(candidateId);
    _notifySafely();
    return ok;
  }

  Future<void> fetchAllCandidates({
    int? employerId,
    String? search,
    List<int>? jobProfileIds,
    List<int>? preferredStateIds,
    List<int>? preferredCityIds,
    List<int>? qualificationIds,
    List<int>? shiftIds,
    List<int>? skillIds,
    List<int>? salaryRangeIds,
    String? verificationStatus,
    List<Map<String, num?>>? experienceRanges,
    List<Map<String, num?>>? distanceRanges,
    String? gender,
    String? expectedSalaryFrequency,
    double? lat,
    double? lng,
    int page = 1,
    int limit = 50,
  }) async {
    isLoadingAll = true;
    lastError = null;
    _notifySafely();

    final result = await _service.getAllCandidates(
      employerId: employerId,
      search: search,
      jobProfileIds: jobProfileIds,
      preferredStateIds: preferredStateIds,
      preferredCityIds: preferredCityIds,
      qualificationIds: qualificationIds,
      shiftIds: shiftIds,
      skillIds: skillIds,
      salaryRangeIds: salaryRangeIds,
      verificationStatus: verificationStatus,
      experienceRanges: experienceRanges,
      distanceRanges: distanceRanges,
      gender: gender,
      expectedSalaryFrequency: expectedSalaryFrequency,
      lat: lat,
      lng: lng,
      page: page,
      limit: limit,
    );

    switch (result) {
      case Success(value: final resp):
        allCandidates = resp.candidates;
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isLoadingAll = false;
    _notifySafely();
  }

  Future<void> fetchRecommendedCandidates({
    required int employerId,
    String? search,
    List<int>? jobProfileIds,
    List<int>? preferredStateIds,
    List<int>? preferredCityIds,
    List<int>? qualificationIds,
    List<int>? shiftIds,
    List<int>? skillIds,
    List<int>? salaryRangeIds,
    String? verificationStatus,
    List<Map<String, num?>>? experienceRanges,
    List<Map<String, num?>>? distanceRanges,
    String? gender,
    String? expectedSalaryFrequency,
    double? lat,
    double? lng,
    int page = 1,
    int limit = 50,
  }) async {
    isLoadingRecommended = true;
    lastError = null;
    _notifySafely();

    final result = await _service.getRecommendedCandidates(
      employerId: employerId,
      search: search,
      jobProfileIds: jobProfileIds,
      preferredStateIds: preferredStateIds,
      preferredCityIds: preferredCityIds,
      qualificationIds: qualificationIds,
      shiftIds: shiftIds,
      skillIds: skillIds,
      salaryRangeIds: salaryRangeIds,
      verificationStatus: verificationStatus,
      experienceRanges: experienceRanges,
      distanceRanges: distanceRanges,
      gender: gender,
      expectedSalaryFrequency: expectedSalaryFrequency,
      lat: lat,
      lng: lng,
      page: page,
      limit: limit,
    );

    switch (result) {
      case Success(value: final resp):
        recommendedCandidates = resp.candidates;
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isLoadingRecommended = false;
    _notifySafely();
  }

  void reset() {
    isLoadingAll = false;
    isLoadingRecommended = false;
    lastError = null;
    allCandidates = const [];
    recommendedCandidates = const [];
    _notifySafely();
  }
}
