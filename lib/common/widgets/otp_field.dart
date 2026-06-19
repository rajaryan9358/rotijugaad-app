import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class OtpField extends StatefulWidget {
  final String? Function(String?)? validator;
  final String? Function(String?)? onCompleted;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final int length;
  final bool enabled;

  const OtpField({
    super.key,
    required this.validator,
    required this.onCompleted,
    this.onChanged,
    this.focusNode,
    this.length = 5,
    this.enabled = true,
  });

  @override
  State<StatefulWidget> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 48,
      textStyle: TextStyle(
        fontSize: 20,
        color: context.colors.onPrimaryContainer,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.primary),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: context.colors.primary),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return Pinput(
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      length: widget.length,
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      validator: widget.validator,
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      showCursor: true,
      onChanged: widget.onChanged,
      onCompleted: (otp) {
        FocusScope.of(context).unfocus();
        widget.onCompleted?.call(otp);
      },
    );
  }
}
