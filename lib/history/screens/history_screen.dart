import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:rotijugaad/history/widgets/contact_history_item.dart';
import 'package:rotijugaad/history/widgets/interest_history_item.dart';
import 'package:rotijugaad/common/widgets/app_shimmer_placeholders.dart';
import 'package:rotijugaad/theme/context_ext.dart';

import '../../common/widgets/toolbar.dart';
import '../../utils/custom_exception.dart';
import '../../utils/result.dart';
import '../../utils/shared_pref.dart';
import '../services/employee_history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final EmployeeHistoryService _service = EmployeeHistoryService();

  bool _loadingContacts = false;
  bool _loadingInterests = false;

  CustomException? _contactsError;
  CustomException? _interestsError;

  List<Map<String, dynamic>> _contacts = const [];
  List<Map<String, dynamic>> _interests = const [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      _ensureLoaded(_tabController.index);
    });
    _ensureLoaded(0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  List<Map<String, dynamic>> _asMapList(dynamic v) {
    if (v is List) {
      return v.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
    }
    return const [];
  }

  int _getEmployeeId() {
    var employeeId = SharedPrefUtils.readInt('auth_employee_id');
    if (employeeId > 0) return employeeId;

    final profile = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_PROFILE_JSON);
    employeeId = _asInt(profile?['id'] ?? profile?['employeeId']);
    return employeeId;
  }

  void _ensureLoaded(int index) {
    if (index == 0 && _contacts.isEmpty && !_loadingContacts) {
      _loadContacts();
    }
    if (index == 1 && _interests.isEmpty && !_loadingInterests) {
      _loadInterests();
    }
  }

  Future<void> _loadContacts() async {
    if (_loadingContacts) return;

    final employeeId = _getEmployeeId();
    if (employeeId <= 0) {
      setState(() {
        _contactsError = CustomException(
          code: 'NO_EMPLOYEE',
          message: 'errors.no_employee_id'.tr(),
        );
      });
      return;
    }

    setState(() {
      _loadingContacts = true;
      _contactsError = null;
    });

    final result = await _service.getContacts(employeeId);
    if (!mounted) return;

    switch (result) {
      case Success(value: final value):
        setState(() {
          _contacts = _asMapList(value['results']);
        });
        break;
      case Failure(exception: final e):
        setState(() {
          _contactsError = e;
        });
        break;
    }

    if (!mounted) return;
    setState(() {
      _loadingContacts = false;
    });
  }

  Future<void> _loadInterests() async {
    if (_loadingInterests) return;

    final employeeId = _getEmployeeId();
    if (employeeId <= 0) {
      setState(() {
        _interestsError = CustomException(
          code: 'NO_EMPLOYEE',
          message: 'errors.no_employee_id'.tr(),
        );
      });
      return;
    }

    setState(() {
      _loadingInterests = true;
      _interestsError = null;
    });

    final result = await _service.getInterests(employeeId);
    if (!mounted) return;

    switch (result) {
      case Success(value: final value):
        setState(() {
          _interests = _asMapList(value['results']);
        });
        break;
      case Failure(exception: final e):
        setState(() {
          _interestsError = e;
        });
        break;
    }

    if (!mounted) return;
    setState(() {
      _loadingInterests = false;
    });
  }

  Widget _buildState({
    required bool loading,
    required CustomException? error,
    required List<Map<String, dynamic>> items,
    required Widget Function(Map<String, dynamic>) itemBuilder,
    required VoidCallback onRetry,
  }) {
    if (loading) {
      return const AppListShimmer(padding: EdgeInsets.only(top: 12));
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.spacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                error.message,
                style: context.text.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.spacing.md),
              ElevatedButton(
                onPressed: onRetry,
                child: Text('common.retry'.tr()),
              ),
            ],
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Text('history.empty'.tr(), style: context.text.bodyMedium),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.md,
      ).copyWith(top: context.spacing.md),
      itemCount: items.length,
      itemBuilder: (context, index) => itemBuilder(items[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.onPrimary,
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Toolbar('history.screen.title'.tr(), () {
                Navigator.of(context).pop();
              }),
              TabBar(
                controller: _tabController,
                labelColor: context.colors.onBackground,
                labelStyle: context.text.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: context.text.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                unselectedLabelColor: context.colors.onSurface,
                dividerColor: context.xcolors.stroke,
                indicatorColor: context.colors.primary,
                indicatorWeight: 2,
                tabs: [
                  Tab(text: 'history.tabs.contacts'.tr()),
                  Tab(text: 'history.tabs.interests'.tr()),
                ],
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: context.spacing.xs),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildState(
                        loading: _loadingContacts,
                        error: _contactsError,
                        items: _contacts,
                        itemBuilder: (m) => ContactHistoryItem(item: m),
                        onRetry: _loadContacts,
                      ),
                      _buildState(
                        loading: _loadingInterests,
                        error: _interestsError,
                        items: _interests,
                        itemBuilder: (m) => InterestHistoryItem(item: m),
                        onRetry: _loadInterests,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
