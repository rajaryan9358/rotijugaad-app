import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rotijugaad/theme/context_ext.dart';

import '../../common/widgets/otp_field.dart';

class VerifyHireOtpDialog extends StatefulWidget {
  const VerifyHireOtpDialog({super.key});

  @override
  State<StatefulWidget> createState() => _VerifyHireOtpDialogState();
}

class _VerifyHireOtpDialogState extends State<VerifyHireOtpDialog> {
  String _otp = '';

  bool get _isValidOtp => RegExp(r'^\d{4}$').hasMatch(_otp.trim());

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colors.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'The OTP can be found in my application section of the applicant',
              style: context.text.bodyMedium!.copyWith(
                color: context.colors.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacing.md),
            OtpField(
              length: 4,
              validator: (_) {
                return null;
              },
              onChanged: (otp) {
                setState(() {
                  _otp = otp.trim();
                });
              },
              onCompleted: (otp) {
                setState(() {
                  _otp = (otp ?? '').trim();
                });
                return null;
              },
            ),
            SizedBox(height: context.spacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(elevation: 0),
                onPressed: () {
                  final otp = _otp.trim();
                  if (!RegExp(r'^\d{4}$').hasMatch(otp)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid 4-digit OTP'),
                      ),
                    );
                    return;
                  }
                  Navigator.of(context).pop(otp);
                },
                child: Text(_isValidOtp ? 'Verify' : 'Enter 4-digit OTP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
