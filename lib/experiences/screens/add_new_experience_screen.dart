import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rotijugaad/editprofile/screens/add_experience_screen.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/utils/shared_pref.dart';

import '../../common/widgets/toolbar.dart';

class AddNewExperienceScreen extends StatefulWidget {
  final int? experienceId;

  const AddNewExperienceScreen({super.key, this.experienceId});

  @override
  State<StatefulWidget> createState() => _AddNewExperienceScreenState();
}

class _AddNewExperienceScreenState extends State<AddNewExperienceScreen> {
  int? _employeeId;

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  @override
  void initState() {
    super.initState();
    final profile = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_PROFILE_JSON);
    _employeeId = _asInt(profile?['id'] ?? profile?['employeeId']);
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = _employeeId;
    final isEditing = widget.experienceId != null;

    return Scaffold(
      backgroundColor: context.colors.onPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Toolbar(
              isEditing
                  ? 'profile.flow.edit_experience'.tr()
                  : 'profile.flow.add_experience'.tr(),
              () {
                Navigator.of(context).pop();
              },
            ),
            Divider(color: context.xcolors.stroke),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: context.spacing.md),
                child: employeeId == null
                    ? Center(
                        child: Text(
                          'profile.flow.unable_to_load_employee_details'.tr(),
                          style: context.text.bodyMedium,
                        ),
                      )
                    : AddExperienceScreen(
                        employeeId: employeeId,
                        experienceId: widget.experienceId,
                        showAdd: true,
                        onButtonClicked: () {
                          Navigator.of(context).pop();
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
