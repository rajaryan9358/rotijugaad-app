import 'dart:async';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/employers/providers/employers_provider.dart';
import 'package:rotijugaad/theme/context_ext.dart';

import '../../common/widgets/clickable_text.dart';
import '../../common/widgets/app_button_child.dart';
import '../../common/widgets/labeled_form_field.dart';
import '../../common/widgets/otp_field.dart';

class EmployerVerifyAadharSheet extends StatefulWidget {
  final int employerId;

  const EmployerVerifyAadharSheet({super.key, required this.employerId});

  @override
  State<StatefulWidget> createState() => _EmployerVerifyAadharSheetState();
}

class _EmployerVerifyAadharSheetState
    extends State<EmployerVerifyAadharSheet> {
  final TextEditingController _aadhaarController = TextEditingController();
  String _otp = '';

  bool _otpStep = false;
  bool _isSubmitting = false;

  Timer? _timer;
  int _secondsLeft = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _aadhaarController.dispose();
    super.dispose();
  }

  String _timerLabel(int secondsLeft) {
    final s = secondsLeft.clamp(0, 59);
    return '00:${s.toString().padLeft(2, '0')}s';
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 45);
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

  void _popWithError(String message) {
    Navigator.of(context).pop({'ok': false, 'message': message});
  }

  Future<void> _requestOtp() async {
    final a = _aadhaarController.text.trim().replaceAll(' ', '');
    if (a.length < 12) {
      _popWithError('verify.aadhaar.invalid'.tr());
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final ok = await context.read<EmployersProvider>().sendAadhaarOtp(
        employerId: widget.employerId,
        aadhaarNumber: a,
      );

      if (!mounted) return;

      if (!ok) {
        final msg =
            context.read<EmployersProvider>().lastError?.message ??
            'common.failed_to_request_otp'.tr();
        _popWithError(msg);
        return;
      }

      setState(() {
        _otpStep = true;
        _otp = '';
      });
      _startTimer();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _verifyOtp() async {
    final a = _aadhaarController.text.trim().replaceAll(' ', '');
    if (a.length < 12) {
      _popWithError('verify.aadhaar.invalid'.tr());
      return;
    }

    final otp = _otp.trim();
    if (otp.length < 6) {
      _popWithError('common.please_enter_otp'.tr());
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final ok = await context.read<EmployersProvider>().verifyAadhaarOtp(
        employerId: widget.employerId,
        aadhaarNumber: a,
        otp: otp,
      );

      if (!mounted) return;

      if (!ok) {
        final msg =
            context.read<EmployersProvider>().lastError?.message ??
            'common.failed_to_verify_otp'.tr();
        _popWithError(msg);
        return;
      }

      Navigator.of(context).pop({'ok': true});
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canResend = _secondsLeft == 0 && !_isSubmitting;

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
                    : () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.arrow_back_rounded,
                  size: context.spacing.xxl,
                  color: context.colors.onPrimaryContainer,
                ),
              ),
              Text(
                'verify.identity.title'.tr(),
                style: context.text.titleMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing.sm),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: !_otpStep
                ? LabeledFormField(
                    key: const ValueKey('aadhaar'),
                    title: 'verify.aadhaar.title'.tr(),
                    hintText: 'verify.aadhaar.hint'.tr(),
                    keyboardType: TextInputType.number,
                    controller: _aadhaarController,
                    maxLength: 12,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
                    ],
                  )
                : Column(
                    key: const ValueKey('otp'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'verify.otp.sent_to_registered'.tr(),
                        style: context.text.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.primary,
                        ),
                      ),
                      SizedBox(height: context.spacing.sm),
                      OtpField(
                        validator: (otp) => null,
                        length: 6,
                        onCompleted: (otp) {
                          setState(() => _otp = otp ?? '');
                          return null;
                        },
                      ),
                      SizedBox(height: context.spacing.sm),
                      ClickableText(
                        _timerLabel(_secondsLeft),
                        'common.resend_otp'.tr(),
                        canResend ? _requestOtp : () {},
                        fontSize: context.spacing.md,
                      ),
                    ],
                  ),
          ),
          SizedBox(height: context.spacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      if (!_otpStep) {
                        await _requestOtp();
                      } else {
                        await _verifyOtp();
                      }
                    },
              child: AppButtonChild(
                label: !_otpStep
                    ? 'common.request_otp'.tr()
                    : 'common.verify_otp'.tr(),
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
