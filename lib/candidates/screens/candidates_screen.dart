import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/candidatedetail/screens/candidate_detail_screen.dart';
import 'package:rotijugaad/candidates/providers/candidates_provider.dart';
import 'package:rotijugaad/candidates/widgets/candidate_item.dart';
import 'package:rotijugaad/candidates/models/candidate_summary.dart';
import 'package:rotijugaad/common/widgets/app_loading_indicator.dart';
import 'package:rotijugaad/common/widgets/app_shimmer_placeholders.dart';
import 'package:rotijugaad/employers/providers/employers_provider.dart';
import 'package:rotijugaad/filters/models/filter_section.dart';
import 'package:rotijugaad/filters/sheets/candidates_filter_sheet.dart';
import 'package:rotijugaad/filters/utils/masters_filter_sections.dart';
import 'package:rotijugaad/jobs/models/story_model.dart';
import 'package:rotijugaad/jobs/screens/help_support_screen.dart';
import 'package:rotijugaad/jobs/screens/notification_screen.dart';
import 'package:rotijugaad/notifications/notification_service.dart';
import 'package:rotijugaad/jobs/screens/story_screen.dart';
import 'package:rotijugaad/jobs/widgets/incomplete_card.dart';
import 'package:rotijugaad/jobs/widgets/pending_card.dart';
import 'package:rotijugaad/jobs/widgets/rejected_card.dart';
import 'package:rotijugaad/jobs/widgets/story_item.dart';
import 'package:rotijugaad/masters/models/misc_dtos.dart';
import 'package:rotijugaad/masters/providers/masters_provider.dart';
import 'package:rotijugaad/profile/utils/employer_profile_action_guard.dart';
import 'package:rotijugaad/profile/utils/profile_status_helper.dart';
import 'package:rotijugaad/profile/utils/session_refresh_helper.dart';
import 'package:rotijugaad/profile/screens/edit_employer_profile_screen.dart';
import 'package:rotijugaad/settings/providers/language_provider.dart';
import 'package:rotijugaad/stories/providers/stories_provider.dart';
import 'package:rotijugaad/theme/app_icons.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/utils/shared_pref.dart';

import '../../common/widgets/labeled_form_field.dart';
import '../../common/widgets/xicon.dart';
import '../../employerjobs/screens/add_job_screen.dart';

class CandidatesScreen extends StatefulWidget {
  const CandidatesScreen({super.key});

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen>
    with TickerProviderStateMixin {
  static const String _filtersStorageKey =
      SharedPrefUtils.CANDIDATES_FILTERS_JSON;

  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  EmployersProvider? _employersProvider;

  bool _bootstrapped = false;
  bool _initialCandidatesLoadDone = false;
  bool _employerStoriesFetched = false;
  String _salaryType = 'month';
  bool? _filterSectionsIsHindi;
  bool _isLoadingFilterSections = false;
  List<FilterSection> _filterSections = const [];

  Map<String, Set<String>> _selectedFilters = const {};
  bool _isFirstVisit = false;

  Map<String, dynamic>? get _authUserJson =>
      SharedPrefUtils.readJson(SharedPrefUtils.AUTH_USER_JSON);

  Map<String, dynamic>? get _authProfileJson =>
      SharedPrefUtils.readJson(SharedPrefUtils.AUTH_PROFILE_JSON);

  bool get _isProfileCompleted =>
      SharedPrefUtils.readBool(SharedPrefUtils.AUTH_PROFILE_COMPLETED);

  bool get _effectiveProfileCompleted => ProfileStatusHelper.isProfileCompleted(
    user: _authUserJson,
    profile: _employersProvider?.employerDetail ?? _authProfileJson,
  );

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

  int? get _employerId {
    final providerDetail = _employersProvider?.employerDetail;
    final fromProvider = _asInt(
      providerDetail?['id'] ??
          providerDetail?['employerId'] ??
          providerDetail?['employer_id'] ??
          providerDetail?['employerID'],
    );
    if (fromProvider != null && fromProvider > 0) return fromProvider;

    final profile = _authProfileJson;

    final fromProfile = _asInt(
      profile?['id'] ??
          profile?['employerId'] ??
          profile?['employer_id'] ??
          profile?['employerID'],
    );
    if (fromProfile != null && fromProfile > 0) return fromProfile;

    final nested = profile?['employer'];
    if (nested is Map<String, dynamic>) {
      final fromNested = _asInt(
        nested['id'] ??
            nested['employerId'] ??
            nested['employer_id'] ??
            nested['employerID'],
      );
      if (fromNested != null && fromNested > 0) return fromNested;
    }

    final fromUser = _asInt(
      _authUserJson?['employerId'] ?? _authUserJson?['employer_id'],
    );
    if (fromUser != null && fromUser > 0) return fromUser;

    final stored = SharedPrefUtils.readInt('auth_employer_id');
    if (stored > 0) return stored;

    return null;
  }

  double? get _employerLat => _asDouble(_authProfileJson?['lat']);

  double? get _employerLng => _asDouble(_authProfileJson?['lng']);

  String get _verificationStatus {
    final providerDetail = _employersProvider?.employerDetail;
    final providerRaw = providerDetail == null
        ? null
        : (providerDetail['verification_status'] ??
                  providerDetail['verificationStatus'])
              ?.toString();
    if (providerRaw != null && providerRaw.trim().isNotEmpty) {
      return providerRaw.trim().toLowerCase();
    }

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
        final height = MediaQuery.of(context).size.height * 0.8;
        return SizedBox(
          height: height,
          child: CandidatesFilterSheet(
            sections: sections,
            initial: initial ?? {},
          ),
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
      final sections = await MastersFilterSections.buildCandidates(
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

  List<int> _parseIntIds(Set<String>? values) {
    final out = <int>[];
    for (final v in values ?? const <String>{}) {
      final n = int.tryParse(v);
      if (n != null && n > 0) out.add(n);
    }
    return out;
  }

  Future<List<Map<String, num?>>> _experienceRangesFromIds(
    MastersProvider masters,
    Set<String>? selectedIds,
  ) async {
    final ids = _parseIntIds(selectedIds);
    if (ids.isEmpty) return const [];

    final list = await masters.getExperiencesFromDb();
    final byId = {for (final e in list) e.id: e};

    final out = <Map<String, num?>>[];
    for (final id in ids) {
      final ExperienceDto? e = byId[id];
      if (e == null) continue;
      out.add({'min': e.expFrom?.toDouble(), 'max': e.expTo?.toDouble()});
    }
    return out;
  }

  Future<List<Map<String, num?>>> _distanceRangesFromIds(
    MastersProvider masters,
    Set<String>? selectedIds,
  ) async {
    final ids = _parseIntIds(selectedIds);
    if (ids.isEmpty) return const [];

    final list = await masters.getDistancesFromDb();
    final byId = {for (final d in list) d.id: d};

    final out = <Map<String, num?>>[];
    for (final id in ids) {
      final d = byId[id];
      final km = d?.distance;
      if (km == null) continue;
      out.add({'min': null, 'max': km});
    }
    return out;
  }

  Future<void> _fetchEmployerStories({bool force = false}) async {
    final employerId = _employerId;
    if (employerId == null || employerId <= 0) {
      debugPrint('[Candidates] Skip employer stories: missing employerId');
      return;
    }

    if (!force && _employerStoriesFetched) return;
    _employerStoriesFetched = true;

    if (!mounted) return;
    debugPrint(
      '[Candidates] Fetch employer stories for employerId=$employerId',
    );
    await context.read<StoriesProvider>().fetchEmployerStories(employerId);
  }

  void _onEmployerChanged() {
    _fetchEmployerStories();
  }

  Future<void> _fetchAllCandidates() async {
    final provider = context.read<CandidatesProvider>();
    final masters = context.read<MastersProvider>();

    final experienceRanges = await _experienceRangesFromIds(
      masters,
      _selectedFilters['experience'],
    );
    final distanceRanges = await _distanceRangesFromIds(
      masters,
      _selectedFilters['distance'],
    );

    final genderSet = _selectedFilters['gender'];
    final gender = (genderSet != null && genderSet.isNotEmpty)
        ? genderSet.first
        : '';

    final verificationSet = _selectedFilters['verification_status'];
    final verificationStatus = (verificationSet != null && verificationSet.isNotEmpty)
        ? verificationSet.first
        : null;

    await provider.fetchAllCandidates(
      employerId: _employerId,
      search: _searchController.text.trim(),
      jobProfileIds: _parseIntIds(_selectedFilters['job_profile']),
      preferredStateIds: _parseIntIds(_selectedFilters['preferred_state']),
      preferredCityIds: _parseIntIds(_selectedFilters['preferred_city']),
      qualificationIds: _parseIntIds(_selectedFilters['qualification']),
      shiftIds: _parseIntIds(_selectedFilters['shift']),
      skillIds: _parseIntIds(_selectedFilters['skill']),
      salaryRangeIds: _parseIntIds(_selectedFilters['salary_range']),
      verificationStatus: verificationStatus,
      experienceRanges: experienceRanges,
      distanceRanges: distanceRanges,
      gender: gender.trim(),
      expectedSalaryFrequency: _salaryType.trim(),
      lat: _employerLat,
      lng: _employerLng,
      page: 1,
      limit: 50,
    );
  }

  Future<void> _fetchRecommendedCandidates() async {
    final provider = context.read<CandidatesProvider>();
    final id = _employerId;
    if (id == null || id <= 0) return;

    final masters = context.read<MastersProvider>();

    final experienceRanges = await _experienceRangesFromIds(
      masters,
      _selectedFilters['experience'],
    );
    final distanceRanges = await _distanceRangesFromIds(
      masters,
      _selectedFilters['distance'],
    );

    final genderSet = _selectedFilters['gender'];
    final gender = (genderSet != null && genderSet.isNotEmpty)
        ? genderSet.first
        : '';

    final verificationSet = _selectedFilters['verification_status'];
    final verificationStatus = (verificationSet != null && verificationSet.isNotEmpty)
        ? verificationSet.first
        : null;

    await provider.fetchRecommendedCandidates(
      employerId: id,
      search: _searchController.text.trim(),
      jobProfileIds: _parseIntIds(_selectedFilters['job_profile']),
      preferredStateIds: _parseIntIds(_selectedFilters['preferred_state']),
      preferredCityIds: _parseIntIds(_selectedFilters['preferred_city']),
      qualificationIds: _parseIntIds(_selectedFilters['qualification']),
      shiftIds: _parseIntIds(_selectedFilters['shift']),
      skillIds: _parseIntIds(_selectedFilters['skill']),
      salaryRangeIds: _parseIntIds(_selectedFilters['salary_range']),
      verificationStatus: verificationStatus,
      experienceRanges: experienceRanges,
      distanceRanges: distanceRanges,
      gender: gender.trim(),
      expectedSalaryFrequency: _salaryType.trim(),
      lat: _employerLat,
      lng: _employerLng,
      page: 1,
      limit: 50,
    );
  }

  Future<void> _refreshCandidatesHome() async {
    await SessionRefreshHelper.refreshCurrentSession(context);

    final futures = <Future<void>>[
      _fetchAllCandidates(),
      _fetchRecommendedCandidates(),
    ];

    final id = _employerId;
    if (id != null && id > 0) {
      futures.addAll([_fetchEmployerStories(force: true)]);
    }

    await Future.wait(futures);
  }

  Future<void> _toggleShortlist(CandidateSummaryDto candidate) async {
    final employerId = _employerId;
    if (employerId == null || employerId <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('errors.no_employer_id'.tr())));
      return;
    }

    if (!await EmployerProfileActionGuard.ensureAllowed(context)) {
      return;
    }

    final ok = await context
        .read<CandidatesProvider>()
        .toggleCandidateShortlist(
          employerId: employerId,
          candidateId: candidate.id,
        );

    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<CandidatesProvider>().lastError?.message ??
                'candidates.shortlist.failed'.tr(),
          ),
        ),
      );
      return;
    }

    final message = candidate.isShortlisted
        ? 'candidates.shortlist.removed'.tr()
        : 'candidates.shortlist.added'.tr();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _bootstrap() async {
    if (_bootstrapped) return;
    _bootstrapped = true;

    if (!mounted) return;

    try {
      final isHindi = context.read<LanguageProvider>().isHindi;
      await _loadFilterSections(isHindi: isHindi);
      if (_tabController.index == 1) {
        await _fetchRecommendedCandidates();
      } else {
        await _fetchAllCandidates();
      }
    } finally {
      if (mounted) {
        setState(() => _initialCandidatesLoadDone = true);
      }
    }
  }

  double _stickyHeaderExtent(BuildContext context) {
    final spacing = context.spacing;

    final padding = spacing.xxs + spacing.xs;
    const rowHeight = kMinInteractiveDimension;
    const tabBarHeight = kTextTabBarHeight;

    return padding +
        rowHeight +
        spacing.xxs +
        rowHeight +
        spacing.xs +
        tabBarHeight;
  }

  @override
  void initState() {
    super.initState();
    NotificationService.init();
    _selectedFilters = _readPersistedFilters();
    _isFirstVisit = !SharedPrefUtils.readBool(SharedPrefUtils.HAS_SEEN_HOME);
    if (_isFirstVisit) SharedPrefUtils.saveBool(SharedPrefUtils.HAS_SEEN_HOME, true);
    _tabController = TabController(length: 2, vsync: this);

    _searchController.addListener(() {
      _searchDebounce?.cancel();
      _searchDebounce = Timer(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        if (_tabController.index == 1) {
          _fetchRecommendedCandidates();
        } else {
          _fetchAllCandidates();
        }
      });
    });

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      if (!mounted) return;
      if (_tabController.index == 1) {
        _fetchRecommendedCandidates();
      } else {
        _fetchAllCandidates();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.refreshUnreadCount();
      _fetchEmployerStories();
      _bootstrap();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final next = context.read<EmployersProvider>();
    if (_employersProvider == next) return;

    _employersProvider?.removeListener(_onEmployerChanged);
    _employersProvider = next;
    _employersProvider?.addListener(_onEmployerChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _employersProvider?.removeListener(_onEmployerChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when employer detail refreshes so verification UI updates.
    context.watch<EmployersProvider>().employerDetail;

    final colors = context.colors;
    final spacing = context.spacing;

    final isHindi = context.watch<LanguageProvider>().isHindi;
    if (_filterSectionsIsHindi != isHindi && !_isLoadingFilterSections) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadFilterSections(isHindi: isHindi, force: true);
        }
      });
    }
    final storiesProvider = context.watch<StoriesProvider>();
    final candidatesProvider = context.watch<CandidatesProvider>();

    final hasError = (candidatesProvider.lastError?.message ?? '')
        .trim()
        .isNotEmpty;
    final isAllTab = _tabController.index == 0;
    final activeIsLoading = isAllTab
        ? candidatesProvider.isLoadingAll
        : candidatesProvider.isLoadingRecommended;
    final activeListEmpty = isAllTab
        ? candidatesProvider.allCandidates.isEmpty
        : candidatesProvider.recommendedCandidates.isEmpty;

    // Apply full-page shimmer only for the very first load.
    // After that (tab/salary/filter changes), shimmer only the list.
    if (!_initialCandidatesLoadDone &&
        activeIsLoading &&
        activeListEmpty &&
        !hasError) {
      return Scaffold(
        backgroundColor: colors.onPrimary,
        body: SafeArea(
          child: AppCandidatesPageShimmer(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.md,
              vertical: spacing.md,
            ),
          ),
        ),
      );
    }

    final effectiveProfileCompleted =
        _effectiveProfileCompleted || _isProfileCompleted;
    final showRecommendedTab = effectiveProfileCompleted;
    final hasAppliedFilters = _appliedFilterCount > 0;

    final stickyExtent = _stickyHeaderExtent(context);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: spacing.md),
        ),
        onPressed: () async {
          if (!await EmployerProfileActionGuard.ensureAllowed(
            context,
            blockPending: false,
          )) {
            return;
          }
          if (!context.mounted) return;
          if (!await EmployerProfileActionGuard.ensureHasAdCredit(context)) {
            return;
          }
          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddJobScreen()),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            XIcon(AppIcon.addJob),
            SizedBox(width: spacing.xs),
            Text(
              'candidates.post_ad'.tr(),
              style: context.text.labelMedium!.copyWith(
                color: colors.onPrimary,
              ),
            ),
          ],
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: RefreshIndicator(
          onRefresh: _refreshCandidatesHome,
          notificationPredicate: (notification) => notification.depth == 2,
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
                  builder: (ctx, shrink) => Container(
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
                              valueListenable:
                                  NotificationService.instance.unreadCount,
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
                                            builder: (context) =>
                                                NotificationScreen(),
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
                                          constraints: const BoxConstraints(
                                            minWidth: 18,
                                          ),
                                          decoration: BoxDecoration(
                                            color: context.xcolors.failure,
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Text(
                                            badgeText,
                                            textAlign: TextAlign.center,
                                            style: context.text.bodySmall
                                                ?.copyWith(
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
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    if (!effectiveProfileCompleted ||
                        _verificationStatus.isEmpty)
                      IncompleteCard(() async {
                        final outcome = await Navigator.push<Object?>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditEmployerProfileScreen(
                              goToAddJobAfterVerification: true,
                            ),
                          ),
                        );
                        if (!mounted) return;
                        await handleEditEmployerProfileOutcome(
                          context,
                          outcome,
                        );
                        if (!mounted) return;
                        await _refreshCandidatesHome();
                        if (!mounted) return;
                        setState(() {});
                      }),
                    if (effectiveProfileCompleted &&
                        _verificationStatus == 'pending')
                      PendingCard(),
                    if (effectiveProfileCompleted &&
                        _verificationStatus == 'rejected')
                      RejectedCard(() async {
                        final outcome = await Navigator.push<Object?>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditEmployerProfileScreen(),
                          ),
                        );
                        if (!mounted) return;
                        await handleEditEmployerProfileOutcome(
                          context,
                          outcome,
                        );
                        if (!mounted) return;
                        await _refreshCandidatesHome();
                        if (!mounted) return;
                        setState(() {});
                      }),

                    if (storiesProvider.isLoadingEmployer ||
                        storiesProvider.employerStories.isNotEmpty)
                      Container(
                        width: double.infinity,
                        color: context.xcolors.gradientStart,
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.md,
                          vertical: spacing.xs,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'jobs.stories.title'.tr(),
                              style: context.text.titleMedium,
                            ),
                            SizedBox(height: spacing.xs),
                            SizedBox(
                              height: 108,
                              child: storiesProvider.isLoadingEmployer
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
                                      itemCount: storiesProvider
                                          .employerStories
                                          .length,
                                      itemBuilder: (context, index) {
                                        final story = storiesProvider
                                            .employerStories[index];
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
                                              final employerId = _employerId;
                                              if (employerId == null ||
                                                  employerId <= 0) {
                                                return;
                                              }

                                              final storyIds = storiesProvider
                                                  .employerStories
                                                  .map((s) => s.id)
                                                  .toList();

                                              final items = storiesProvider
                                                  .employerStories
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
                                                          i >=
                                                              storyIds.length) {
                                                        return;
                                                      }

                                                      storiesProvider
                                                          .markEmployerRead(
                                                            employerId:
                                                                employerId,
                                                            storyId:
                                                                storyIds[i],
                                                          );
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                            child: StoryItem(
                                              title: title.isEmpty
                                                  ? '—'
                                                  : title,
                                              imageUrl: story.image,
                                              isRead: story.isRead,
                                              width: 92,
                                              height: 108,
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
                  minExtent: stickyExtent,
                  maxExtent: stickyExtent,
                  builder: (ctx, shrink) => Container(
                    color: colors.onPrimary,
                    padding: EdgeInsets.only(
                      left: spacing.md,
                      right: spacing.md,
                      top: spacing.xxs,
                      bottom: spacing.xxs,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _radio('terms.monthly_staff'.tr(), 'month'),
                            const SizedBox(width: 16),
                            _radio('terms.daily_wage_worker'.tr(), 'day'),
                          ],
                        ),
                        SizedBox(height: spacing.xxs),
                        Row(
                          children: [
                            Expanded(
                              child: LabeledFormField(
                                title: '',
                                hintText: 'candidates.search_job_profile'.tr(),
                                prefixIcon: XIcon(AppIcon.search),
                                controller: _searchController,
                                textInputAction: TextInputAction.search,
                                onFieldSubmitted: (_) {
                                  if (_tabController.index == 1) {
                                    _fetchRecommendedCandidates();
                                  } else {
                                    _fetchAllCandidates();
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
                                    await _fetchRecommendedCandidates();
                                  } else {
                                    await _fetchAllCandidates();
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
                              Tab(text: 'candidates.tabs.all'.tr()),
                              Tab(text: 'candidates.tabs.recommended'.tr()),
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
                  _CandidatesList(
                    isHindi: isHindi,
                    isLoading: candidatesProvider.isLoadingAll,
                    errorMessage: candidatesProvider.lastError?.message,
                    candidates: candidatesProvider.allCandidates,
                    onShortlistToggle: _toggleShortlist,
                  ),
                  showRecommendedTab
                      ? _CandidatesList(
                          isHindi: isHindi,
                          isLoading: candidatesProvider.isLoadingRecommended,
                          errorMessage: candidatesProvider.lastError?.message,
                          candidates: candidatesProvider.recommendedCandidates,
                          onShortlistToggle: _toggleShortlist,
                        )
                      : Center(
                          child: Padding(
                            padding: EdgeInsets.all(spacing.lg),
                            child: Text(
                              'candidates.complete_profile'.tr(),
                              textAlign: TextAlign.center,
                              style: context.text.bodyMedium?.copyWith(
                                color: context.colors.onSurface,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
          ),
        ),
      ),
    );
  }

  Widget _radio(String label, String value) {
    return InkWell(
      onTap: () {
        if (_salaryType == value) return;
        setState(() => _salaryType = value);
        if (_tabController.index == 1) {
          _fetchRecommendedCandidates();
        } else {
          _fetchAllCandidates();
        }
      },
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: _salaryType,
            onChanged: (v) {
              if (v == null) return;
              if (_salaryType == v) return;
              setState(() => _salaryType = v);
              if (_tabController.index == 1) {
                _fetchRecommendedCandidates();
              } else {
                _fetchAllCandidates();
              }
            },
          ),
          Text(label, style: context.text.bodySmall),
        ],
      ),
    );
  }
}

class _CandidatesList extends StatelessWidget {
  final bool isHindi;
  final bool isLoading;
  final String? errorMessage;
  final List<CandidateSummaryDto> candidates;
  final Future<void> Function(CandidateSummaryDto candidate) onShortlistToggle;

  const _CandidatesList({
    required this.isHindi,
    required this.isLoading,
    required this.errorMessage,
    required this.candidates,
    required this.onShortlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Rebuild when employer detail refreshes so verification UI updates.
    context.watch<EmployersProvider>().employerDetail;

    final spacing = context.spacing;

    if (isLoading) {
      return const AppListShimmer(padding: EdgeInsets.only(top: 12));
    }

    if (errorMessage != null && errorMessage!.trim().isNotEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: spacing.md),
        children: [
          SizedBox(height: spacing.lg),
          Center(
            child: Text(
              errorMessage!.trim(),
              style: context.text.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    if (candidates.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: spacing.md),
        children: [
          SizedBox(height: spacing.lg),
          Center(
            child: Text(
              'candidates.empty'.tr(),
              style: context.text.bodyMedium,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: spacing.md),
      itemCount: candidates.length,
      itemBuilder: (context, index) {
        final c = candidates[index];
        return InkWell(
          onTap: () async {
            if (!await EmployerProfileActionGuard.ensureAllowed(context, blockPending: false)) {
              return;
            }
            if (!context.mounted) return;
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CandidateDetailScreen(candidateId: c.id),
              ),
            );
            if (!context.mounted) return;
            final state = context
                .findAncestorStateOfType<_CandidatesScreenState>();
            await state?._refreshCandidatesHome();
          },
          child: CandidateItem(
            candidate: c,
            isHindi: isHindi,
            isShortlistLoading: context
                .watch<CandidatesProvider>()
                .isShortlistUpdating(c.id),
            onShortlistTap: () => onShortlistToggle(c),
          ),
        );
      },
    );
  }
}

class _FixedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minExtent;
  final double maxExtent;
  final Widget Function(BuildContext, double) builder;

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
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minExtent;
  final double maxExtent;
  final Widget Function(BuildContext, double) builder;

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
    return builder(context, shrinkOffset);
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) =>
      minExtent != oldDelegate.minExtent ||
      maxExtent != oldDelegate.maxExtent ||
      builder != oldDelegate.builder;
}
