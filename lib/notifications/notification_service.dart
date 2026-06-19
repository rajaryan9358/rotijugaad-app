import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../network/api_client.dart';
import '../network/api_service.dart';
import '../utils/result.dart';
import '../utils/shared_pref.dart';

/// Background message handler.
///
/// Must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}

  if (kDebugMode) {
    debugPrint(
      '[FCM] background message: ${message.messageId} data=${message.data}',
    );
  }
}

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  FirebaseMessaging? _messaging;
  final ApiService _api = ApiService();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _localInitialized = false;
  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'rotijugaad_default',
        'Rotijugaad Notifications',
        description: 'Default notification channel',
        importance: Importance.high,
      );

  StreamSubscription<String>? _tokenSub;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedSub;

  String? _cachedToken;
  bool _initialized = false;
  int _serverUnreadCount = 0;

  final ValueNotifier<List<Map<String, dynamic>>> inbox = ValueNotifier(
    <Map<String, dynamic>>[],
  );
  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  String? get cachedToken => _cachedToken;

  static Future<void> init() => instance._init();

  Future<void> _init() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] Firebase.initializeApp failed: $e');
      return;
    }

    _messaging = FirebaseMessaging.instance;
    _initialized = true;

    _loadInboxFromPrefs();
    _loadUnreadCountFromPrefs();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // iOS permission request (safe to call on Android too).
    try {
      await _messaging?.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (_) {}

    // iOS: allow notifications while app is foreground.
    try {
      await _messaging?.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (_) {}

    await _initLocalNotifications();

    // Get current token and sync on startup.
    try {
      _cachedToken = await _messaging?.getToken();
      await syncTokenIfLoggedIn();
    } catch (_) {}

    // Foreground messages.
    _onMessageSub?.cancel();
    _onMessageSub = FirebaseMessaging.onMessage.listen((message) {
      _handleIncoming(message, source: 'foreground');
      _showForegroundLocalNotification(message);
      if (kDebugMode) {
        debugPrint(
          '[FCM] foreground message: ${message.messageId} data=${message.data}',
        );
      }
    });

    // When user taps a notification and app opens/resumes.
    _onMessageOpenedSub?.cancel();
    _onMessageOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen((
      message,
    ) {
      _handleIncoming(message, source: 'opened');
      if (kDebugMode) {
        debugPrint(
          '[FCM] opened message: ${message.messageId} data=${message.data}',
        );
      }
    });

    // Terminated -> opened from notification.
    try {
      final initial = await _messaging?.getInitialMessage();
      if (initial != null) {
        _handleIncoming(initial, source: 'initial');
        if (kDebugMode) {
          debugPrint(
            '[FCM] initial message: ${initial.messageId} data=${initial.data}',
          );
        }
      }
    } catch (_) {}

    // Token refresh.
    _tokenSub?.cancel();
    _tokenSub = _messaging?.onTokenRefresh.listen((token) async {
      _cachedToken = token;
      await syncTokenIfLoggedIn();
    });
  }

  Future<void> _initLocalNotifications() async {
    if (_localInitialized) return;

    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      await _localNotifications.initialize(initSettings);

      final androidImpl = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImpl != null) {
        await androidImpl.createNotificationChannel(_androidChannel);
        // Android 13+ runtime permission
        await androidImpl.requestNotificationsPermission();
      }

      _localInitialized = true;
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] local notification init failed: $e');
    }
  }

  Future<void> _showForegroundLocalNotification(RemoteMessage message) async {
    try {
      if (!_localInitialized) {
        await _initLocalNotifications();
      }

      final data = message.data;
      final titleEn = (data['title_en'] ?? message.notification?.title ?? '')
          .toString();
      final bodyEn = (data['body_en'] ?? message.notification?.body ?? '')
          .toString();
      final titleHi = (data['title_hi'] ?? data['title_hindi'] ?? '')
          .toString();
      final bodyHi = (data['body_hi'] ?? data['body_hindi'] ?? '').toString();

      final title = _pickLocalized(en: titleEn, hi: titleHi).trim();
      final body = _pickLocalized(en: bodyEn, hi: bodyHi).trim();

      if (title.isEmpty && body.isEmpty) return;

      final id = DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _localNotifications.show(id, title, body, details);
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] local notification show failed: $e');
    }
  }

  Future<String?> getToken() async {
    if (_cachedToken != null && _cachedToken!.trim().isNotEmpty)
      return _cachedToken;

    if (!_initialized) {
      try {
        await _init();
      } catch (_) {}
    }

    try {
      _cachedToken = await _messaging?.getToken();
      return _cachedToken;
    } catch (_) {
      return null;
    }
  }

  int? _readLoggedInUserId() {
    final loggedIn = SharedPrefUtils.readBool(SharedPrefUtils.AUTH_LOGGED_IN);
    if (!loggedIn) return null;

    final user = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_USER_JSON);
    final idRaw = user?['id'] ?? user?['user_id'] ?? user?['userId'];
    if (idRaw == null) return null;

    final id = int.tryParse(idRaw.toString());
    if (id == null || id <= 0) return null;
    return id;
  }

  Future<void> syncTokenIfLoggedIn() async {
    final userId = _readLoggedInUserId();
    if (userId == null) return;

    final token = await getToken();
    if (token == null || token.trim().isEmpty) return;

    try {
      await _api.putJson<Map<String, dynamic>>(
        endpoint: ApiClient.userUpdateFcmToken(userId),
        body: {'fcm_token': token.trim()},
        fromJson: (json) => json ?? <String, dynamic>{},
      );
    } catch (_) {}
  }

  void _loadInboxFromPrefs() {
    try {
      inbox.value = SharedPrefUtils.readJsonList(
        SharedPrefUtils.INBOX_NOTIFICATIONS_JSON,
      );
    } catch (_) {
      inbox.value = <Map<String, dynamic>>[];
    }
    _recomputeUnreadCount();
  }

  void _loadUnreadCountFromPrefs() {
    try {
      _serverUnreadCount = SharedPrefUtils.readInt(
        SharedPrefUtils.SERVER_NOTIFICATIONS_UNREAD_COUNT,
      );
    } catch (_) {
      _serverUnreadCount = 0;
    }
    _recomputeUnreadCount();
  }

  bool _isHindiSelected() {
    final l = SharedPrefUtils.readStr(SharedPrefUtils.APP_LANGUAGE).trim();
    return l.toLowerCase() == 'hi';
  }

  String _pickLocalized({required String en, required String hi}) {
    if (_isHindiSelected()) return hi.trim().isNotEmpty ? hi : en;
    return en.trim().isNotEmpty ? en : hi;
  }

  bool _isMarkedRead(dynamic value) {
    if (value is bool) return value;
    final text = value?.toString().trim().toLowerCase() ?? '';
    return text == 'true' || text == '1';
  }

  int _localUnreadCount() {
    return inbox.value.where((item) => !_isMarkedRead(item['is_read'])).length;
  }

  void _recomputeUnreadCount() {
    unreadCount.value = _serverUnreadCount + _localUnreadCount();
  }

  Future<void> _persistInbox() async {
    await SharedPrefUtils.saveJsonList(
      SharedPrefUtils.INBOX_NOTIFICATIONS_JSON,
      inbox.value,
    );
    _recomputeUnreadCount();
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  Future<void> setServerUnreadCount(int count) async {
    _serverUnreadCount = count < 0 ? 0 : count;
    await SharedPrefUtils.saveInt(
      SharedPrefUtils.SERVER_NOTIFICATIONS_UNREAD_COUNT,
      _serverUnreadCount,
    );
    _recomputeUnreadCount();
  }

  Future<void> refreshUnreadCount() async {
    final userId = _readLoggedInUserId();
    if (userId == null) {
      await setServerUnreadCount(0);
      return;
    }

    try {
      final result = await _api.getJson<Map<String, dynamic>>(
        endpoint: ApiClient.userNotifications(userId),
        queryParameters: const {'limit': '1'},
        fromJson: (json) => json ?? <String, dynamic>{},
      );

      if (result case Success<Map<String, dynamic>, dynamic>(
        value: final data,
      )) {
        await setServerUnreadCount(_asInt(data['unread_count']) ?? 0);
      }
    } catch (_) {}
  }

  Map<String, dynamic>? _decodeInboxData(Map<String, dynamic> item) {
    final raw = (item['data'] ?? '').toString().trim();
    if (!raw.startsWith('{')) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
    return null;
  }

  bool isActionableNotification(Map<String, dynamic> item) {
    final data = _decodeInboxData(item);
    final referenceType =
        (item['reference_type'] ??
                data?['reference_type'] ??
                data?['entity'] ??
                '')
            .toString()
            .trim()
            .toLowerCase();

    if (referenceType == 'employer_credit' || referenceType == 'employee_credit') return true;

    final referenceId = _asInt(
      item['reference_id'] ?? data?['reference_id'] ?? data?['entity_id'],
    );

    if (referenceId == null || referenceId <= 0) return false;
    return referenceType == 'job' || referenceType == 'candidate';
  }

  Future<void> markInboxItemsRead(Iterable<dynamic> ids) async {
    final targetIds = ids
        .map((id) => id?.toString().trim() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
    if (targetIds.isEmpty) return;

    var changed = false;
    final next = inbox.value
        .map((item) {
          final currentId = (item['id'] ?? '').toString().trim();
          if (!targetIds.contains(currentId) ||
              _isMarkedRead(item['is_read'])) {
            return item;
          }

          changed = true;
          return {...item, 'is_read': true};
        })
        .toList(growable: false);

    if (!changed) return;
    inbox.value = next;
    await _persistInbox();
  }

  Future<void> markNonActionableInboxItemsRead() async {
    final ids = inbox.value
        .where(
          (item) =>
              !_isMarkedRead(item['is_read']) &&
              !isActionableNotification(item),
        )
        .map((item) => item['id'])
        .toList(growable: false);
    await markInboxItemsRead(ids);
  }

  Future<void> _applyUnreadCountFromPayload(Map<String, dynamic> data) async {
    final unreadFromPayload = _asInt(data['unread_count']);
    if (unreadFromPayload != null) {
      await setServerUnreadCount(unreadFromPayload);
      return;
    }

    final isStoredNotification =
        (data['stored_notification'] ?? '').toString().trim().toLowerCase() ==
        'true';
    if (isStoredNotification) {
      await setServerUnreadCount(_serverUnreadCount + 1);
    }
  }

  Future<void> _handleIncoming(
    RemoteMessage message, {
    required String source,
  }) async {
    try {
      final data = message.data;
      await _applyUnreadCountFromPayload(data);
      final isStoredNotification =
          (data['stored_notification'] ?? '').toString().trim().toLowerCase() ==
          'true';

      if (isStoredNotification) {
        if (kDebugMode) {
          debugPrint(
            '[FCM] skip local inbox for stored notification ($source)',
          );
        }
        return;
      }

      final titleEn = (data['title_en'] ?? message.notification?.title ?? '')
          .toString();
      final bodyEn = (data['body_en'] ?? message.notification?.body ?? '')
          .toString();

      final titleHi = (data['title_hi'] ?? data['title_hindi'] ?? '')
          .toString();
      final bodyHi = (data['body_hi'] ?? data['body_hindi'] ?? '').toString();

      final selectedTitle = _pickLocalized(en: titleEn, hi: titleHi);
      final selectedBody = _pickLocalized(en: bodyEn, hi: bodyHi);

      if (kDebugMode) {
        debugPrint(
          '[FCM] store message($source): title="$selectedTitle" body="$selectedBody"',
        );
      }

      final now = DateTime.now();
      final item = <String, dynamic>{
        'id': message.messageId ?? '${now.microsecondsSinceEpoch}',
        'source': source,
        'title_en': titleEn,
        'body_en': bodyEn,
        'title_hi': titleHi,
        'body_hi': bodyHi,
        'received_at': now.toIso8601String(),
        'reference_type': data['reference_type'] ?? data['entity'] ?? '',
        'reference_id': data['reference_id'] ?? data['entity_id'] ?? '',
        'is_read': false,
        'data': jsonEncode(data),
      };

      final next = <Map<String, dynamic>>[item, ...inbox.value];
      if (next.length > 50) next.removeRange(50, next.length);

      inbox.value = next;
      await _persistInbox();
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] store message failed: $e');
    }
  }

  void dispose() {
    _tokenSub?.cancel();
    _onMessageSub?.cancel();
    _onMessageOpenedSub?.cancel();
  }
}
