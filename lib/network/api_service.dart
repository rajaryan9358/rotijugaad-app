import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/custom_exception.dart';
import '../utils/result.dart';
import '../utils/shared_pref.dart';
import 'api_client.dart';
import 'network_status_provider.dart';

class ApiService {
  static bool enableLogging = true;

  static Future<void> Function({required String code, String? message})?
  onForcedLogout;

  static bool _forcingLogout = false;

  ApiService();

  String _currentLang() {
    final stored = SharedPrefUtils.readStr(SharedPrefUtils.APP_LANGUAGE);
    final code = stored.trim().toLowerCase();
    if (code == 'hi' || code == 'en') return code;
    if (code == 'hindi') return 'hi';
    if (code == 'english') return 'en';
    return 'en';
  }

  String _truncate(String value, {int max = 2000}) {
    if (value.length <= max) return value;
    return '${value.substring(0, max)}…(truncated)';
  }

  static const Set<String> _bilingualBaseKeys = {
    'name',
    'about_user',
    'organization_name',
    'address',
    'title',
    'body',
    'target',
    'description',
    'review',
  };

  bool _hasText(dynamic value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    return true;
  }

  dynamic _preferHindiFields(dynamic value) {
    if (value is List) {
      return value.map(_preferHindiFields).toList();
    }
    if (value is Map) {
      final out = <String, dynamic>{};
      value.forEach((k, v) {
        out[k.toString()] = _preferHindiFields(v);
      });

      final keys = out.keys.toList(growable: false);
      for (final key in keys) {
        if (key.endsWith('_hindi') || key.endsWith('_english')) continue;
        final hindiKey = '${key}_hindi';
        if (out.containsKey(hindiKey) && _hasText(out[hindiKey])) {
          out[key] = out[hindiKey];
        }
      }
      return out;
    }
    return value;
  }

  Map<String, dynamic> _mapHindiInput(Map<String, dynamic> body) {
    if (_currentLang() != 'hi') return body;

    final out = Map<String, dynamic>.from(body);
    for (final key in _bilingualBaseKeys) {
      final hindiKey = '${key}_hindi';
      if (out.containsKey(key) && !out.containsKey(hindiKey)) {
        out[hindiKey] = out[key];
        out.remove(key);
      }
    }
    return out;
  }

  Map<String, String> _redactHeaders(Map<String, String> headers) {
    final out = <String, String>{};
    headers.forEach((k, v) {
      final key = k.toLowerCase();
      if (key == 'authorization' || key == 'cookie' || key == 'set-cookie') {
        out[k] = '<redacted>';
      } else {
        out[k] = v;
      }
    });
    return out;
  }

  dynamic _redactJson(dynamic value) {
    const sensitive = {
      'token',
      'access_token',
      'refresh_token',
      'otp',
      'password',
      'authorization',
    };
    if (value is Map) {
      final out = <String, dynamic>{};
      value.forEach((k, v) {
        final key = k.toString().toLowerCase();
        if (sensitive.contains(key) ||
            key.contains('token') ||
            key.contains('otp') ||
            key.contains('password')) {
          out[k.toString()] = '<redacted>';
        } else {
          out[k.toString()] = _redactJson(v);
        }
      });
      return out;
    }
    if (value is List) return value.map(_redactJson).toList();
    return value;
  }

  String _safeBodyForLog(String? body) {
    final raw = (body ?? '').trim();
    if (raw.isEmpty) return '';
    try {
      final decoded = jsonDecode(raw);
      final redacted = _redactJson(decoded);
      return _truncate(const JsonEncoder.withIndent('  ').convert(redacted));
    } catch (_) {
      return _truncate(raw);
    }
  }

  void _logRequest({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    String? body,
  }) {
    if (!enableLogging) return;
    debugPrint('[API] → $method $uri');
    debugPrint('[API]   headers: ${_redactHeaders(headers)}');
    final safeBody = _safeBodyForLog(body);
    if (safeBody.trim().isNotEmpty) {
      debugPrint('[API]   body: $safeBody');
    }
  }

  void _logResponse({
    required String method,
    required Uri uri,
    required int statusCode,
    required Map<String, String> headers,
    required String body,
    required int elapsedMs,
  }) {
    if (!enableLogging) return;
    debugPrint('[API] ← $method $uri ($statusCode) ${elapsedMs}ms');
    debugPrint('[API]   headers: ${_redactHeaders(headers)}');
    final safeBody = _safeBodyForLog(body);
    if (safeBody.trim().isNotEmpty) {
      debugPrint('[API]   body: $safeBody');
    }
  }

  Uri _buildUri(String endpoint, {Map<String, String>? queryParameters}) {
    final normalized = endpoint.startsWith('/') ? endpoint : '/$endpoint';

    final base = Uri.parse(ApiClient.baseUrl);

    final basePath = ApiClient.basePath.endsWith('/')
        ? ApiClient.basePath.substring(0, ApiClient.basePath.length - 1)
        : ApiClient.basePath;

    final fullPath = '$basePath$normalized';

    return base.replace(path: fullPath, queryParameters: queryParameters);
  }

  Result<T, CustomException> _parseResponse<T>({
    required Uri uri,
    required http.Response response,
    required T Function(Map<String, dynamic>?) fromJson,
  }) {
    Map<String, dynamic>? json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      json = null;
    }

    _maybeForceLogout(uri: uri, json: json);

    if (response.statusCode != 200) {
      return Failure(
        CustomException(
          code: 'HTTP_${response.statusCode}',
          message: json?['message']?.toString() ?? 'Request failed',
        ),
      );
    }

    final status = json?['status'];
    final ok =
        (status is String && status.toLowerCase() == 'success') ||
        json?['success'] == true;

    if (!ok) {
      return Failure(
        CustomException(
          code: json?['code']?.toString(),
          message: json?['message']?.toString() ?? 'Something went wrong',
        ),
      );
    }

    dynamic data = json?['data'];
    if (_currentLang() == 'hi') {
      data = _preferHindiFields(data);
    }
    if (data is List) {
      return Success(fromJson({'data': data}));
    }

    return Success(fromJson(data is Map<String, dynamic> ? data : null));
  }

  bool _isUserDetailUri(Uri uri) {
    // Only apply forced logout for: GET /api/app/users/:id
    // (Not for /users/:id/preferred-language, /employees/*, /employers/*, etc.)
    return RegExp(r'^/api/app/users/\d+$').hasMatch(uri.path);
  }

  void _maybeForceLogout({required Uri uri, Map<String, dynamic>? json}) {
    final code = json?['code']?.toString();
    if (code != 'FC_02') return;

    const forcedCode = 'FC_02';

    if (!_isUserDetailUri(uri)) return;

    // Only force logout for existing sessions (FC_02 is also used during login).
    final isLoggedIn = SharedPrefUtils.readBool(SharedPrefUtils.AUTH_LOGGED_IN);
    if (!isLoggedIn) return;

    if (_forcingLogout) return;
    _forcingLogout = true;

    final message = json?['message']?.toString();
    final handler = onForcedLogout;
    if (handler == null) {
      // No handler installed yet; still clear local auth to prevent loops.
      // ignore: unawaited_futures
      SharedPrefUtils.clearAuthSession();
      _forcingLogout = false;
      return;
    }

    // ignore: unawaited_futures
    () async {
      try {
        await handler(code: forcedCode, message: message);
      } finally {
        _forcingLogout = false;
      }
    }();
  }

  bool _isConnectivityError(Object error) {
    return error is SocketException ||
        error is HttpException ||
        error is HandshakeException ||
        error is http.ClientException ||
        error is TimeoutException;
  }

  Failure<T, CustomException> _networkFailure<T>(Object error) {
    if (_isConnectivityError(error)) {
      NetworkStatusProvider.instance.reportNetworkFailure();
    }
    return Failure(
      CustomException(code: 'NETWORK', message: 'Network error: $error'),
    );
  }

  Future<Result<T, CustomException>> getJson<T>({
    required String endpoint,
    Map<String, String>? queryParameters,
    required T Function(Map<String, dynamic>?) fromJson,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(endpoint, queryParameters: queryParameters);

    final requestHeaders = <String, String>{
      HttpHeaders.acceptHeader: 'application/json',
      ...?headers,
      'lang': _currentLang(),
    };

    final started = DateTime.now();
    _logRequest(method: 'GET', uri: uri, headers: requestHeaders);

    try {
      final response = await http.get(uri, headers: requestHeaders);
      NetworkStatusProvider.instance.reportSuccess();
      _logResponse(
        method: 'GET',
        uri: uri,
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
        elapsedMs: DateTime.now().difference(started).inMilliseconds,
      );
      return _parseResponse(uri: uri, response: response, fromJson: fromJson);
    } catch (e) {
      return _networkFailure(e);
    }
  }

  Future<Result<T, CustomException>> postJson<T>({
    required String endpoint,
    required Map<String, dynamic> body,
    required T Function(Map<String, dynamic>?) fromJson,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(endpoint);

    final requestHeaders = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
      ...?headers,
      'lang': _currentLang(),
    };

    final started = DateTime.now();
    final mappedBody = _mapHindiInput(body);
    final encodedBody = jsonEncode(mappedBody);
    _logRequest(
      method: 'POST',
      uri: uri,
      headers: requestHeaders,
      body: encodedBody,
    );

    try {
      final response = await http.post(
        uri,
        headers: requestHeaders,
        body: encodedBody,
      );
      NetworkStatusProvider.instance.reportSuccess();

      _logResponse(
        method: 'POST',
        uri: uri,
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
        elapsedMs: DateTime.now().difference(started).inMilliseconds,
      );

      return _parseResponse(uri: uri, response: response, fromJson: fromJson);
    } catch (e) {
      return _networkFailure(e);
    }
  }

  Future<Result<T, CustomException>> putJson<T>({
    required String endpoint,
    required Map<String, dynamic> body,
    required T Function(Map<String, dynamic>?) fromJson,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(endpoint);

    final requestHeaders = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
      ...?headers,
      'lang': _currentLang(),
    };

    final started = DateTime.now();
    final mappedBody = _mapHindiInput(body);
    final encodedBody = jsonEncode(mappedBody);
    _logRequest(
      method: 'PUT',
      uri: uri,
      headers: requestHeaders,
      body: encodedBody,
    );

    try {
      final response = await http.put(
        uri,
        headers: requestHeaders,
        body: encodedBody,
      );
      NetworkStatusProvider.instance.reportSuccess();

      _logResponse(
        method: 'PUT',
        uri: uri,
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
        elapsedMs: DateTime.now().difference(started).inMilliseconds,
      );

      return _parseResponse(uri: uri, response: response, fromJson: fromJson);
    } catch (e) {
      return _networkFailure(e);
    }
  }

  Future<Result<T, CustomException>> deleteJson<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>?) fromJson,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(endpoint);

    final requestHeaders = <String, String>{
      HttpHeaders.acceptHeader: 'application/json',
      ...?headers,
      'lang': _currentLang(),
    };

    final started = DateTime.now();
    _logRequest(method: 'DELETE', uri: uri, headers: requestHeaders);

    try {
      final response = await http.delete(uri, headers: requestHeaders);
      NetworkStatusProvider.instance.reportSuccess();
      _logResponse(
        method: 'DELETE',
        uri: uri,
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
        elapsedMs: DateTime.now().difference(started).inMilliseconds,
      );
      return _parseResponse(uri: uri, response: response, fromJson: fromJson);
    } catch (e) {
      return _networkFailure(e);
    }
  }

  Future<Result<T, CustomException>> postMultipart<T>({
    required String endpoint,
    required Map<String, dynamic> fields,
    Map<String, File>? files,
    required T Function(Map<String, dynamic>?) fromJson,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(endpoint);

    final started = DateTime.now();
    final mappedFields = _mapHindiInput(fields);
    final filesMeta = (files == null)
        ? const <String, String>{}
        : Map<String, String>.fromEntries(
            files.entries.map(
              (e) => MapEntry(e.key, e.value.path.split('/').last),
            ),
          );
    _logRequest(
      method: 'POST',
      uri: uri,
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
        ...?headers,
        'lang': _currentLang(),
      },
      body: jsonEncode({'fields': mappedFields, 'files': filesMeta}),
    );

    try {
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        HttpHeaders.acceptHeader: 'application/json',
        ...?headers,
        'lang': _currentLang(),
      });

      mappedFields.forEach((key, value) {
        if (value == null) return;
        request.fields[key] = value.toString();
      });

      if (files != null) {
        for (final entry in files.entries) {
          request.files.add(
            await http.MultipartFile.fromPath(entry.key, entry.value.path),
          );
        }
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      NetworkStatusProvider.instance.reportSuccess();

      _logResponse(
        method: 'POST',
        uri: uri,
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
        elapsedMs: DateTime.now().difference(started).inMilliseconds,
      );

      return _parseResponse(uri: uri, response: response, fromJson: fromJson);
    } catch (e) {
      return _networkFailure(e);
    }
  }

  Future<Result<T, CustomException>> putMultipart<T>({
    required String endpoint,
    required Map<String, dynamic> fields,
    Map<String, File>? files,
    required T Function(Map<String, dynamic>?) fromJson,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(endpoint);

    final started = DateTime.now();
    final mappedFields = _mapHindiInput(fields);
    final filesMeta = (files == null)
        ? const <String, String>{}
        : Map<String, String>.fromEntries(
            files.entries.map(
              (e) => MapEntry(e.key, e.value.path.split('/').last),
            ),
          );
    _logRequest(
      method: 'PUT',
      uri: uri,
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
        ...?headers,
        'lang': _currentLang(),
      },
      body: jsonEncode({'fields': mappedFields, 'files': filesMeta}),
    );

    try {
      final request = http.MultipartRequest('PUT', uri);
      request.headers.addAll({
        HttpHeaders.acceptHeader: 'application/json',
        ...?headers,
        'lang': _currentLang(),
      });

      mappedFields.forEach((key, value) {
        if (value == null) return;
        request.fields[key] = value.toString();
      });

      if (files != null) {
        for (final entry in files.entries) {
          request.files.add(
            await http.MultipartFile.fromPath(entry.key, entry.value.path),
          );
        }
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      NetworkStatusProvider.instance.reportSuccess();

      _logResponse(
        method: 'PUT',
        uri: uri,
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
        elapsedMs: DateTime.now().difference(started).inMilliseconds,
      );

      return _parseResponse(uri: uri, response: response, fromJson: fromJson);
    } catch (e) {
      return _networkFailure(e);
    }
  }
}
