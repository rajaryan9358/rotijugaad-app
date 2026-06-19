import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rotijugaad/profile/widgets/hired_job_item.dart';
import 'package:rotijugaad/theme/context_ext.dart';

import '../../common/widgets/toolbar.dart';
import '../../common/widgets/app_shimmer_placeholders.dart';
import '../../employees/models/hired_jobs_dtos.dart';
import '../../employees/services/employees_service.dart';
import '../../utils/result.dart';
import '../../utils/shared_pref.dart';

class HiredJobsScreen extends StatefulWidget {
  const HiredJobsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HiredJobsScreenState();
}

class _HiredJobsScreenState extends State<HiredJobsScreen> {
  final _service = EmployeesService();

  bool _isLoading = true;
  String? _error;
  EmployeeHiredJobsPageDto? _page;

  int? get _employeeId {
    final profile = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_PROFILE_JSON);
    final raw =
        profile?['id'] ?? profile?['employee_id'] ?? profile?['user_id'];
    final id = int.tryParse(raw?.toString() ?? '');
    return (id != null && id > 0) ? id : null;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final employeeId = _employeeId;
    if (employeeId == null) {
      setState(() {
        _isLoading = false;
        _error = 'Unable to load employee id';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _service.getHiredJobs(employeeId: employeeId);
    if (!mounted) return;

    switch (result) {
      case Success(value: final data):
        setState(() {
          _isLoading = false;
          _page = data;
        });
        break;
      case Failure(exception: final e):
        setState(() {
          _isLoading = false;
          _error = e.message;
          _page = null;
        });
        break;
    }
  }

  String _formatHiredOn(DateTime? dt) {
    final label = 'profile.flow.hired_on'.tr();
    if (dt == null) return '$label —';
    return '$label ${DateFormat('d MMM, y', context.locale.toString()).format(dt)}';
  }

  String _formatPhone(String? raw) {
    final source = (raw ?? '').trim();
    if (source.isEmpty || source.startsWith('-')) return '—';
    final digits = (raw ?? '').replaceAll(RegExp(r'\D+'), '');
    if (digits.isEmpty) return '—';
    if (digits.length == 10) return '+91 $digits';
    if (digits.length == 12 && digits.startsWith('91')) {
      return '+91 ${digits.substring(2)}';
    }
    return source;
  }

  String _formatLocation(EmployeeHiredJobDto item) {
    final city = item.job.jobCity?.trim();
    final state = item.job.jobState?.trim();
    if ((city ?? '').isEmpty && (state ?? '').isEmpty) return '—';
    if ((city ?? '').isEmpty) return state!;
    if ((state ?? '').isEmpty) return city!;
    return '$city, $state';
  }

  @override
  Widget build(BuildContext context) {
    final results = _page?.results ?? const <EmployeeHiredJobDto>[];

    return Scaffold(
      backgroundColor: context.colors.onPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Toolbar('profile.hired_jobs'.tr(), () {
              Navigator.of(context).pop();
            }),
            Divider(color: context.xcolors.stroke),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.spacing.md),
                child: Builder(
                  builder: (context) {
                    if (_isLoading) {
                      return const AppListShimmer();
                    }

                    if (_error != null) {
                      return Center(
                        child: Text(
                          _error!,
                          style: context.text.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    if (results.isEmpty) {
                      return Center(
                        child: Text(
                          'profile.flow.no_hired_jobs'.tr(),
                          style: context.text.bodyMedium,
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final item = results[index];
                        return InkWell(
                          onTap: null,
                          child: HiredJobItem(
                            title: item.job.jobProfile ?? '—',
                            organization:
                                item.job.organizationName ??
                                item.organizationName ??
                                '—',
                            location: _formatLocation(item),
                            phone: _formatPhone(item.employerPhone),
                            hiredOn: _formatHiredOn(item.hired.hiredAt),
                          ),
                        );
                      },
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
