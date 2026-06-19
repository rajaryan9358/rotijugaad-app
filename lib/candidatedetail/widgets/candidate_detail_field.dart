


import 'package:flutter/cupertino.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class CandidateDetailField extends StatelessWidget{
  String title;
  String value;

  CandidateDetailField(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: context.spacing.xs,),
        Text(title,style: context.text.bodySmall,),
        Text(value,style: context.text.bodyMedium!.copyWith(
          color: context.colors.primary,
          fontWeight: FontWeight.w500
        ),),
        SizedBox(height: context.spacing.sm,),
      ],
    );
  }
}