import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/common/models/id_name.dart';
import 'package:rotijugaad/common/widgets/app_dropdown.dart';
import 'package:rotijugaad/common/widgets/app_button_child.dart';
import 'package:rotijugaad/common/widgets/app_loading_indicator.dart';
import 'package:rotijugaad/common/widgets/xicon.dart';
import 'package:rotijugaad/masters/providers/masters_provider.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/candidates/services/candidates_service.dart';
import 'package:rotijugaad/utils/shared_pref.dart';
import 'package:rotijugaad/utils/result.dart';
import 'package:intl/intl.dart';

import '../../common/dialogs/primary_dialog.dart';
import '../../theme/app_icons.dart';

class ReportCandidateSheet extends StatefulWidget {
  final int candidateId;
  final bool alreadyReported;
  final String? reportedAt;

  const ReportCandidateSheet({
    super.key,
    required this.candidateId,
    this.alreadyReported = false,
    this.reportedAt,
  });

  @override
  State<StatefulWidget> createState() => _ReportCandidateSheetState();
}

class _ReportCandidateSheetState extends State<ReportCandidateSheet> {
  final TextEditingController _commentController = TextEditingController();
  final CandidatesService _service = CandidatesService();

  String? _selectedReasonId;
  late final Future<List<IdName>> _reasonsFuture;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _reasonsFuture = _loadReasons();
  }

  Future<List<IdName>> _loadReasons() async {
    final masters = context.read<MastersProvider>();
    await masters.loadMasters(force: false);

    final reasons = await masters.getEmployerReportReasonsFromDb();
    reasons.sort((a, b) => (a.sequence ?? 0).compareTo(b.sequence ?? 0));

    return reasons.where((r) => r.id > 0).map((r) {
      final isHindi = context.locale.languageCode.toLowerCase() == 'hi';
      final selected =
          (isHindi ? r.reasonHindi : r.reasonEnglish) ??
          r.reasonEnglish ??
          r.reasonHindi ??
          '';
      return IdName(
        id: r.id.toString(),
        name: selected.trim().isEmpty ? '-' : selected.trim(),
      );
    }).toList();
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
    final reportedAtDate = DateTime.tryParse((widget.reportedAt ?? '').trim());
    final reportedAtText = reportedAtDate == null
        ? '-'
        : DateFormat('d MMM, y').format(reportedAtDate.toLocal());

    if (widget.alreadyReported) {
      return Padding(
        padding: EdgeInsets.only(
          left: context.spacing.lg,
          right: context.spacing.lg,
          top: context.spacing.lg,
          bottom: context.spacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                XIcon(AppIcon.success, color: context.xcolors.success),
                SizedBox(width: context.spacing.sm),
                Expanded(
                  child: Text(
                    'candidates.report.already_reported_on'.tr(
                      args: [reportedAtText],
                    ),
                    style: context.text.bodyMedium!.copyWith(
                      color: context.colors.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: XIcon(AppIcon.clear),
                ),
              ],
            ),
            SizedBox(height: context.spacing.md),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: context.spacing.lg,
        right: context.spacing.lg,
        top: context.spacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + context.spacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'candidates.report.title'.tr(),
            style: context.text.titleMedium!.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.spacing.sm),
          FutureBuilder<List<IdName>>(
            future: _reasonsFuture,
            builder: (context, snap) {
              final isLoadingReasons =
                  snap.connectionState == ConnectionState.waiting;
              final reasons = snap.data ?? const <IdName>[];

              if (isLoadingReasons) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: context.spacing.sm),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: AppLoadingIndicator.inline(
                        size: 22,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                );
              }

              return AppDropdown(
                title: 'candidates.report.reason_title'.tr(),
                hint: 'candidates.report.reason_hint'.tr(),
                valueId: _selectedReasonId,
                enabled: !_isSubmitting,
                items: reasons,
                onChanged: (idName) {
                  setState(() {
                    _selectedReasonId = idName?.id;
                  });
                },
              );
            },
          ),
          SizedBox(height: context.spacing.md),
          Text(
            'candidates.report.description_title'.tr(),
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
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              hintText: 'candidates.report.description_hint'.tr(),
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
                  onPressed: _isSubmitting
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
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          final reasonId = int.tryParse(
                            (_selectedReasonId ?? '').trim(),
                          );

                          if (reasonId == null || reasonId <= 0) {
                            _showSnack(
                              context,
                              'candidates.report.select_reason'.tr(),
                            );
                            return;
                          }

                          final employerId = SharedPrefUtils.readInt(
                            'auth_employer_id',
                          );
                          if (employerId <= 0) {
                            _showSnack(
                              context,
                              'candidates.send_interest.no_employer_id'.tr(),
                            );
                            return;
                          }

                          setState(() {
                            _isSubmitting = true;
                          });

                          final result = await _service.reportCandidate(
                            candidateId: widget.candidateId,
                            employerId: employerId,
                            reasonId: reasonId,
                            description: _commentController.text,
                          );

                          if (!mounted) return;

                          setState(() {
                            _isSubmitting = false;
                          });

                          if (!context.mounted) return;

                          switch (result) {
                            case Success():
                              Navigator.of(context).pop(true);
                              await showDialog<void>(
                                context: context,
                                barrierDismissible: true,
                                builder: (context) => PrimaryDialog(
                                  'candidates.report.success'.tr(),
                                  buttonLabel: 'common.ok'.tr(),
                                ),
                              );
                              break;
                            case Failure(exception: final e):
                              _showSnack(
                                context,
                                e.message.isEmpty
                                    ? 'candidates.report.failed'.tr()
                                    : e.message,
                              );
                              break;
                          }
                        },
                  child: AppButtonChild(
                    isLoading: _isSubmitting,
                    label: 'common.submit'.tr(),
                    loaderColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing.md),
        ],
      ),
    );
  }
}
