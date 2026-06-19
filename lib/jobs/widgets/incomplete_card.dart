


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class IncompleteCard extends StatelessWidget{
  Function() onCompleteClicked;

  IncompleteCard(this.onCompleteClicked);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 3,
          color: context.xcolors.failure,
        ),
        Container(
          color: context.xcolors.failureBackground,
          padding: EdgeInsets.symmetric(horizontal: context.spacing.md,vertical: context.spacing.sm),
          child: Row(
            children: [
              SvgPicture.asset("assets/icons/ic_incomplete.svg",color: context.xcolors.failure,),
              SizedBox(width: context.spacing.sm,),
              Text("Your profile is incomplete",style: context.text.bodyMedium!.copyWith(
                  color: context.colors.onPrimaryContainer,
                  fontWeight: FontWeight.w500
              ),),
              Spacer(),
              SizedBox(
                height: 32,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.xcolors.failure,
                      padding: EdgeInsets.symmetric(horizontal: context.spacing.sm)
                    ),
                    onPressed: (){
                      onCompleteClicked();
                    }, child: Text("Complete now",style: context.text.bodySmall!.copyWith(
                  color: context.colors.onPrimary
                ),)),
              )
            ],
          ),
        )
      ],
    );
  }
}