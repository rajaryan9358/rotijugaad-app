import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/common/dialogs/primary_dialog.dart';
import 'package:rotijugaad/common/models/id_name.dart';
import 'package:rotijugaad/common/widgets/app_dropdown.dart';
import 'package:rotijugaad/common/widgets/app_loading_indicator.dart';
import 'package:rotijugaad/jobdetails/providers/job_details_provider.dart';
import 'package:rotijugaad/masters/providers/masters_provider.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class ReportJobSheet extends StatefulWidget {
  final int jobId;
  final int employeeId;

  const ReportJobSheet({
    super.key,
    required this.jobId,
    required this.employeeId,
  });

  @override
  State<StatefulWidget> createState() => _ReportJobSheetState();
}

class _ReportJobSheetState extends State<ReportJobSheet> {
  final TextEditingController _commentController = TextEditingController();

  String? _selectedReasonId;
  Future<List<IdName>>? _reasonsFuture;
  bool _reasonsFutureStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_reasonsFutureStarted) {
      _reasonsFutureStarted = true;
      _reasonsFuture = _loadReasons();
    }
  }

  Future<List<IdName>> _loadReasons() async {
    debugPrint('[ReportJobSheet] _loadReasons: started');
    try {
      final masters = context.read<MastersProvider>();
      debugPrint('[ReportJobSheet] masters provider obtained');
      final isHindi = context.locale.languageCode == 'hi';
      debugPrint('[ReportJobSheet] isHindi=$isHindi, masters.masters=${masters.masters != null ? "loaded" : "null"}');

      await masters.loadMasters(force: false);
      debugPrint('[ReportJobSheet] after loadMasters: masters.masters=${masters.masters != null ? "loaded" : "null"}, lastError=${masters.lastError?.message}');

      final fromBundle = masters.masters?.employeeReportReasons;
      debugPrint('[ReportJobSheet] in-memory employeeReportReasons count=${fromBundle?.length ?? "null (no bundle)"}');

      List<dynamic> reasons;
      if (fromBundle != null) {
        reasons = fromBundle;
        debugPrint('[ReportJobSheet] using in-memory bundle');
      } else {
        reasons = await masters.getEmployeeReportReasonsFromDb();
        debugPrint('[ReportJobSheet] using DB fallback, count=${reasons.length}');
      }

      reasons = [...reasons]
        ..sort((a, b) => (a.sequence ?? 0).compareTo(b.sequence ?? 0));

      final items = reasons
          .where((r) => r.id > 0)
          .map(
            (r) => IdName(
              id: r.id.toString(),
              name: (() {
                final label =
                    ((isHindi ? r.reasonHindi : r.reasonEnglish) ??
                            r.reasonEnglish ??
                            r.reasonHindi ??
                            '')
                        .toString()
                        .trim();
                return label.isNotEmpty ? label : '-';
              })(),
            ),
          )
          .toList();

      debugPrint('[ReportJobSheet] final items count=${items.length}: ${items.map((e) => e.name).join(', ')}');
      return items;
    } catch (e, st) {
      debugPrint('[ReportJobSheet] ERROR in _loadReasons: $e\n$st');
      return const [];
    }
  }

  void _showSnack(BuildContext context, String message) {
    final t = message.trim();
    if (t.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JobDetailsProvider>();

    return Padding(
      padding: EdgeInsets.only(
        left: context.spacing.lg,
        right: context.spacing.lg,
        top: context.spacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + context.spacing.lg,
      ),
      child: FutureBuilder<List<IdName>>(
        future: _reasonsFuture,
        builder: (context, snap) {
          final isLoadingReasons = _reasonsFuture == null ||
              snap.connectionState == ConnectionState.waiting;
          final reasons = snap.data ?? const <IdName>[];

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'job.report.title'.tr(),
                style: context.text.titleMedium!.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: context.spacing.sm),
              if (isLoadingReasons)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: context.spacing.sm),
                  child: Center(
                    child: AppLoadingIndicator.inline(size: 22, strokeWidth: 2),
                  ),
                )
              else
                AppDropdown(
                  title: 'job.report.reason.title'.tr(),
                  hint: 'job.report.reason.hint'.tr(),
                  valueId: _selectedReasonId,
                  enabled: !provider.isActionLoading,
                  items: reasons,
                  onChanged: (idName) {
                    setState(() {
                      _selectedReasonId = idName?.id;
                    });
                  },
                ),
              SizedBox(height: context.spacing.sm),
              Text(
                'job.report.description.title'.tr(),
                style: context.text.bodyMedium!.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: context.spacing.sm),
              TextFormField(
                controller: _commentController,
                minLines: 4,
                maxLines: 6,
                keyboardType: TextInputType.multiline,
                style: context.text.bodyMedium,
                textInputAction: TextInputAction.newline,
                enabled: !provider.isActionLoading,
                decoration: InputDecoration(
                  hintText: 'job.report.description.hint'.tr(),
                  filled: true,
                  fillColor: context.colors.surface,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: context.spacing.md,
                    vertical: context.spacing.md,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.radii.md),
                    borderSide: BorderSide(color: context.colors.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.radii.md),
                    borderSide: BorderSide(
                      color: context.colors.primary,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
              SizedBox(height: context.spacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: provider.isActionLoading
                          ? null
                          : () {
                              Navigator.of(context).pop(false);
                            },
                      child: Text('common.cancel'.tr()),
                    ),
                  ),
                  SizedBox(width: context.spacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: provider.isActionLoading
                          ? null
                          : () async {
                              final reasonId = int.tryParse(
                                (_selectedReasonId ?? '').trim(),
                              );

                              if (reasonId == null || reasonId <= 0) {
                                _showSnack(
                                  context,
                                  'job.report.reason.required'.tr(),
                                );
                                return;
                              }

                              final ok = await provider.reportJob(
                                jobId: widget.jobId,
                                employeeId: widget.employeeId,
                                reasonId: reasonId,
                                description: _commentController.text,
                              );

                              if (!context.mounted) return;

                              if (!ok) {
                                _showSnack(
                                  context,
                                  provider.lastError?.message ??
                                      'job.report.failed'.tr(),
                                );
                                return;
                              }

                              Navigator.of(context).pop(true);

                              await showDialog<void>(
                                context: context,
                                barrierDismissible: true,
                                builder: (context) => PrimaryDialog(
                                  'job.report.success'.tr(),
                                  buttonLabel: 'common.ok'.tr(),
                                ),
                              );
                            },
                      child: Text('common.submit'.tr()),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.spacing.md),
            ],
          );
        },
      ),
    );
  }
}
