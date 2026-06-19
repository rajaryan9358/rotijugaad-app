


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class Toolbar extends StatelessWidget{
  String title;
  Function() onBackPressed;

  Toolbar(this.title, this.onBackPressed);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: (){
            onBackPressed();
          },
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.spacing.sm,vertical: context.spacing.sm),
              child: Icon(Icons.arrow_back_rounded,size: context.spacing.xxl,color: context.colors.onPrimaryContainer,)),
        ),
        Text(title,style: context.text.titleMedium!.copyWith(
          fontWeight: FontWeight.w800
        ),)
      ],
    );
  }
}