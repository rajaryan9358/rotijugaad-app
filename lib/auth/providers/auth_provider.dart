import 'package:flutter/foundation.dart';

import '../../utils/custom_exception.dart';
import '../../utils/result.dart';
import '../models/auth_send_otp_response.dart';
import '../models/auth_verify_otp_response.dart';
import '../services/auth_service.dart';
import '../../utils/shared_pref.dart';
import '../../notifications/notification_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider({AuthService? authService})
    : _authService = authService ?? AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  CustomException? _lastError;
  CustomException? get lastError => _lastError;

  String _mobile = '';
  String get mobile => _mobile;
  set mobile(String value) {
    _mobile = value;
    notifyListeners();
  }

  String _otp = '';
  String get otp => _otp;
  set otp(String value) {
    _otp = value;
    notifyListeners();
  }

  String _name = '';
  String get name => _name;
  set name(String value) {
    _name = value;
    notifyListeners();
  }

  String _userType = 'employee';
  String get userType => _userType;
  set userType(String value) {
    _userType = value;
    notifyListeners();
  }

  String _referredBy = '';
  String get referredBy => _referredBy;
  set referredBy(String value) {
    _referredBy = value;
    notifyListeners();
  }

  AuthSendOtpResponse? _lastSendOtp;
  AuthSendOtpResponse? get lastSendOtp => _lastSendOtp;

  AuthVerifyOtpResponse? _lastVerifyOtp;
  AuthVerifyOtpResponse? get lastVerifyOtp => _lastVerifyOtp;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _persistVerifiedUser(AuthVerifyOtpResponse response) async {
    await SharedPrefUtils.saveBool(SharedPrefUtils.AUTH_LOGGED_IN, true);
    await SharedPrefUtils.saveJson(
      SharedPrefUtils.AUTH_USER_JSON,
      response.user.toJson(),
    );
    await SharedPrefUtils.saveStr(
      SharedPrefUtils.AUTH_PROFILE_TYPE,
      response.profileType ?? '',
    );
    await SharedPrefUtils.saveBool(
      SharedPrefUtils.AUTH_PROFILE_COMPLETED,
      response.profileCompleted,
    );
    if (response.profile != null) {
      await SharedPrefUtils.saveJson(
        SharedPrefUtils.AUTH_PROFILE_JSON,
        response.profile!,
      );
    } else {
      await SharedPrefUtils.saveStr(SharedPrefUtils.AUTH_PROFILE_JSON, '');
    }

    final resolvedType = response.user.userType;
    if (resolvedType != null && resolvedType.trim().isNotEmpty) {
      await SharedPrefUtils.saveStr(
        SharedPrefUtils.USER_TYPE,
        resolvedType.trim(),
      );
      userType = resolvedType.trim();
    }
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  void clearAuthDraft({bool keepUserType = true}) {
    _isLoading = false;
    _lastError = null;
    _mobile = '';
    _otp = '';
    _name = '';
    _referredBy = '';
    if (!keepUserType) {
      _userType = 'employee';
    }
    _lastSendOtp = null;
    _lastVerifyOtp = null;
    notifyListeners();
  }

  Future<AuthSendOtpResponse> sendLoginOtp() async {
    _setLoading(true);
    clearError();

    final response = await _authService.sendLoginOtp(mobile: mobile);
    switch (response) {
      case Success<AuthSendOtpResponse, CustomException>():
        _lastSendOtp = response.value;
        _setLoading(false);
        return response.value;
      case Failure<AuthSendOtpResponse, CustomException>():
        _lastError = response.exception;
        _setLoading(false);
        throw response.exception;
    }
  }

  Future<AuthVerifyOtpResponse> verifyLoginOtp() async {
    _setLoading(true);
    clearError();

    final response = await _authService.verifyLoginOtp(
      mobile: mobile,
      otp: otp,
    );
    switch (response) {
      case Success<AuthVerifyOtpResponse, CustomException>():
        _lastVerifyOtp = response.value;
        await _persistVerifiedUser(response.value);
        await NotificationService.instance.syncTokenIfLoggedIn();
        _setLoading(false);
        return response.value;
      case Failure<AuthVerifyOtpResponse, CustomException>():
        _lastError = response.exception;
        _setLoading(false);
        throw response.exception;
    }
  }

  Future<AuthSendOtpResponse> sendSignupOtp() async {
    _setLoading(true);
    clearError();

    final response = await _authService.sendSignupOtp(
      name: name,
      mobile: mobile,
      userType: userType,
      referredBy: referredBy,
    );

    switch (response) {
      case Success<AuthSendOtpResponse, CustomException>():
        _lastSendOtp = response.value;
        _setLoading(false);
        return response.value;
      case Failure<AuthSendOtpResponse, CustomException>():
        _lastError = response.exception;
        _setLoading(false);
        throw response.exception;
    }
  }

  Future<AuthVerifyOtpResponse> verifySignupOtp() async {
    _setLoading(true);
    clearError();

    final response = await _authService.verifySignupOtp(
      mobile: mobile,
      otp: otp,
    );
    switch (response) {
      case Success<AuthVerifyOtpResponse, CustomException>():
        _lastVerifyOtp = response.value;
        await _persistVerifiedUser(response.value);
        await NotificationService.instance.syncTokenIfLoggedIn();
        _setLoading(false);
        return response.value;
      case Failure<AuthVerifyOtpResponse, CustomException>():
        _lastError = response.exception;
        _setLoading(false);
        throw response.exception;
    }
  }

  void reset() {
    clearAuthDraft(keepUserType: false);
  }
}
