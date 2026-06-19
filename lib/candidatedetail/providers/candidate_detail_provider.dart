import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../candidates/services/candidates_service.dart';
import '../../utils/custom_exception.dart';
import '../../utils/result.dart';
import '../../utils/shared_pref.dart';
import '../models/candidate_detail_models.dart';

class CandidateDetailProvider extends ChangeNotifier {
  final CandidatesService _service;
  final int candidateId;

  CandidateDetailProvider({
    required this.candidateId,
    CandidatesService? service,
  }) : _service = service ?? CandidatesService();

  CandidateDetailDto? detail;

  bool isLoading = false;
  CustomException? error;

  bool isUnlockingContact = false;
  CustomException? unlockError;

  bool isActionLoading = false;
  CustomException? lastError;
  bool isShortlistLoading = false;
  CustomException? shortlistError;

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

  bool get isContactUnlocked => detail?.contact.isUnlocked ?? false;
  bool get isShortlisted => detail?.shortlist.isShortlisted ?? false;

  void ensureLoaded() {
    if (detail == null && !isLoading) {
      load();
    }
  }

  Future<void> load() async {
    if (isLoading) return;

    final employerId = SharedPrefUtils.readInt('auth_employer_id');
    if (employerId <= 0) {
      error = CustomException(
        code: 'NO_EMPLOYER',
        message: 'Employer ID not found. Please sign in again.',
      );
      _notifySafely();
      return;
    }

    isLoading = true;
    error = null;
    _notifySafely();

    final result = await _service.getCandidateDetail(
      candidateId: candidateId,
      employerId: employerId,
    );

    switch (result) {
      case Success(value: final value):
        detail = value;
        break;
      case Failure(exception: final e):
        error = e;
        break;
    }

    isLoading = false;
    _notifySafely();
  }

  Future<bool> unlockContact() async {
    if (isUnlockingContact) return false;

    final employerId = SharedPrefUtils.readInt('auth_employer_id');
    if (employerId <= 0) {
      unlockError = CustomException(
        code: 'NO_EMPLOYER',
        message: 'Employer ID not found. Please sign in again.',
      );
      _notifySafely();
      return false;
    }

    isUnlockingContact = true;
    unlockError = null;
    _notifySafely();

    final result = await _service.unlockCandidateContact(
      candidateId: candidateId,
      employerId: employerId,
    );

    var ok = false;

    switch (result) {
      case Success(value: final contact):
        ok = contact.isUnlocked;
        if (detail != null) {
          detail = detail!.copyWith(contact: contact);
        }
        break;
      case Failure(exception: final e):
        unlockError = e;
        break;
    }

    isUnlockingContact = false;
    _notifySafely();
    return ok;
  }

  Future<bool> reportCandidate({
    required int reasonId,
    String? description,
  }) async {
    if (isActionLoading) return false;

    final employerId = SharedPrefUtils.readInt('auth_employer_id');
    if (employerId <= 0) {
      lastError = CustomException(
        code: 'NO_EMPLOYER',
        message: 'Employer ID not found. Please sign in again.',
      );
      _notifySafely();
      return false;
    }

    isActionLoading = true;
    lastError = null;
    _notifySafely();

    final result = await _service.reportCandidate(
      candidateId: candidateId,
      employerId: employerId,
      reasonId: reasonId,
      description: description,
    );

    var ok = false;
    switch (result) {
      case Success():
        ok = true;
        if (detail != null) {
          detail = detail!.copyWith(
            report: detail!.report.copyWith(
              isReported: true,
              reportedAt: DateTime.now().toIso8601String(),
            ),
          );
        }
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isActionLoading = false;
    _notifySafely();
    return ok;
  }

  Future<bool> toggleShortlist() async {
    if (isShortlistLoading) return false;

    final employerId = SharedPrefUtils.readInt('auth_employer_id');
    if (employerId <= 0) {
      shortlistError = CustomException(
        code: 'NO_EMPLOYER',
        message: 'Employer ID not found. Please sign in again.',
      );
      _notifySafely();
      return false;
    }

    isShortlistLoading = true;
    shortlistError = null;
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
        final shortlist = CandidateShortlistDto.fromJson(data);
        if (detail != null) {
          detail = detail!.copyWith(shortlist: shortlist);
        }
        ok = true;
        break;
      case Failure(exception: final e):
        shortlistError = e;
        break;
    }

    isShortlistLoading = false;
    _notifySafely();
    return ok;
  }
}
