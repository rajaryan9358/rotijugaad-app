import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/applicants/providers/applicants_provider.dart';
import 'package:rotijugaad/candidatedetail/screens/candidate_detail_screen.dart';
import 'package:rotijugaad/common/widgets/app_shimmer_placeholders.dart';
import 'package:rotijugaad/common/widgets/toolbar.dart';
import 'package:rotijugaad/employerjobs/screens/employer_job_details_screen.dart';
import 'package:rotijugaad/jobdetails/screens/job_details_screen.dart';
import 'package:rotijugaad/container/container_nav.dart';
import 'package:rotijugaad/jobs/widgets/notification_item.dart';
import 'package:rotijugaad/network/api_client.dart';
import 'package:rotijugaad/network/api_service.dart';
import 'package:rotijugaad/notifications/notification_service.dart';
import 'package:rotijugaad/profile/screens/hired_jobs_screen.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/utils/result.dart';
import 'package:rotijugaad/utils/shared_pref.dart';

class NotificationScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late final NotificationService _service;
  final ApiService _api = ApiService();
  List<Map<String, dynamic>> _storedNotifications = <Map<String, dynamic>>[];
  bool _loading = true;
  bool _didMarkNonActionableOnClose = false;

  int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  String _currentUserType() {
    final userType = SharedPrefUtils.readStr(SharedPrefUtils.USER_TYPE).trim();
    if (userType.isNotEmpty) return userType.toLowerCase();
    return SharedPrefUtils.readStr(
      SharedPrefUtils.AUTH_PROFILE_TYPE,
    ).trim().toLowerCase();
  }

  int? _readProfileId() {
    final profile = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_PROFILE_JSON);
    final raw =
        profile?['id'] ?? profile?['employeeId'] ?? profile?['employerId'];
    final id = int.tryParse(raw?.toString() ?? '');
    if (id == null || id <= 0) return null;
    return id;
  }

  @override
  void initState() {
    super.initState();
    _service = NotificationService.instance;
    NotificationService.init();
    _service.inbox.addListener(_onInboxChanged);
    _loadStoredNotifications();
  }

  @override
  void dispose() {
    _service.inbox.removeListener(_onInboxChanged);
    super.dispose();
  }

  void _onInboxChanged() {
    if (!mounted) return;
    setState(() {});
  }

  int? _readLoggedInUserId() {
    final loggedIn = SharedPrefUtils.readBool(SharedPrefUtils.AUTH_LOGGED_IN);
    if (!loggedIn) return null;

    final user = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_USER_JSON);
    final idRaw = user?['id'] ?? user?['user_id'] ?? user?['userId'];
    final id = int.tryParse(idRaw?.toString() ?? '');
    if (id == null || id <= 0) return null;
    return id;
  }

  Future<void> _loadStoredNotifications() async {
    final userId = _readLoggedInUserId();
    if (userId == null) {
      await _service.setServerUnreadCount(0);
      if (!mounted) return;
      setState(() {
        _storedNotifications = <Map<String, dynamic>>[];
        _loading = false;
      });
      return;
    }

    final result = await _api.getJson<Map<String, dynamic>>(
      endpoint: ApiClient.userNotifications(userId),
      fromJson: (json) => json ?? <String, dynamic>{},
    );

    if (!mounted) return;

    if (result case Success<Map<String, dynamic>, dynamic>(value: final data)) {
      final rawList = data['notifications'];
      final list = rawList is List
          ? rawList
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
          : <Map<String, dynamic>>[];
      await _service.setServerUnreadCount(_asInt(data['unread_count']));
      setState(() {
        _storedNotifications = list;
        _loading = false;
      });
      return;
    }

    setState(() {
      _storedNotifications = <Map<String, dynamic>>[];
      _loading = false;
    });
  }

  bool _isHindiSelected() {
    return SharedPrefUtils.readStr(
          SharedPrefUtils.APP_LANGUAGE,
        ).trim().toLowerCase() ==
        'hi';
  }

  String _pickLocalized({required String en, required String hi}) {
    if (_isHindiSelected()) return hi.trim().isNotEmpty ? hi : en;
    return en.trim().isNotEmpty ? en : hi;
  }

  String _formatDateLabel(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final mm = (dt.month >= 1 && dt.month <= 12) ? months[dt.month - 1] : '';
      return '${dt.day} $mm';
    } catch (_) {
      return '';
    }
  }

  bool _isStoredInboxItem(Map<String, dynamic> item) {
    final rawData = (item['data'] ?? '').toString().trim();
    if (rawData.isEmpty) return false;
    try {
      final decoded = rawData.startsWith('{') ? decodedJson(rawData) : null;
      return (decoded?['stored_notification'] ?? '')
              .toString()
              .trim()
              .toLowerCase() ==
          'true';
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic>? decodedJson(String value) {
    return value.isEmpty ? null : Map<String, dynamic>.from(jsonDecode(value));
  }

  bool _isStoredItem(Map<String, dynamic> item) => item['kind'] == 'stored';

  bool _isRead(Map<String, dynamic> item) {
    final value = item['is_read'];
    if (value is bool) return value;
    final text = value?.toString().trim().toLowerCase() ?? '';
    return text == 'true' || text == '1';
  }

  Future<void> _markStoredNotificationsRead(List<int> notificationIds) async {
    final userId = _readLoggedInUserId();
    if (userId == null || notificationIds.isEmpty) return;

    final uniqueIds = notificationIds.toSet().toList(growable: false);
    final result = await _api.putJson<Map<String, dynamic>>(
      endpoint: ApiClient.userNotificationsRead(userId),
      body: {'notification_ids': uniqueIds},
      fromJson: (json) => json ?? <String, dynamic>{},
    );

    if (result case Success<Map<String, dynamic>, dynamic>(value: final data)) {
      await _service.setServerUnreadCount(_asInt(data['unread_count']));
      if (!mounted) return;
      setState(() {
        _storedNotifications = _storedNotifications
            .map((item) {
              final id = _asInt(item['id'], fallback: -1);
              if (!uniqueIds.contains(id)) return item;
              return {...item, 'is_read': true};
            })
            .toList(growable: false);
      });
    }
  }

  Future<void> _markNotificationRead(Map<String, dynamic> item) async {
    if (_isRead(item)) return;

    if (_isStoredItem(item)) {
      final id = _asInt(item['id'], fallback: -1);
      if (id > 0) {
        await _markStoredNotificationsRead([id]);
      }
      return;
    }

    await _service.markInboxItemsRead([item['id']]);
  }

  Future<void> _markNonActionableAsRead() async {
    final storedIds = _storedNotifications
        .where((item) => !_isRead(item) && !_isActionable(item))
        .map((item) => _asInt(item['id'], fallback: -1))
        .where((id) => id > 0)
        .toList(growable: false);

    if (storedIds.isNotEmpty) {
      await _markStoredNotificationsRead(storedIds);
    }

    await _service.markNonActionableInboxItemsRead();
  }

  Future<void> _handleScreenClose() async {
    if (_didMarkNonActionableOnClose) return;
    _didMarkNonActionableOnClose = true;
    await _markNonActionableAsRead();
  }

  Future<void> _openNotificationTarget(Map<String, dynamic> item) async {
    await _markNotificationRead(item);

    final referenceType = (item['reference_type'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    final userType = _currentUserType();

    final rawData = (item['data'] ?? '').toString().trim();
    final decodedData = rawData.startsWith('{') ? decodedJson(rawData) : null;
    final event = (decodedData?['event'] ?? '').toString().trim().toLowerCase();

    if (referenceType == 'employer_credit' || referenceType == 'employee_credit') {
      ContainerNav.switchTab(3);
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    if (event == 'application.hired' && userType == 'employee') {
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HiredJobsScreen()),
      );
      return;
    }

    if (event == 'application.hired.employer' && userType == 'employer') {
      ContainerNav.switchTab(1);
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      context.read<ApplicantsProvider>().setFilter('Hired');
      return;
    }

    final referenceId = int.tryParse((item['reference_id'] ?? '').toString());
    if (referenceId == null || referenceId <= 0) return;
    if (!mounted) return;

    if (referenceType == 'job') {
      if (userType == 'employee') {
        final employeeId = _readProfileId();
        if (employeeId == null || employeeId <= 0) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                JobDetailsScreen(jobId: referenceId, employeeId: employeeId),
          ),
        );
        return;
      }

      if (userType == 'employer') {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EmployerJobDetailsScreen(jobId: referenceId),
          ),
        );
      }
      return;
    }

    if (referenceType == 'candidate' && userType == 'employer') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CandidateDetailScreen(candidateId: referenceId),
        ),
      );
    }
  }

  bool _isActionable(Map<String, dynamic> item) {
    final referenceType = (item['reference_type'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    if (referenceType == 'employer_credit' || referenceType == 'employee_credit') return true;
    final referenceId = int.tryParse((item['reference_id'] ?? '').toString());
    if (referenceId == null || referenceId <= 0) return false;
    return referenceType == 'job' || referenceType == 'candidate';
  }

  List<Map<String, dynamic>> _buildItems() {
    final localItems = _service.inbox.value
        .where((item) => !_isStoredInboxItem(item))
        .map((item) {
          final next = Map<String, dynamic>.from(item);
          next['kind'] = 'local';
          final rawData = (item['data'] ?? '').toString().trim();
          if (rawData.startsWith('{')) {
            final decoded = decodedJson(rawData);
            next['reference_type'] =
                decoded?['reference_type'] ?? decoded?['entity'] ?? '';
            next['reference_id'] =
                decoded?['reference_id'] ?? decoded?['entity_id'] ?? '';
          }
          return next;
        });

    final storedItems = _storedNotifications.map(
      (item) => {
        'kind': 'stored',
        'id': item['id'],
        'title_en': item['title_en'] ?? item['title_english'] ?? '',
        'title_hi': item['title_hi'] ?? item['title_hindi'] ?? '',
        'body_en': item['body_en'] ?? item['body_english'] ?? '',
        'body_hi': item['body_hi'] ?? item['body_hindi'] ?? '',
        'received_at': item['received_at'] ?? item['created_at'] ?? '',
        'reference_type': item['reference_type'] ?? '',
        'reference_id': item['reference_id'] ?? '',
        'is_read': item['is_read'] ?? false,
      },
    );

    final merged = <Map<String, dynamic>>[...storedItems, ...localItems];

    merged.sort((a, b) {
      final aTime =
          DateTime.tryParse((a['received_at'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bTime =
          DateTime.tryParse((b['received_at'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });

    return merged;
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildItems();
    final emptyView = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.18),
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("assets/images/img_notification.png"),
              SizedBox(height: context.spacing.sm),
              Text(
                "No Notifications Available",
                style: context.text.bodyMedium!.copyWith(
                  color: context.colors.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return WillPopScope(
      onWillPop: () async {
        await _handleScreenClose();
        return true;
      },
      child: Scaffold(
        backgroundColor: context.colors.onPrimary,
        body: Column(
          children: [
            Container(
              color: context.colors.onPrimary,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).viewPadding.top,
              ),
              child: Toolbar("Notifications", () async {
                await _handleScreenClose();
                if (!context.mounted) return;
                Navigator.of(context).pop();
              }),
            ),
            Expanded(
              child: _loading
                  ? const AppListShimmer(padding: EdgeInsets.only(top: 12))
                  : items.isEmpty
                  ? RefreshIndicator(
                      onRefresh: _loadStoredNotifications,
                      child: emptyView,
                    )
                  : RefreshIndicator(
                      onRefresh: _loadStoredNotifications,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: items.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          final n = items[index];
                          final titleEn = (n['title_en'] ?? '').toString();
                          final titleHi = (n['title_hi'] ?? '').toString();
                          final bodyEn = (n['body_en'] ?? '').toString();
                          final bodyHi = (n['body_hi'] ?? '').toString();
                          final receivedAt = (n['received_at'] ?? '')
                              .toString();

                          final title = _pickLocalized(
                            en: titleEn,
                            hi: titleHi,
                          );
                          final body = _pickLocalized(en: bodyEn, hi: bodyHi);

                          return NotificationItem(
                            title: title.isNotEmpty ? title : '-',
                            description: body.isNotEmpty ? body : '-',
                            dateLabel: _formatDateLabel(receivedAt),
                            isRead: _isRead(n),
                            isActionable: _isActionable(n),
                            onTap: _isActionable(n)
                                ? () => _openNotificationTarget(n)
                                : null,
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
