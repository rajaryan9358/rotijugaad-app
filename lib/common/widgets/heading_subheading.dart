



import 'package:flutter/cupertino.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class HeadingSubheading extends StatelessWidget{
  String heading;
  String subheading;

  HeadingSubheading(this.heading,this.subheading);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(heading,style: context.text.bodyLarge!.copyWith(
          color: context.colors.primary,
          fontSize: 20,
          fontWeight: FontWeight.w600
        ),),
        SizedBox(height: context.spacing.xs,),
        Text(subheading,style: context.text.bodyMedium!.copyWith(
          color: context.colors.onPrimaryContainer
        ),)
      ],
    );
  }

}