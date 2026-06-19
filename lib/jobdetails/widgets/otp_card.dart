


import 'package:flutter/cupertino.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class OtpCard extends StatelessWidget{
  String otp;

  OtpCard(this.otp);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: otp.characters.map((otpChar)=> Container(
        decoration: BoxDecoration(
          color: context.colors.primary,
          borderRadius: BorderRadius.circular(context.radii.sm),
        ),
        height: 36,
        width: 36,
        margin: EdgeInsets.symmetric(horizontal: context.spacing.xs),
        child: Center(child: Text(otpChar,style: context.text.bodyMedium!.copyWith(
          color: context.colors.onPrimary,
          fontWeight: FontWeight.w500
        ),)),
      )).toList(),
    );
  }

}