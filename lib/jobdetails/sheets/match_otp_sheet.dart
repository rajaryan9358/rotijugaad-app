import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/theme/context_ext.dart';

import '../providers/job_details_provider.dart';

class MatchOtpSheet extends StatefulWidget {
  final int jobId;
  final int employeeId;

  const MatchOtpSheet({
    super.key,
    required this.jobId,
    required this.employeeId,
  });

  @override
  State<StatefulWidget> createState() => _MatchOtpSheetState();
}

class _MatchOtpSheetState extends State<MatchOtpSheet> {
  void _showSnack(BuildContext context, String message) {
    final t = message.trim();
    if (t.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pop(false);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacing.xs,
                    vertical: context.spacing.sm,
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: context.spacing.xxl,
                    color: context.colors.onPrimaryContainer,
                  ),
                ),
              ),
              Text(
                'For Hiring Match OTP',
                style: context.text.titleMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing.sm),
          Text(
            'By verifying OTP with employer, following things would occur.',
            style: context.text.bodyMedium!.copyWith(
              color: context.colors.primary,
            ),
          ),
          SizedBox(height: context.spacing.md),
          Column(
            children:
                [
                      'Hired employee would no longer be displayed.',
                      'Occupied seat would no longer be displayed.',
                    ]
                    .map(
                      (points) => Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: context.colors.onPrimaryContainer,
                              shape: BoxShape.circle,
                            ),
                            width: 5,
                            height: 5,
                          ),
                          SizedBox(width: context.spacing.sm),
                          Text(
                            points,
                            style: context.text.bodySmall!.copyWith(
                              color: context.colors.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
          ),
          SizedBox(height: context.spacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: provider.isActionLoading
                  ? null
                  : () async {
                      final ok = await provider.unlockApplicationOtp(
                        jobId: widget.jobId,
                        employeeId: widget.employeeId,
                      );

                      if (!context.mounted) return;

                      if (!ok) {
                        _showSnack(
                          context,
                          provider.lastError?.message ??
                              'Failed to unlock OTP.',
                        );
                        return;
                      }

                      Navigator.of(context).pop(true);
                    },
              child: const Text('Click to continue'),
            ),
          ),
          SizedBox(height: context.spacing.md),
        ],
      ),
    );
  }
}
