import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/common/widgets/app_loading_indicator.dart';
import 'package:rotijugaad/common/widgets/app_shimmer.dart';
import 'package:rotijugaad/common/widgets/labeled_form_field.dart';
import 'package:rotijugaad/common/widgets/xicon.dart';
import 'package:rotijugaad/editprofile/screens/edit_profile.dart';
import 'package:rotijugaad/employees/providers/employees_provider.dart';
import 'package:rotijugaad/stories/providers/stories_provider.dart';
import 'package:rotijugaad/filters/sheets/jobs_filter_sheet.dart';
import 'package:rotijugaad/filters/utils/masters_filter_sections.dart';
import 'package:rotijugaad/jobdetails/screens/job_details_screen.dart';
import 'package:rotijugaad/jobs/screens/help_support_screen.dart';
import 'package:rotijugaad/jobs/screens/notification_screen.dart';
import 'package:rotijugaad/notifications/notification_service.dart';
import 'package:rotijugaad/jobs/screens/story_screen.dart';
import 'package:rotijugaad/jobs/providers/jobs_provider.dart';
import 'package:rotijugaad/jobs/widgets/incomplete_card.dart';
import 'package:rotijugaad/jobs/widgets/job_item.dart';
import 'package:rotijugaad/jobs/widgets/job_item_shimmer.dart';
import 'package:rotijugaad/jobs/widgets/pending_card.dart';
import 'package:rotijugaad/jobs/widgets/rejected_card.dart';
import 'package:rotijugaad/auth/utils/account_status_guard.dart';
import 'package:rotijugaad/profile/dialogs/profile_incomplete_dialog.dart';
import 'package:rotijugaad/profile/utils/session_refresh_helper.dart';
import 'package:rotijugaad/utils/shared_pref.dart';
import 'package:rotijugaad/masters/models/misc_dtos.dart';
import 'package:rotijugaad/masters/providers/masters_provider.dart';
import 'package:rotijugaad/theme/app_icons.dart';
import 'package:rotijugaad/settings/providers/language_provider.dart';
import 'package:rotijugaad/theme/context_ext.dart';

import '../../filters/models/filter_section.dart';
import '../models/get_all_jobs_request.dart';
import '../models/job_dto.dart';
import '../models/story_model.dart';
import '../widgets/story_item.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> with TickerProviderStateMixin {
  static const String _filtersStorageKey = SharedPrefUtils.JOBS_FILTERS_JSON;

  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  Map<String, Set<String>> _selectedFilters = const {};
  bool _didFinishInitialPageLoad = false;
  bool? _filterSectionsIsHindi;
  bool _isLoadingFilterSections = false;
  List<FilterSection> _filterSections = const [];
  bool _isFirstVisit = false;

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  double? _asDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  int? get _employeeId {
    final profile = _authProfileJson;
    return _asInt(profile?['id'] ?? profile?['employeeId']);
  }

  double? get _employeeLat {
    final profile = _authProfileJson;
    return _asDouble(profile?['lat']);
  }

  double? get _employeeLng {
    final profile = _authProfileJson;
    return _asDouble(profile?['lng']);
  }

  List<int> _parseIntIds(Set<String>? values) {
    final out = <int>[];
    for (final v in values ?? const <String>{}) {
      final n = int.tryParse(v);
      if (n != null && n > 0) out.add(n);
    }
    return out;
  }

  Future<List<RangeFilter>> _salaryRangesFromIds(
    MastersProvider masters,
    Set<String>? selectedIds,
  ) async {
    final ids = _parseIntIds(selectedIds);
    if (ids.isEmpty) return const [];

    final list = await masters.getSalaryRangesFromDb();
    final byId = {for (final s in list) s.id: s};

    final out = <RangeFilter>[];
    for (final id in ids) {
      final s = byId[id];
      if (s == null) continue;
      out.add(RangeFilter(min: s.salaryFrom, max: s.salaryTo));
    }
    return out;
  }

  Future<List<RangeFilter>> _experienceRangesFromIds(
    MastersProvider masters,
    Set<String>? selectedIds,
  ) async {
    final ids = _parseIntIds(selectedIds);
    if (ids.isEmpty) return const [];

    final list = await masters.getExperiencesFromDb();
    final byId = {for (final e in list) e.id: e};

    final out = <RangeFilter>[];
    for (final id in ids) {
      final ExperienceDto? e = byId[id];
      if (e == null) continue;
      out.add(
        RangeFilter(min: e.expFrom?.toDouble(), max: e.expTo?.toDouble()),
      );
    }
    return out;
  }

  Future<List<RangeFilter>> _distanceRangesFromIds(
    MastersProvider masters,
    Set<String>? selectedIds,
  ) async {
    final ids = _parseIntIds(selectedIds);
    if (ids.isEmpty) return const [];

    final list = await masters.getDistancesFromDb();
    final byId = {for (final d in list) d.id: d};

    final out = <RangeFilter>[];
    for (final id in ids) {
      final d = byId[id];
      final km = d?.distance;
      if (km == null) continue;
      out.add(RangeFilter(max: km));
    }
    return out;
  }

  Future<void> _fetchAllJobs({int page = 1}) async {
    final id = _employeeId;
    if (id == null || id <= 0) return;

    final masters = context.read<MastersProvider>();

    final salaryRanges = await _salaryRangesFromIds(
      masters,
      _selectedFilters['salary_range'],
    );
    final experienceRanges = await _experienceRangesFromIds(
      masters,
      _selectedFilters['experience'],
    );
    final distanceRanges = await _distanceRangesFromIds(
      masters,
      _selectedFilters['distance'],
    );

    final verificationSet = _selectedFilters['verification_status'];
    final verification = (verificationSet != null && verificationSet.isNotEmpty)
        ? verificationSet.first
        : '';

    final genderSet = _selectedFilters['gender'];
    final genderRaw = (genderSet != null && genderSet.isNotEmpty)
        ? genderSet.first
        : '';
    final gender = (genderRaw == 'other') ? 'any' : genderRaw;

    final req = GetAllJobsRequest(
      search: _searchController.text.trim(),
      jobProfileIds: _parseIntIds(_selectedFilters['job_profile']),
      preferredStateIds: _parseIntIds(_selectedFilters['preferred_state']),
      preferredCityIds: _parseIntIds(_selectedFilters['preferred_city']),
      salaryTypeIds: _parseIntIds(_selectedFilters['salary_type']),
      skillIds: _parseIntIds(_selectedFilters['skill']),
      qualificationIds: _parseIntIds(_selectedFilters['qualification']),
      shiftIds: _parseIntIds(_selectedFilters['shift']),
      businessCategoryIds: _parseIntIds(_selectedFilters['business_category']),
      salaryRanges: salaryRanges,
      experienceRanges: experienceRanges,
      distanceRanges: distanceRanges,
      verification: verification.trim(),
      gender: gender.trim(),
      employeeId: id,
      lat: _employeeLat,
      lng: _employeeLng,
      page: page,
      limit: 10,
    );

    await context.read<JobsProvider>().fetchAllJobs(request: req);
  }

  Future<void> _fetchRecommendedJobs() async {
    final id = _employeeId;
    if (id == null || id <= 0) return;

    final masters = context.read<MastersProvider>();

    final salaryRanges = await _salaryRangesFromIds(
      masters,
      _selectedFilters['salary_range'],
    );
    final experienceRanges = await _experienceRangesFromIds(
      masters,
      _selectedFilters['experience'],
    );
    final distanceRanges = await _distanceRangesFromIds(
      masters,
      _selectedFilters['distance'],
    );

    final verificationSet = _selectedFilters['verification_status'];
    final verification = (verificationSet != null && verificationSet.isNotEmpty)
        ? verificationSet.first
        : '';

    final genderSet = _selectedFilters['gender'];
    final genderRaw = (genderSet != null && genderSet.isNotEmpty)
        ? genderSet.first
        : '';
    final gender = (genderRaw == 'other') ? 'any' : genderRaw;

    final req = GetAllJobsRequest(
      search: _searchController.text.trim(),
      jobProfileIds: _parseIntIds(_selectedFilters['job_profile']),
      preferredStateIds: _parseIntIds(_selectedFilters['preferred_state']),
      preferredCityIds: _parseIntIds(_selectedFilters['preferred_city']),
      salaryTypeIds: _parseIntIds(_selectedFilters['salary_type']),
      skillIds: _parseIntIds(_selectedFilters['skill']),
      qualificationIds: _parseIntIds(_selectedFilters['qualification']),
      shiftIds: _parseIntIds(_selectedFilters['shift']),
      businessCategoryIds: _parseIntIds(_selectedFilters['business_category']),
      salaryRanges: salaryRanges,
      experienceRanges: experienceRanges,
      distanceRanges: distanceRanges,
      verification: verification.trim(),
      gender: gender.trim(),
      employeeId: id,
      lat: _employeeLat,
      lng: _employeeLng,
      page: 1,
      limit: 10,
    );

    await context.read<JobsProvider>().fetchRecommendedJobs(id, request: req);
  }

  Future<void> _refreshVerificationStatus() async {
    final id = _employeeId;
    if (id == null || id <= 0) return;

    await SessionRefreshHelper.refreshCurrentSession(context);
    if (!mounted) return;

    final wasInactive = await AccountStatusGuard.handleIfInactive(context);
    if (wasInactive) return;

    await Future.wait([
      context.read<StoriesProvider>().fetchEmployeeStories(id),
      _fetchAllJobs(),
      _fetchRecommendedJobs(),
    ]);
  }

  late final TabController _tabController;

  Map<String, dynamic>? get _authUserJson =>
      SharedPrefUtils.readJson(SharedPrefUtils.AUTH_USER_JSON);

  Map<String, dynamic>? get _authProfileJson =>
      SharedPrefUtils.readJson(SharedPrefUtils.AUTH_PROFILE_JSON);

  bool get _isProfileCompleted =>
      SharedPrefUtils.readBool(SharedPrefUtils.AUTH_PROFILE_COMPLETED);

  String get _verificationStatus {
    final raw =
        (_authProfileJson?['verification_status'] ??
                _authProfileJson?['verificationStatus'])
            ?.toString()
            .trim()
            .toLowerCase();
    final v = raw ?? '';
    return v == 'init' ? '' : v;
  }

  String get _displayName {
    final isHindi = context.locale.languageCode.toLowerCase() == 'hi';

    String? pick(Map<String, dynamic>? map) {
      if (map == null) return null;
      final hi = (map['name_hindi'] ?? map['nameHindi'])?.toString().trim();
      final en = (map['name_english'] ?? map['nameEnglish'] ?? map['name'])
          ?.toString()
          .trim();
      final primary = isHindi ? hi : en;
      final fallback = isHindi ? en : hi;
      final value = primary ?? fallback;
      if (value == null || value.isEmpty) return null;
      return value;
    }

    final profileName = pick(_authProfileJson);
    if (profileName != null && profileName.isNotEmpty) return profileName;

    final userName = pick(_authUserJson);
    if (userName != null && userName.isNotEmpty) return userName;

    return '';
  }

  Future<void> _openProfileFlow({required String title}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfile(
          mode: EditProfileMode.completeFlow,
          title: title,
          openKycOnSubmit: true,
        ),
      ),
    );

    if (!mounted || result != true) return;

    await _refreshVerificationStatus();
    if (!mounted) return;
    setState(() {});
  }

  Widget _buildVerificationIcon({
    required Color primaryColor,
    required Color warningColor,
    required Color failureColor,
  }) {
    switch (_verificationStatus) {
      case 'verified':
        return XIcon(AppIcon.verified, color: primaryColor, size: 18);
      case 'pending':
        return XIcon(AppIcon.profilePending, color: warningColor, size: 18);
      case 'rejected':
        return XIcon(AppIcon.rejected, color: failureColor, size: 18);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTopHeader(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Container(
      color: colors.onPrimary,
      padding: EdgeInsets.only(
        top: spacing.sm + MediaQuery.of(context).viewPadding.top,
        bottom: spacing.sm,
        left: spacing.md,
        right: spacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isFirstVisit
                    ? 'candidates.welcome'.tr()
                    : 'candidates.welcome_back'.tr(),
                style: context.text.bodyMedium!.copyWith(
                  color: colors.onPrimaryContainer,
                ),
              ),
              Row(
                children: [
                  Text(
                    _displayName.isEmpty ? '—' : _displayName,
                    style: context.text.bodySmall!.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                  if (_verificationStatus.isNotEmpty) ...[
                    SizedBox(width: spacing.xs),
                    _buildVerificationIcon(
                      primaryColor: colors.primary,
                      warningColor: context.xcolors.warning,
                      failureColor: context.xcolors.failure,
                    ),
                  ],
                ],
              ),
            ],
          ),
          Row(
            children: [
              ValueListenableBuilder<int>(
                valueListenable: NotificationService.instance.unreadCount,
                builder: (context, unreadCount, _) {
                  final badgeText = unreadCount > 99
                      ? '99+'
                      : unreadCount.toString();

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationScreen(),
                            ),
                          );
                        },
                        icon: XIcon(AppIcon.notification),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            constraints: const BoxConstraints(minWidth: 18),
                            decoration: BoxDecoration(
                              color: context.xcolors.failure,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              badgeText,
                              textAlign: TextAlign.center,
                              style: context.text.bodySmall?.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HelpSupportScreen(),
                    ),
                  );
                },
                icon: XIcon(AppIcon.helpSupport),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    NotificationService.init();
    _selectedFilters = _readPersistedFilters();
    _isFirstVisit = !SharedPrefUtils.readBool(SharedPrefUtils.HAS_SEEN_HOME);
    if (_isFirstVisit) SharedPrefUtils.saveBool(SharedPrefUtils.HAS_SEEN_HOME, true);
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (_tabController.index == 1 && !_tabController.indexIsChanging) {
        _fetchRecommendedJobs();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.refreshUnreadCount();
      _loadInitialPageData();
    });
  }

  Future<void> _loadInitialPageData() async {
    final id = _employeeId;
    if (id == null || id <= 0) {
      if (mounted) {
        setState(() {
          _didFinishInitialPageLoad = true;
        });
      }
      return;
    }

    if (!mounted) return;
    final wasInactive = await AccountStatusGuard.handleIfInactive(context);
    if (wasInactive || !mounted) return;

    try {
      final isHindi = context.read<LanguageProvider>().isHindi;
      await _loadFilterSections(isHindi: isHindi);
      await Future.wait([
        context.read<StoriesProvider>().fetchEmployeeStories(id),
        _fetchAllJobs(),
      ]);
    } finally {
      if (mounted) {
        setState(() {
          _didFinishInitialPageLoad = true;
        });
      }
    }

    if (_isProfileCompleted) {
      _fetchRecommendedJobs();
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<Map<String, Set<String>>?> showAdvancedFilterSheet(
    BuildContext context, {
    required List<FilterSection> sections,
    Map<String, Set<String>>? initial,
  }) {
    return showModalBottomSheet<Map<String, Set<String>>>(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final height = MediaQuery.of(context).size.height * 0.8; // 60% height
        return SizedBox(
          height: height,
          child: JobsFilterSheet(sections: sections, initial: initial ?? {}),
        );
      },
    );
  }

  Map<String, Set<String>> _readPersistedFilters() {
    final raw = SharedPrefUtils.readJson(_filtersStorageKey);
    if (raw == null || raw.isEmpty) return {};

    final parsed = <String, Set<String>>{};
    raw.forEach((key, value) {
      if (value is List) {
        parsed[key] = value
            .map((item) => item?.toString() ?? '')
            .where((item) => item.isNotEmpty)
            .toSet();
      }
    });
    return parsed;
  }

  Future<void> _persistSelectedFilters() {
    final payload = <String, dynamic>{
      for (final entry in _selectedFilters.entries)
        if (entry.value.isNotEmpty) entry.key: entry.value.toList(),
    };
    return SharedPrefUtils.saveJson(_filtersStorageKey, payload);
  }

  int get _appliedFilterCount {
    return _selectedFilters.entries.where((e) => e.value.isNotEmpty).length;
  }

  Future<List<FilterSection>> _loadFilterSections({
    required bool isHindi,
    bool force = false,
  }) async {
    if (!force &&
        _filterSections.isNotEmpty &&
        _filterSectionsIsHindi == isHindi) {
      return _filterSections;
    }
    if (_isLoadingFilterSections) return _filterSections;

    _isLoadingFilterSections = true;
    try {
      final sections = await MastersFilterSections.buildJobs(
        context.read<MastersProvider>(),
        isHindi: isHindi,
      );
      if (!mounted) return sections;
      setState(() {
        _filterSections = sections;
        _filterSectionsIsHindi = isHindi;
      });
      return sections;
    } finally {
      _isLoadingFilterSections = false;
    }
  }

  String _filterButtonLabel(BuildContext context) {
    final count = _appliedFilterCount;
    final baseLabel = 'jobs.filters'.tr();
    if (count == 0) return baseLabel;
    return '$baseLabel ($count)';
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when employee detail refreshes so verification UI updates.
    context.watch<EmployeesProvider>().employeeDetail;

    final colors = context.colors;
    final spacing = context.spacing;

    final storiesProvider = context.watch<StoriesProvider>();
    final isHindi = context.watch<LanguageProvider>().isHindi;
    if (_filterSectionsIsHindi != isHindi && !_isLoadingFilterSections) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadFilterSections(isHindi: isHindi, force: true);
        }
      });
    }
    final jobsProvider = context.watch<JobsProvider>();
    final showRecommendedTab = _isProfileCompleted;
    final hasAppliedFilters = _appliedFilterCount > 0;
    final showInitialPageShimmer =
        !_didFinishInitialPageLoad &&
        (jobsProvider.isLoadingAll || storiesProvider.isLoadingEmployee);

    if (showInitialPageShimmer) {
      return Column(
        children: [
          _buildTopHeader(context),
          const Expanded(child: _JobsPageShimmer()),
        ],
      );
    }

    Widget buildJobTile(JobDto job) {
      return InkWell(
        onTap: () async {
          if (!_isProfileCompleted) {
            await showDialog<void>(
              context: context,
              barrierDismissible: true,
              builder: (dialogContext) => ProfileIncompleteDialog(
                onCompleteProfile: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditProfile()),
                  );
                },
              ),
            );
            return;
          }

          final employeeId = _employeeId;
          if (employeeId == null || employeeId <= 0) return;

          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  JobDetailsScreen(jobId: job.id, employeeId: employeeId),
            ),
          );
        },
        child: JobItem(
          job: job,
          onBookmarkTap: () async {
            final employeeId = _employeeId;
            if (employeeId == null || employeeId <= 0) {
              return;
            }
            await context.read<JobsProvider>().toggleWishlist(
              jobId: job.id,
              employeeId: employeeId,
            );
          },
        ),
      );
    }

    Widget buildAllJobsList() {
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: context.spacing.md),
        itemCount: (jobsProvider.allJobs?.jobs.isNotEmpty ?? false)
            ? (jobsProvider.allJobs?.jobs.length ?? 0)
            : (jobsProvider.isLoadingAll ? 6 : 1),
        itemBuilder: (context, index) {
          final jobs = jobsProvider.allJobs?.jobs ?? const [];
          if (jobs.isEmpty) {
            if (jobsProvider.isLoadingAll) {
              return const JobItemShimmer();
            }
            return Padding(
              padding: EdgeInsets.only(
                top: context.spacing.lg,
                left: context.spacing.md,
                right: context.spacing.md,
              ),
              child: Text(
                jobsProvider.lastError?.message ?? 'jobs.empty.all'.tr(),
                style: context.text.bodyMedium,
              ),
            );
          }

          return buildJobTile(jobs[index]);
        },
      );
    }

    Widget buildRecommendedJobsList() {
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: context.spacing.md),
        itemCount:
            1 +
            (jobsProvider.recommendedJobs.isNotEmpty
                ? jobsProvider.recommendedJobs.length
                : (jobsProvider.isLoadingRecommended ? 6 : 1)),
        itemBuilder: (context, index) {
          if (index == 0) {
            final prefix = 'jobs.count'.tr(
              args: [jobsProvider.recommendedJobs.length.toString()],
            );
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: context.spacing.md),
              child: Text(
                'jobs.near_you'.tr(args: [prefix]),
                style: context.text.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          if (jobsProvider.recommendedJobs.isEmpty) {
            if (jobsProvider.isLoadingRecommended) {
              return const JobItemShimmer();
            }
            return Padding(
              padding: EdgeInsets.only(
                top: context.spacing.lg,
                left: context.spacing.md,
                right: context.spacing.md,
              ),
              child: Text(
                jobsProvider.lastError?.message ??
                    'jobs.empty.recommended'.tr(),
                style: context.text.bodyMedium,
              ),
            );
          }

          return buildJobTile(jobsProvider.recommendedJobs[index - 1]);
        },
      );
    }

    return DefaultTabController(
      length: 2,
      child: RefreshIndicator(
        onRefresh: _refreshVerificationStatus,
        notificationPredicate: (notification) => notification.depth == 0,
        child: NestedScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          headerSliverBuilder: (context, innerScrolled) => [
            SliverPersistentHeader(
              pinned: true,
              delegate: _FixedHeaderDelegate(
                minExtent:
                    kToolbarHeight +
                    MediaQuery.of(context).viewPadding.top +
                    spacing.xs,
                maxExtent:
                    kToolbarHeight +
                    MediaQuery.of(context).viewPadding.top +
                    spacing.xs,
                builder: (ctx, shrink) => _buildTopHeader(ctx),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  if (!_isProfileCompleted || _verificationStatus.isEmpty)
                    IncompleteCard(() {
                      _openProfileFlow(title: 'profile.complete.title'.tr());
                    }),
                  if (_isProfileCompleted && _verificationStatus == 'pending')
                    PendingCard(),
                  if (_isProfileCompleted && _verificationStatus == 'rejected')
                    RejectedCard(() {
                      _openProfileFlow(title: 'profile.resubmit.title'.tr());
                    }),
                  if (storiesProvider.isLoadingEmployee ||
                      storiesProvider.employeeStories.isNotEmpty)
                    Container(
                      width: double.infinity,
                      color: context.xcolors.gradientStart,
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing.md,
                        vertical: spacing.md,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'jobs.stories.title'.tr(),
                            style: context.text.titleMedium,
                          ),
                          SizedBox(height: spacing.sm),
                          SizedBox(
                            height: 90,
                            child: storiesProvider.isLoadingEmployee
                                ? Center(
                                    child: AppLoadingIndicator.inline(
                                      size: 18,
                                      strokeWidth: 2,
                                      color: colors.primary,
                                    ),
                                  )
                                : ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        storiesProvider.employeeStories.length,
                                    itemBuilder: (context, index) {
                                      final story = storiesProvider
                                          .employeeStories[index];
                                      final title =
                                          (isHindi
                                                  ? story.titleHindi
                                                  : story.titleEnglish)
                                              .trim();

                                      return Padding(
                                        padding: EdgeInsets.only(
                                          left: index == 0 ? 0 : spacing.xs,
                                          right: spacing.xs,
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            final id = _employeeId;
                                            if (id == null || id <= 0) return;

                                            final storyIds = storiesProvider
                                                .employeeStories
                                                .map((s) => s.id)
                                                .toList();

                                            final items = storiesProvider
                                                .employeeStories
                                                .map(
                                                  (s) => StoryItemModel(
                                                    imageUrl: s.image,
                                                    title:
                                                        (isHindi
                                                                ? s.titleHindi
                                                                : s.titleEnglish)
                                                            .trim(),
                                                    description:
                                                        (isHindi
                                                                ? s.descriptionHindi
                                                                : s.descriptionEnglish)
                                                            .trim(),
                                                    duration: const Duration(
                                                      seconds: 6,
                                                    ),
                                                  ),
                                                )
                                                .toList();

                                            if (items.isEmpty) return;

                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                fullscreenDialog: true,
                                                builder: (_) => StoryViewer(
                                                  stories: items,
                                                  initialIndex: index,
                                                  onIndexChanged: (i) {
                                                    if (i < 0 ||
                                                        i >= storyIds.length) {
                                                      return;
                                                    }

                                                    storiesProvider.markRead(
                                                      employeeId: id,
                                                      storyId: storyIds[i],
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                          child: StoryItem(
                                            title: title.isEmpty ? '—' : title,
                                            imageUrl: story.image,
                                            isRead: story.isRead,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyHeaderDelegate(
                minExtent: 40 + 8 + 48 + 16,
                maxExtent: 40 + 8 + 48 + 16,
                builder: (ctx, shrink) => Container(
                  color: colors.onPrimary,
                  padding: EdgeInsets.only(
                    left: spacing.md,
                    right: spacing.md,
                    top: spacing.sm,
                    bottom: spacing.xs,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: LabeledFormField(
                              title: '',
                              hintText: 'jobs.search.hint'.tr(),
                              prefixIcon: XIcon(AppIcon.search),
                              controller: _searchController,
                              textInputAction: TextInputAction.search,
                              onChanged: (_) {
                                _searchDebounce?.cancel();
                                _searchDebounce = Timer(
                                  const Duration(milliseconds: 600),
                                  () {
                                    if (_tabController.index == 1) {
                                      _fetchRecommendedJobs();
                                    } else {
                                      _fetchAllJobs();
                                    }
                                  },
                                );
                              },
                              onFieldSubmitted: (_) {
                                _searchDebounce?.cancel();
                                if (_tabController.index == 1) {
                                  _fetchRecommendedJobs();
                                } else {
                                  _fetchAllJobs();
                                }
                              },
                            ),
                          ),
                          SizedBox(width: spacing.md),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: hasAppliedFilters
                                  ? colors.primary
                                  : null,
                              fixedSize: const Size.fromHeight(48),
                              side: BorderSide(color: colors.primary),
                              padding: EdgeInsets.symmetric(
                                horizontal: spacing.md,
                              ),
                            ),
                            onPressed: () async {
                              final sections = await _loadFilterSections(
                                isHindi: context
                                    .read<LanguageProvider>()
                                    .isHindi,
                                force: true,
                              );

                              final result = await showAdvancedFilterSheet(
                                context,
                                sections: sections,
                                initial: _selectedFilters,
                              );

                              if (result != null) {
                                setState(() {
                                  _selectedFilters = result;
                                });
                                await _persistSelectedFilters();
                                if (_tabController.index == 1) {
                                  await _fetchRecommendedJobs();
                                } else {
                                  await _fetchAllJobs();
                                }
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                XIcon(
                                  AppIcon.filter,
                                  color: hasAppliedFilters
                                      ? colors.onPrimary
                                      : null,
                                ),
                                SizedBox(width: spacing.xs),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 160,
                                  ),
                                  child: Text(
                                    _filterButtonLabel(context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.text.bodySmall?.copyWith(
                                      color: hasAppliedFilters
                                          ? colors.onPrimary
                                          : colors.onPrimaryContainer,
                                      fontWeight: hasAppliedFilters
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: spacing.xs),
                      TabBar(
                        controller: _tabController,
                        labelColor: colors.onBackground,
                        labelStyle: context.text.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: context.text.bodyMedium!
                            .copyWith(fontWeight: FontWeight.w500),
                        unselectedLabelColor: colors.onSurface,
                        dividerColor: Colors.transparent,
                        indicatorColor: colors.primary,
                        indicatorWeight: 2,
                        tabs: [
                          Tab(text: 'jobs.tabs.all'.tr()),
                          Tab(text: 'jobs.tabs.recommended'.tr()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
              controller: _tabController,
              children: [
                RefreshIndicator(
                  onRefresh: _refreshVerificationStatus,
                  child: buildAllJobsList(),
                ),
                RefreshIndicator(
                  onRefresh: _refreshVerificationStatus,
                  child: showRecommendedTab
                      ? buildRecommendedJobsList()
                      : Center(
                          child: Padding(
                            padding: EdgeInsets.all(
                              context.spacing.lg,
                            ),
                            child: Text(
                              'jobs.empty.complete_profile'.tr(),
                              textAlign: TextAlign.center,
                              style: context.text.bodyMedium?.copyWith(
                                color: context.colors.onSurface,
                              ),
                            ),
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

class _FixedHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  final double minExtent;
  @override
  final double maxExtent;
  final Widget Function(BuildContext context, double shrinkOffset) builder;

  _FixedHeaderDelegate({
    required this.minExtent,
    required this.maxExtent,
    required this.builder,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return builder(context, shrinkOffset);
  }

  @override
  bool shouldRebuild(covariant _FixedHeaderDelegate oldDelegate) =>
      minExtent != oldDelegate.minExtent ||
      maxExtent != oldDelegate.maxExtent ||
      builder != oldDelegate.builder;

  @override
  OverScrollHeaderStretchConfiguration? get stretchConfiguration => null;
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  final double minExtent;
  @override
  final double maxExtent;
  final Widget Function(BuildContext context, double shrinkOffset) builder;

  _StickyHeaderDelegate({
    required this.minExtent,
    required this.maxExtent,
    required this.builder,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Colors.transparent,
      child: builder(context, shrinkOffset),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) =>
      minExtent != oldDelegate.minExtent ||
      maxExtent != oldDelegate.maxExtent ||
      builder != oldDelegate.builder;
}

class _JobsPageShimmer extends StatelessWidget {
  const _JobsPageShimmer();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: AppShimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    spacing.md,
                    spacing.md,
                    spacing.md,
                    0,
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colors.onPrimary,
                      borderRadius: BorderRadius.circular(context.radii.md),
                    ),
                    padding: EdgeInsets.all(spacing.md),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppShimmerBox(height: 14, width: 180),
                        SizedBox(height: 10),
                        AppShimmerBox(height: 12, width: 240),
                        SizedBox(height: 16),
                        AppShimmerBox(height: 40, width: 120),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  color: context.xcolors.gradientStart,
                  margin: EdgeInsets.only(top: spacing.md),
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.md,
                    vertical: spacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppShimmerBox(height: 16, width: 90),
                      SizedBox(height: spacing.sm),
                      SizedBox(
                        height: 90,
                        child: Row(
                          children: List.generate(
                            4,
                            (index) => Padding(
                              padding: EdgeInsets.only(right: spacing.xs),
                              child: const Column(
                                children: [
                                  AppShimmerBox(
                                    width: 58,
                                    height: 58,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(29),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  AppShimmerBox(height: 10, width: 56),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: colors.onPrimary,
                  padding: EdgeInsets.only(
                    left: spacing.md,
                    right: spacing.md,
                    top: spacing.sm,
                    bottom: spacing.xs,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(
                                  context.radii.sm,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: spacing.md),
                          const AppShimmerBox(height: 40, width: 96),
                        ],
                      ),
                      SizedBox(height: spacing.sm),
                      const Row(
                        children: [
                          Expanded(child: AppShimmerBox(height: 16)),
                          SizedBox(width: 24),
                          Expanded(child: AppShimmerBox(height: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    spacing.md,
                    spacing.md,
                    spacing.md,
                    spacing.xs,
                  ),
                  child: const AppShimmerBox(height: 14, width: 170),
                ),
              ],
            ),
          ),
        ),
        SliverList.builder(
          itemCount: 6,
          itemBuilder: (context, index) => const JobItemShimmer(),
        ),
        SliverToBoxAdapter(child: SizedBox(height: spacing.lg)),
      ],
    );
  }
}
