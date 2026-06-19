


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class ApplicantFilterChip extends StatelessWidget{
  String filter;
  bool isSelected;
  Function() onFilterSelected;

  ApplicantFilterChip(this.filter, this.isSelected,this.onFilterSelected);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        onFilterSelected();
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected?context.colors.primary:context.colors.onPrimary,
          borderRadius: BorderRadius.all(Radius.circular(context.radii.md)),
          border: Border.all(color: context.colors.primary,width: 1)
        ),
        margin: EdgeInsets.symmetric(horizontal: context.spacing.xs),
        padding: EdgeInsets.symmetric(horizontal: context.spacing.md,vertical: context.spacing.sm),
        child: Text(filter,style: context.text.bodyMedium!.copyWith(
          color: isSelected?context.colors.onPrimary:context.colors.onPrimaryContainer
        ),),
      ),
    );
  }

}