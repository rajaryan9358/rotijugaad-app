



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class ProfileReviewDialog extends StatefulWidget{
  @override
  State<StatefulWidget> createState() =>_ProfileReviewDialogState();
}

class _ProfileReviewDialogState extends State<ProfileReviewDialog>{
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colors.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Your profile is under review!",style: context.text.bodyMedium!.copyWith(
                  color: context.colors.onPrimaryContainer,
                  fontWeight: FontWeight.w600
              ),),
              SizedBox(height: context.spacing.sm,),
              Text("You will be notified once approved",textAlign: TextAlign.center,style: context.text.bodySmall!.copyWith(
                  fontWeight: FontWeight.w400
              ),),
              SizedBox(height: context.spacing.md,),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: (){}, child: Text("Done"))),
            ]),
      ),
    );
  }

}