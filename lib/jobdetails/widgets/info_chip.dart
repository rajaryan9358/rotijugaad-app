


import 'package:flutter/cupertino.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class InfoChip extends StatelessWidget{
  String text;

  InfoChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.tertiary,
        borderRadius: BorderRadius.all(Radius.circular(context.radii.sm))
      ),
      margin: EdgeInsets.symmetric(horizontal: context.spacing.xs,vertical: context.spacing.xs),
      padding: EdgeInsets.symmetric(horizontal: context.spacing.sm,vertical: context.spacing.sm),
      child: Text(text,style: context.text.bodySmall!.copyWith(
        color: context.colors.onPrimaryContainer
      ),),
    );
  }
}