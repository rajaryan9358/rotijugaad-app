import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/jobs/providers/jobs_provider.dart';
import 'package:rotijugaad/theme/context_ext.dart';

import '../../common/widgets/app_button_child.dart';
import '../../common/widgets/otp_field.dart';

class VerifyInterviewerMobileSheet extends StatefulWidget {
  final int employerId;
  final String interviewerContact;
  final int? initialVerificationId;

  const VerifyInterviewerMobileSheet({
    super.key,
    required this.employerId,
    required this.interviewerContact,
    this.initialVerificationId,
  });

  @override
  State<StatefulWidget> createState() => _VerifyInterviewerMobileSheetState();
}

class _VerifyInterviewerMobileSheetState
    extends State<VerifyInterviewerMobileSheet> {
  String _otp = '';
  int? _verificationId;
  final FocusNode _otpFocusNode = FocusNode();

  bool _isSubmitting = false;

  Timer? _timer;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialVerificationId != null) {
      _verificationId = widget.initialVerificationId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTimer();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendOtp();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _timerLabel(int secondsLeft) {
    final s = secondsLeft.clamp(0, 59);
    return '00:${s.toString().padLeft(2, '0')}s';
  }

  Widget _buildResendSection() {
    if (_secondsLeft > 0) {
      return Text(
        'Send otp in ${_timerLabel(_secondsLeft)}',
        style: context.text.bodyLarge,
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _isSubmitting ? null : _sendOtp,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.spacing.md,
            vertical: context.spacing.sm,
          ),
          child: Text(
            'Send OTP',
            style: context.text.bodyLarge!.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  Future<void> _sendOtp() async {
    final mobile = widget.interviewerContact.trim();
    if (mobile.isEmpty) {
      _snack('Please enter the contact number');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final verificationId = await context
          .read<JobsProvider>()
          .sendInterviewerContactOtp(
            employerId: widget.employerId,
            interviewerContact: mobile,
          );

      if (!mounted) return;

      if (verificationId == null || verificationId <= 0) {
        final msg =
            context.read<JobsProvider>().lastError?.message ??
            'Failed to send OTP';
        _snack(msg);
        return;
      }

      setState(() {
        _verificationId = verificationId;
        _otp = '';
      });
      _startTimer();
    } finally {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otp.trim();
    if (otp.length != 4) {
      _snack('Please enter 4-digit OTP');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final ok = await context.read<JobsProvider>().verifyInterviewerContactOtp(
        employerId: widget.employerId,
        interviewerContact: widget.interviewerContact.trim(),
        otp: otp,
        verificationId: _verificationId,
      );

      if (!mounted) return;

      if (!ok) {
        final msg =
            context.read<JobsProvider>().lastError?.message ??
            'Failed to verify OTP';
        _snack(msg);
        return;
      }

      Navigator.of(context).pop(true);
    } finally {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobile = widget.interviewerContact.trim();

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
              IconButton(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        Navigator.of(context).pop(false);
                      },
                icon: Icon(
                  Icons.arrow_back_rounded,
                  size: context.spacing.xxl,
                  color: context.colors.onPrimaryContainer,
                ),
              ),
              Text(
                'Verify Number',
                style: context.text.titleMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing.sm),
          Text(
            'Enter OTP sent to +91 $mobile',
            style: context.text.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.primary,
            ),
          ),
          SizedBox(height: context.spacing.sm),
          OtpField(
            enabled: !_isSubmitting,
            focusNode: _otpFocusNode,
            length: 4,
            validator: (otp) => null,
            onChanged: (otp) {
              setState(() => _otp = otp);
            },
            onCompleted: (otp) {
              setState(() => _otp = otp ?? '');
              return null;
            },
          ),
          SizedBox(height: context.spacing.sm),
          _buildResendSection(),
          SizedBox(height: context.spacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _verifyOtp,
              child: AppButtonChild(
                label: 'Verify OTP',
                isLoading: _isSubmitting,
              ),
            ),
          ),
          SizedBox(height: context.spacing.md),
        ],
      ),
    );
  }
}
