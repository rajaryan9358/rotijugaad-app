import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../common/widgets/toolbar.dart';
import '../../common/widgets/app_shimmer_placeholders.dart';
import '../../theme/context_ext.dart';
import '../../utils/custom_exception.dart';
import '../../utils/result.dart';
import '../../utils/shared_pref.dart';
import '../services/employer_history_service.dart';
import '../widgets/employer_ads_history_item.dart';
import '../widgets/employer_contact_history_item.dart';
import '../widgets/employer_interest_history_item.dart';

class EmployerHistoryScreen extends StatefulWidget {
  const EmployerHistoryScreen({super.key});

  @override
  State<StatefulWidget> createState() => _EmployerHistoryScreenState();
}

class _EmployerHistoryScreenState extends State<EmployerHistoryScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final EmployerHistoryService _service = EmployerHistoryService();

  bool _loadingContacts = false;
  bool _loadingInterests = false;
  bool _loadingAds = false;

  CustomException? _contactsError;
  CustomException? _interestsError;
  CustomException? _adsError;

  List<Map<String, dynamic>> _contacts = const [];
  List<Map<String, dynamic>> _interests = const [];
  List<Map<String, dynamic>> _ads = const [];

  int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  List<Map<String, dynamic>> _asMapList(dynamic v) {
    if (v is List) {
      return v.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
    }
    return const [];
  }

  int _getEmployerId() {
    var employerId = SharedPrefUtils.readInt('auth_employer_id');
    if (employerId > 0) return employerId;

    final profile = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_PROFILE_JSON);
    employerId = _asInt(profile?['id'] ?? profile?['employerId']);
    return employerId;
  }

  Future<void> _loadContacts() async {
    if (_loadingContacts) return;

    final employerId = _getEmployerId();
    if (employerId <= 0) {
      setState(() {
        _contactsError = CustomException(
          code: 'NO_EMPLOYER',
          message: 'errors.no_employer_id'.tr(),
        );
      });
      return;
    }

    setState(() {
      _loadingContacts = true;
      _contactsError = null;
    });

    final result = await _service.getContacts(employerId);
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

    final employerId = _getEmployerId();
    if (employerId <= 0) {
      setState(() {
        _interestsError = CustomException(
          code: 'NO_EMPLOYER',
          message: 'errors.no_employer_id'.tr(),
        );
      });
      return;
    }

    setState(() {
      _loadingInterests = true;
      _interestsError = null;
    });

    final result = await _service.getInterests(employerId);
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

  Future<void> _loadAds() async {
    if (_loadingAds) return;

    final employerId = _getEmployerId();
    if (employerId <= 0) {
      setState(() {
        _adsError = CustomException(
          code: 'NO_EMPLOYER',
          message: 'errors.no_employer_id'.tr(),
        );
      });
      return;
    }

    setState(() {
      _loadingAds = true;
      _adsError = null;
    });

    final result = await _service.getAds(employerId);
    if (!mounted) return;

    switch (result) {
      case Success(value: final value):
        setState(() {
          _ads = _asMapList(value['results']);
        });
        break;
      case Failure(exception: final e):
        setState(() {
          _adsError = e;
        });
        break;
    }

    if (!mounted) return;
    setState(() {
      _loadingAds = false;
    });
  }

  void _ensureLoaded(int index) {
    if (index == 0 && _contacts.isEmpty && !_loadingContacts) _loadContacts();
    if (index == 1 && _interests.isEmpty && !_loadingInterests)
      _loadInterests();
    if (index == 2 && _ads.isEmpty && !_loadingAds) _loadAds();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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

  Widget _buildState({
    required bool loading,
    required CustomException? error,
    required List<Map<String, dynamic>> items,
    required Widget Function(Map<String, dynamic>) itemBuilder,
    required VoidCallback onRetry,
  }) {
    if (loading) return const AppListShimmer(padding: EdgeInsets.only(top: 12));
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error.message, style: context.text.bodyMedium),
            SizedBox(height: context.spacing.md),
            ElevatedButton(
              onPressed: onRetry,
              child: Text('common.retry'.tr()),
            ),
          ],
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
          length: 3,
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
                  Tab(text: 'history.tabs.ads'.tr()),
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
                        itemBuilder: (m) => EmployerContactHistoryItem(item: m),
                        onRetry: _loadContacts,
                      ),
                      _buildState(
                        loading: _loadingInterests,
                        error: _interestsError,
                        items: _interests,
                        itemBuilder: (m) =>
                            EmployerInterestHistoryItem(item: m),
                        onRetry: _loadInterests,
                      ),
                      _buildState(
                        loading: _loadingAds,
                        error: _adsError,
                        items: _ads,
                        itemBuilder: (m) => EmployerAdsHistoryItem(item: m),
                        onRetry: _loadAds,
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
