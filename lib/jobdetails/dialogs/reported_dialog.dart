


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rotijugaad/theme/context_ext.dart';

import '../../common/widgets/xicon.dart';
import '../../theme/app_icons.dart';

class ReportedDialog extends StatefulWidget{
  @override
  State<StatefulWidget> createState() =>_ReportedDialogState();
}

class _ReportedDialogState extends State<ReportedDialog>{
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
              XIcon(AppIcon.success,size: 48,color: context.xcolors.success,),
              SizedBox(height: context.spacing.sm,),
              Text("Reported  Successfully!",style: context.text.bodyMedium!.copyWith(
                  color: context.colors.onPrimaryContainer,
                  fontWeight: FontWeight.w600
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
