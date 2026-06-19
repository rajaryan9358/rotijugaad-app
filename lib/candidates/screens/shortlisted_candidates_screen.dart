import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rotijugaad/candidatedetail/screens/candidate_detail_screen.dart';
import 'package:rotijugaad/candidates/models/candidate_summary.dart';
import 'package:rotijugaad/candidates/widgets/candidate_item.dart';
import 'package:rotijugaad/common/widgets/app_shimmer_placeholders.dart';
import 'package:rotijugaad/common/widgets/toolbar.dart';
import 'package:rotijugaad/employers/services/employers_service.dart';
import 'package:rotijugaad/profile/utils/employer_profile_action_guard.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/utils/result.dart';
import 'package:rotijugaad/utils/shared_pref.dart';

import '../../candidates/services/candidates_service.dart';

class ShortlistedCandidatesScreen extends StatefulWidget {
  const ShortlistedCandidatesScreen({super.key});

  @override
  State<ShortlistedCandidatesScreen> createState() =>
      _ShortlistedCandidatesScreenState();
}

class _ShortlistedCandidatesScreenState
    extends State<ShortlistedCandidatesScreen> {
  final EmployersService _employersService = EmployersService();
  final CandidatesService _candidatesService = CandidatesService();
  final Set<int> _updatingIds = <int>{};

  bool _isLoading = true;
  String? _errorMessage;
  List<CandidateSummaryDto> _candidates = const [];

  int get _employerId => SharedPrefUtils.readInt('auth_employer_id');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final employerId = _employerId;
    if (employerId <= 0) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'errors.no_employer_id'.tr();
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _employersService.getEmployerShortlistedCandidates(
      employerId,
      page: 1,
      limit: 100,
    );

    switch (result) {
      case Success(value: final response):
        setState(() {
          _candidates = response.candidates;
          _isLoading = false;
        });
        break;
      case Failure(exception: final e):
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
        break;
    }
  }

  Future<void> _toggleShortlist(CandidateSummaryDto candidate) async {
    if (_updatingIds.contains(candidate.id)) return;
    if (!await EmployerProfileActionGuard.ensureAllowed(context)) return;

    setState(() => _updatingIds.add(candidate.id));

    final result = await _candidatesService.toggleEmployerCandidateShortlist(
      employerId: _employerId,
      candidateId: candidate.id,
    );

    if (!mounted) return;

    switch (result) {
      case Success():
        setState(() {
          _candidates = _candidates
              .where((item) => item.id != candidate.id)
              .toList(growable: false);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('candidates.shortlist.removed'.tr())),
        );
        break;
      case Failure(exception: final e):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
        break;
    }

    if (!mounted) return;
    setState(() => _updatingIds.remove(candidate.id));
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = context.locale.languageCode.toLowerCase() == 'hi';

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Toolbar('candidates.shortlist.screen_title'.tr(), () {
              Navigator.of(context).pop();
            }),
            if (_isLoading)
              const Expanded(
                child: AppListShimmer(padding: EdgeInsets.only(top: 12)),
              )
            else if ((_errorMessage ?? '').trim().isNotEmpty)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacing.lg,
                    ),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: context.text.bodyMedium,
                    ),
                  ),
                ),
              )
            else if (_candidates.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'candidates.shortlist.empty'.tr(),
                    style: context.text.bodyMedium,
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _candidates.length,
                    itemBuilder: (context, index) {
                      final candidate = _candidates[index];
                      return InkWell(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CandidateDetailScreen(
                                candidateId: candidate.id,
                              ),
                            ),
                          );
                          if (!mounted) return;
                          await _load();
                        },
                        child: CandidateItem(
                          candidate: candidate,
                          isHindi: isHindi,
                          isShortlistLoading: _updatingIds.contains(
                            candidate.id,
                          ),
                          onShortlistTap: () => _toggleShortlist(candidate),
                        ),
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
