


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rotijugaad/common/widgets/xicon.dart';
import 'package:rotijugaad/theme/app_icons.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class AddStoryItem extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(context.spacing.sm)),
          border: Border.all(color: context.colors.onSurface,width: 1.5),
          color: Colors.transparent
      ),
      margin: EdgeInsets.symmetric(horizontal: context.spacing.xs),
      padding: EdgeInsets.all(context.spacing.xxs),
      child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(context.radii.sm)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(context.radii.sm)),
              color: context.colors.primary.withValues(alpha: 0.2)
            ),
            width: 72,
            height: 90,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                XIcon(AppIcon.addMore,color: context.colors.primary,),
                SizedBox(height: context.spacing.xs,),
                Text("Add a story",style: context.text.bodySmall!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 10
                ),)
              ],
            ),
          )),
    );
  }
}