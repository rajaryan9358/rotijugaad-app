import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/common/dialogs/primary_dialog.dart';
import 'package:rotijugaad/theme/context_ext.dart';

import '../../employees/providers/employees_provider.dart';
import '../../employees/services/employees_service.dart';
import '../../employers/providers/employers_provider.dart';
import '../../employers/services/employers_service.dart';
import '../../common/widgets/app_button_child.dart';
import '../../common/widgets/labeled_form_field.dart';
import '../../common/widgets/otp_field.dart';
import '../../utils/custom_exception.dart';
import '../../utils/result.dart';
import '../../utils/shared_pref.dart';

class ChangeMobileSheet extends StatefulWidget {
  const ChangeMobileSheet({super.key});

  @override
  State<StatefulWidget> createState() => _ChangeMobileSheet();
}

class _ChangeMobileSheet extends State<ChangeMobileSheet> {
  final TextEditingController _mobileController = TextEditingController();
  final FocusNode _mobileFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode();

  bool _otpStep = false;
  bool _isSubmitting = false;
  String _otp = '';
  Timer? _timer;
  int _secondsLeft = 0;

  Map<String, dynamic>? get _authUserJson =>
      SharedPrefUtils.readJson(SharedPrefUtils.AUTH_USER_JSON);

  Map<String, dynamic>? get _authProfileJson =>
      SharedPrefUtils.readJson(SharedPrefUtils.AUTH_PROFILE_JSON);

  String get _profileType {
    final explicit = SharedPrefUtils.readStr(
      SharedPrefUtils.AUTH_PROFILE_TYPE,
    ).trim().toLowerCase();
    if (explicit == 'employee' || explicit == 'employer') return explicit;

    final stored = SharedPrefUtils.readStr(
      SharedPrefUtils.USER_TYPE,
    ).trim().toLowerCase();
    if (stored == 'employee' || stored == 'employer') return stored;

    final fromUser = _authUserJson?['user_type']
        ?.toString()
        .trim()
        .toLowerCase();
    if (fromUser == 'employee' || fromUser == 'employer') return fromUser!;

    return 'employee';
  }

  int? get _profileId {
    final raw =
        _authProfileJson?['id'] ??
        _authProfileJson?['employee_id'] ??
        _authProfileJson?['employer_id'];
    final id = int.tryParse(raw?.toString() ?? '');
    return (id != null && id > 0) ? id : null;
  }

  Future<void> _showError(CustomException e) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => PrimaryDialog(e.message),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mobileController.dispose();
    _mobileFocusNode.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  String _timerLabel(int secondsLeft) {
    final s = secondsLeft.clamp(0, 59);
    return '00:${s.toString().padLeft(2, '0')}s';
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  Widget _buildResendSection() {
    if (_secondsLeft > 0) {
      return Text(
        'profile.change_mobile.resend_in'.tr(args: [_timerLabel(_secondsLeft)]),
        style: context.text.bodyLarge,
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _isSubmitting ? null : _requestOtp,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.spacing.md,
            vertical: context.spacing.sm,
          ),
          child: Text(
            'common.send_otp'.tr(),
            style: context.text.bodyLarge!.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _requestOtp() async {
    final mobile = _mobileController.text.trim();
    if (mobile.length != 10) return;

    final id = _profileId;
    if (id == null) {
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => PrimaryDialog('Something went wrong'),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final result = _profileType == 'employer'
        ? await EmployersService().sendMobileChangeOtp(
            employerId: id,
            mobile: mobile,
          )
        : await EmployeesService().sendMobileChangeOtp(
            employeeId: id,
            mobile: mobile,
          );

    if (!mounted) return;

    switch (result) {
      case Success():
        setState(() {
          _otpStep = true;
          _otp = '';
          _isSubmitting = false;
        });
        _startTimer();
        _otpFocusNode.requestFocus();
        break;
      case Failure(exception: final e):
        setState(() => _isSubmitting = false);
        await _showError(e);
        break;
    }
  }

  Future<void> _verifyOtp() async {
    if (_otp.trim().length != 4) return;

    final id = _profileId;
    if (id == null) {
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => PrimaryDialog('Something went wrong'),
      );
      return;
    }

    final mobile = _mobileController.text.trim();
    if (mobile.length != 10) return;

    setState(() => _isSubmitting = true);

    final result = _profileType == 'employer'
        ? await EmployersService().verifyMobileChangeOtp(
            employerId: id,
            mobile: mobile,
            otp: _otp.trim(),
          )
        : await EmployeesService().verifyMobileChangeOtp(
            employeeId: id,
            mobile: mobile,
            otp: _otp.trim(),
          );

    if (!mounted) return;

    switch (result) {
      case Success():
        final userJson = _authUserJson;
        if (userJson != null) {
          userJson['mobile'] = mobile;
          await SharedPrefUtils.saveJson(
            SharedPrefUtils.AUTH_USER_JSON,
            userJson,
          );
        }

        if (_profileType == 'employer') {
          await context.read<EmployersProvider>().refreshEmployerDetail(id);
        } else {
          await context.read<EmployeesProvider>().refreshEmployeeDetail(id);
        }

        if (!mounted) return;
        Navigator.of(context).pop(true);
        break;
      case Failure(exception: final e):
        setState(() => _isSubmitting = false);
        await _showError(e);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                onTap: _isSubmitting
                    ? null
                    : () {
                        Navigator.of(context).pop();
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
                'profile.actions.change_mobile'.tr(),
                style: context.text.titleMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing.sm),
          if (!_otpStep)
            LabeledFormField(
              title: 'auth.signin.mobile_title'.tr(),
              hintText: 'auth.signin.mobile_hint'.tr(),
              keyboardType: TextInputType.phone,
              controller: _mobileController,
              focusNode: _mobileFocusNode,
              enabled: !_isSubmitting,
              maxLength: 10,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              onChanged: (value) {
                if (value.length == 10) {
                  _mobileFocusNode.unfocus();
                }
              },
            ),
          if (_otpStep) ...[
            Text(
              'profile.change_mobile.otp_sent_to'.tr(
                args: [_mobileController.text.trim()],
              ),
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
          ],
          SizedBox(height: context.spacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : _otpStep
                  ? _verifyOtp
                  : _requestOtp,
              child: AppButtonChild(
                label: _otpStep
                    ? 'common.verify_otp'.tr()
                    : 'common.request_otp'.tr(),
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
