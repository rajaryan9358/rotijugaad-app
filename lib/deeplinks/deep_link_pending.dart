import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/providers/auth_provider.dart';
import '../auth/screens/auth_screen.dart';
import '../auth/screens/user_type_screen.dart';
import '../candidatedetail/screens/candidate_detail_screen.dart';
import '../jobdetails/screens/job_details_screen.dart';
import '../navigation/app_page_route.dart';
import '../network/api_client.dart';
import '../network/api_service.dart';
import '../utils/result.dart';
import '../utils/shared_pref.dart';

class DeepLinkPending {
  static const String _typeJob = 'job';
  static const String _typeCandidate = 'candidate';
  static const String _typeReferral = 'referral';

  static Map<String, dynamic>? read() {
    return SharedPrefUtils.readJson(SharedPrefUtils.PENDING_DEEPLINK_JSON);
  }

  static Future<void> clear() async {
    await SharedPrefUtils.saveStr(SharedPrefUtils.PENDING_DEEPLINK_JSON, '');
  }

  static Future<void> _afterFrame() async {
    try {
      await WidgetsBinding.instance.endOfFrame;
    } catch (_) {
      // Best-effort; navigation can still proceed.
    }
  }

  static void _log(String message) {
    if (!kDebugMode) return;
    debugPrint('[DEEPLINK] $message');
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static List<String> _normalizedSegments(Uri uri) {
    final segments = uri.pathSegments
        .where((s) => s.trim().isNotEmpty)
        .toList();
    if (segments.isNotEmpty && segments.first.toLowerCase() == 'app') {
      return segments.sublist(1);
    }
    return segments;
  }

  static Future<void> storeFromUri(Uri uri) async {
    final segments = _normalizedSegments(uri);
    if (segments.isEmpty) return;

    final head = segments[0].toLowerCase();
    if (head == 'jobs' && segments.length >= 2) {
      await SharedPrefUtils.saveJson(SharedPrefUtils.PENDING_DEEPLINK_JSON, {
        'type': _typeJob,
        'slug': segments[1],
      });
      return;
    }

    if (head == 'candidates' && segments.length >= 2) {
      await SharedPrefUtils.saveJson(SharedPrefUtils.PENDING_DEEPLINK_JSON, {
        'type': _typeCandidate,
        'slug': segments[1],
      });
      return;
    }

    if (head == 'referral' && segments.length >= 2) {
      await SharedPrefUtils.saveJson(SharedPrefUtils.PENDING_DEEPLINK_JSON, {
        'type': _typeReferral,
        'code': segments[1],
      });
      return;
    }
  }

  static Future<int?> _resolveId({required String endpoint}) async {
    final api = ApiService();
    final result = await api.getJson<Map<String, dynamic>>(
      endpoint: endpoint,
      fromJson: (json) => json ?? <String, dynamic>{},
    );

    switch (result) {
      case Success(value: final payload):
        // ApiService.getJson already validates `status == success` and returns
        // the unwrapped `data` object.
        final direct = _asInt(payload['id']);
        if (direct != null && direct > 0) return direct;

        // Backward/alternate shape support: { data: { id: ... } }
        final data = payload['data'];
        if (data is Map) {
          final nested = _asInt(data['id']);
          if (nested != null && nested > 0) return nested;
        }

        return null;
      case Failure():
        return null;
    }
  }

  static Future<bool> consumeAndNavigate(
    BuildContext context, {
    NavigatorState? navigator,
  }) async {
    final pending = read();
    if (pending == null || pending.isEmpty) return false;

    final nav = navigator ?? Navigator.maybeOf(context);
    if (nav == null) return false;

    _log('pending=$pending');

    final type = (pending['type'] ?? '').toString().toLowerCase();
    final loggedIn = SharedPrefUtils.readBool(SharedPrefUtils.AUTH_LOGGED_IN);
    final userType = SharedPrefUtils.readStr(
      SharedPrefUtils.USER_TYPE,
    ).trim().toLowerCase();
    final profileJson = SharedPrefUtils.readJson(
      SharedPrefUtils.AUTH_PROFILE_JSON,
    );
    final profileId = _asInt(
      profileJson?['id'] ??
          profileJson?['employeeId'] ??
          profileJson?['employerId'],
    );

    if (type == _typeReferral) {
      final code = (pending['code'] ?? '').toString().trim();
      if (code.isNotEmpty && !loggedIn) {
        context.read<AuthProvider>().referredBy = code;
        if (!context.mounted) return false;
        try {
          await _afterFrame();
          nav.pushAndRemoveUntil(
            AppPageRoute.slideFade(page: UserTypeScreen()),
            (route) => false,
          );
          await clear();
        } catch (e, st) {
          // Keep pending so it can be retried.
          _log('referral navigation failed: $e\n$st');
          return false;
        }
        return true;
      }
      await clear();
      return true;
    }

    if (!loggedIn) {
      // Keep pending, but route user to auth so they can login/signup.
      try {
        await _afterFrame();
        nav.pushAndRemoveUntil(
          AppPageRoute.slideFade(page: AuthScreen()),
          (route) => false,
        );
      } catch (e, st) {
        _log('auth navigation failed: $e\n$st');
        return false;
      }
      return true;
    }

    if (type == _typeJob) {
      if (userType != 'employee' || profileId == null || profileId <= 0)
        return false;
      final slug = (pending['slug'] ?? '').toString().trim();
      if (slug.isEmpty) return false;

      _log('resolving job slug=$slug');
      final jobId = await _resolveId(endpoint: ApiClient.jobIdBySlug(slug));
      if (jobId == null || jobId <= 0) return false;

      if (!context.mounted) return false;
      try {
        _log('navigating jobId=$jobId employeeId=$profileId');
        await _afterFrame();
        final before = nav.canPop();
        nav.push(
          MaterialPageRoute(
            builder: (_) =>
                JobDetailsScreen(jobId: jobId, employeeId: profileId),
          ),
        );
        await _afterFrame();
        final after = nav.canPop();
        if (!before && !after) {
          _log('job push did not change stack; keeping pending');
          return false;
        }
        await clear();
      } catch (e, st) {
        // Keep pending so it can be retried.
        _log('job navigation failed: $e\n$st');
        return false;
      }
      return true;
    }

    if (type == _typeCandidate) {
      if (userType != 'employer') return false;
      final slug = (pending['slug'] ?? '').toString().trim();
      if (slug.isEmpty) return false;

      _log('resolving candidate slug=$slug');
      final candidateId = await _resolveId(
        endpoint: ApiClient.candidateIdBySlug(slug),
      );
      if (candidateId == null || candidateId <= 0) return false;

      if (!context.mounted) return false;
      try {
        _log('navigating candidateId=$candidateId');
        await _afterFrame();
        final before = nav.canPop();
        nav.push(
          MaterialPageRoute(
            builder: (_) => CandidateDetailScreen(candidateId: candidateId),
          ),
        );
        await _afterFrame();
        final after = nav.canPop();
        if (!before && !after) {
          _log('candidate push did not change stack; keeping pending');
          return false;
        }
        await clear();
      } catch (e, st) {
        // Keep pending so it can be retried.
        _log('candidate navigation failed: $e\n$st');
        return false;
      }
      return true;
    }

    return false;
  }
}
