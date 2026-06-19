import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../utils/custom_exception.dart';
import '../../utils/result.dart';
import '../models/wishlist_response.dart';
import '../services/wishlist_service.dart';

class WishlistProvider extends ChangeNotifier {
  final WishlistService _service;

  bool isLoading = false;
  CustomException? lastError;
  WishlistResponse? wishlist;

  WishlistProvider({WishlistService? service})
      : _service = service ?? WishlistService();

  void _notifySafely() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (hasListeners == false) return;
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

  Future<void> fetchWishlist({
    required int employeeId,
    int page = 1,
    int limit = 50,
  }) async {
    isLoading = true;
    lastError = null;
    _notifySafely();

    final result = await _service.getEmployeeWishlist(
      employeeId,
      page: page,
      limit: limit,
    );

    switch (result) {
      case Success(value: final resp):
        wishlist = resp;
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isLoading = false;
    _notifySafely();
  }
}
