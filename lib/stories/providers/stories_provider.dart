import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../utils/custom_exception.dart';
import '../../utils/result.dart';
import '../models/employee_story_dto.dart';
import '../services/stories_service.dart';

class StoriesProvider extends ChangeNotifier {
  final StoriesService _service;

  bool isLoadingEmployee = false;
  bool isLoadingEmployer = false;
  CustomException? lastError;

  List<EmployeeStoryDto> employeeStories = const [];
  List<EmployeeStoryDto> employerStories = const [];

  StoriesProvider({StoriesService? service})
    : _service = service ?? StoriesService();

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

  List<EmployeeStoryDto> _filterAndSort(List<EmployeeStoryDto> input) {
    final now = DateTime.now();
    final filtered =
        input
            .where((s) => s.isActive)
            .where((s) => s.expiryAt == null || s.expiryAt!.isAfter(now))
            .toList()
          ..sort((a, b) => a.sequence.compareTo(b.sequence));
    return filtered;
  }

  Future<void> fetchEmployeeStories(int employeeId) async {
    isLoadingEmployee = true;
    lastError = null;
    _notifySafely();

    final result = await _service.getEmployeeStories(employeeId);

    switch (result) {
      case Success(value: final resp):
        employeeStories = _filterAndSort(resp.stories);
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isLoadingEmployee = false;
    _notifySafely();
  }

  Future<void> fetchEmployerStories(int employerId) async {
    isLoadingEmployer = true;
    lastError = null;
    _notifySafely();

    final result = await _service.getEmployerStories(employerId);

    switch (result) {
      case Success(value: final resp):
        employerStories = _filterAndSort(resp.stories);
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isLoadingEmployer = false;
    _notifySafely();
  }

  Future<bool> markRead({required int employeeId, required int storyId}) async {
    final idx = employeeStories.indexWhere((s) => s.id == storyId);
    if (idx < 0) return false;
    if (employeeStories[idx].isRead) return true;

    final result = await _service.markEmployeeStoryRead(
      employeeId: employeeId,
      storyId: storyId,
    );

    switch (result) {
      case Success(value: final resp):
        employeeStories = List<EmployeeStoryDto>.from(employeeStories);
        employeeStories[idx] = employeeStories[idx].copyWith(
          isRead: true,
          readAt: resp.readAt,
        );
        _notifySafely();
        return true;
      case Failure(exception: final e):
        lastError = e;
        _notifySafely();
        return false;
    }
  }

  Future<bool> markEmployerRead({
    required int employerId,
    required int storyId,
  }) async {
    final idx = employerStories.indexWhere((s) => s.id == storyId);
    if (idx < 0) return false;
    if (employerStories[idx].isRead) return true;

    final result = await _service.markEmployerStoryRead(
      employerId: employerId,
      storyId: storyId,
    );

    switch (result) {
      case Success(value: final resp):
        employerStories = List<EmployeeStoryDto>.from(employerStories);
        employerStories[idx] = employerStories[idx].copyWith(
          isRead: true,
          readAt: resp.readAt,
        );
        _notifySafely();
        return true;
      case Failure(exception: final e):
        lastError = e;
        _notifySafely();
        return false;
    }
  }

  void reset() {
    isLoadingEmployee = false;
    isLoadingEmployer = false;
    lastError = null;
    employeeStories = const [];
    employerStories = const [];
    _notifySafely();
  }
}
