


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class ClickableText extends StatelessWidget{
  String text;
  String button;
  double fontSize;
  Function() onClick;

  ClickableText(this.text, this.button, this.onClick,{this.fontSize=14});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text,style: context.text.bodyLarge,),
        SizedBox(width: context.spacing.xs,),
        GestureDetector(
          onTap: (){
            onClick();
          },
          child: Text(button,style: context.text.bodyMedium!.copyWith(
              color: context.colors.primary,
              fontSize: fontSize,
              fontWeight: FontWeight.w500
          ),),
        )
      ],
    );
  }
  
}