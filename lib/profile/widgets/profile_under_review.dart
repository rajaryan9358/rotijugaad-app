


import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class ProfileUnderReview extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 3,
          color: context.xcolors.warning,
        ),
        Container(
          color: context.xcolors.warningBackground,
          padding: EdgeInsets.symmetric(horizontal: context.spacing.md,vertical: context.spacing.md),
          child: Row(
            children: [
              SvgPicture.asset("assets/icons/ic_pending.svg",color: context.xcolors.warning,),
              SizedBox(width: context.spacing.sm,),
              Text("Profile is under review",style: context.text.bodyMedium!.copyWith(
                  color: context.colors.onPrimaryContainer,
                  fontWeight: FontWeight.w500
              ),)
            ],
          ),
        )
      ],
    );
  }
  
}