import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rotijugaad/jobs/models/job_dto.dart';
import 'package:rotijugaad/jobs/widgets/job_item.dart';
import 'package:rotijugaad/jobs/widgets/job_item_shimmer.dart';
import 'package:rotijugaad/theme/context_ext.dart';

import '../../jobdetails/screens/job_details_screen.dart';
import '../../utils/custom_exception.dart';
import '../../utils/result.dart';
import '../../utils/shared_pref.dart';
import '../models/wishlist_response.dart';
import '../services/wishlist_service.dart';

class WishlistScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistService _service = WishlistService();

  bool _loading = true;
  String? _error;
  int? _employeeId;
  List<JobDto> _jobs = const [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  int? _readEmployeeId() {
    final profile = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_PROFILE_JSON);
    final raw = profile?['id'];
    if (raw is int) return raw;
    return int.tryParse((raw ?? '').toString());
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final employeeId = _readEmployeeId();
    if (employeeId == null || employeeId <= 0) {
      setState(() {
        _loading = false;
        _error = 'errors.no_employee_id'.tr();
        _jobs = const [];
      });
      return;
    }

    _employeeId = employeeId;

    final result = await _service.getEmployeeWishlist(employeeId);
    if (!mounted) return;

    if (result is Success<WishlistResponse, CustomException>) {
      setState(() {
        _loading = false;
        _jobs = result.value.jobs;
      });
      return;
    }

    if (result is Failure<WishlistResponse, CustomException>) {
      setState(() {
        _loading = false;
        _error = result.exception.message;
        _jobs = const [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_loading) {
      content = ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: 6,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) => const JobItemShimmer(),
      );
    } else if (_error != null) {
      content = ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(context.spacing.md),
                child: Text(
                  _error ?? 'wishlist.failed_to_load'.tr(),
                  style: context.text.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      );
    } else if (_jobs.isEmpty) {
      content = ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Text(
                'wishlist.empty'.tr(),
                style: context.text.bodyMedium,
              ),
            ),
          ),
        ],
      );
    } else {
      content = ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _jobs.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final job = _jobs[index];
          return InkWell(
            onTap: () {
              final employeeId = _employeeId;
              if (employeeId == null || employeeId <= 0) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      JobDetailsScreen(jobId: job.id, employeeId: employeeId),
                ),
              );
            },
            child: JobItem(job: job),
          );
        },
      );
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: context.colors.onPrimary,
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).viewPadding.top,
              left: context.spacing.md,
              right: context.spacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: context.spacing.sm),
                Text(
                  'nav.wishlist'.tr(),
                  style: context.text.titleMedium!.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                SizedBox(height: context.spacing.md),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: context.spacing.xs),
              padding: EdgeInsets.only(top: context.spacing.md),
              child: RefreshIndicator(onRefresh: _fetch, child: content),
            ),
          ),
        ],
      ),
    );
  }
}
