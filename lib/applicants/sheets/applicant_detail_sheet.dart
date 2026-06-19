import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:rotijugaad/applicants/models/applicants_models.dart';
import 'package:rotijugaad/candidatedetail/screens/candidate_detail_screen.dart';
import 'package:rotijugaad/common/widgets/employee_identity_badges.dart';
import 'package:rotijugaad/employerjobs/screens/employer_job_details_screen.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class ApplicantDetailSheet extends StatefulWidget {
  final ApplicantRecord record;

  const ApplicantDetailSheet({super.key, required this.record});

  @override
  State<ApplicantDetailSheet> createState() => _ApplicantDetailSheetState();
}

class _ApplicantDetailSheetState extends State<ApplicantDetailSheet> {
  Future<void> _onReject() async {
    Navigator.of(context).pop({'status': 'rejected'});
  }

  Future<void> _onHire() async {
    Navigator.of(context).pop({'status': 'hired'});
  }

  @override
  Widget build(BuildContext context) {
    final genderAsset = employeeGenderIconAsset(widget.record.employee.gender);
    final employeeId = widget.record.employee.id;
    final jobId = widget.record.jobInterest.jobId ?? widget.record.job.id;

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
            'applicants.details_title'.tr(),
            style: context.text.bodyLarge!.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.onPrimaryContainer,
            ),
          ),
          SizedBox(height: context.spacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.record.employeeName,
                        style: context.text.bodyLarge!.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (genderAsset != null) ...[
                        SizedBox(width: context.spacing.xs),
                        EmployeeGenderIcon(
                          gender: widget.record.employee.gender,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    employeeId == null ? '-' : '#$employeeId',
                    style: context.text.bodyMedium!.copyWith(
                      color: context.colors.secondary,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacing.sm,
                      vertical: 0,
                    ),
                  ),
                  onPressed: (employeeId == null)
                      ? null
                      : () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CandidateDetailScreen(
                                candidateId: employeeId,
                              ),
                            ),
                          );
                        },
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing.md),
          Divider(color: context.xcolors.stroke, height: 1),
          SizedBox(height: context.spacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.record.jobProfileName,
                    style: context.text.bodyLarge!.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (widget.record.organizationName.isNotEmpty)
                    Text(
                      widget.record.organizationName,
                      style: context.text.bodyMedium!.copyWith(
                        color: context.colors.secondary,
                      ),
                    ),
                ],
              ),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacing.sm,
                      vertical: 0,
                    ),
                  ),
                  onPressed: (jobId == null)
                      ? null
                      : () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EmployerJobDetailsScreen(jobId: jobId),
                            ),
                          );
                        },
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing.xl),
          Divider(color: context.xcolors.stroke, height: 4),
          SizedBox(height: context.spacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _onReject,
                  child: const Text('Reject'),
                ),
              ),
              SizedBox(width: context.spacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: _onHire,
                  child: const Text('Hire'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
