import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rotijugaad/editprofile/screens/job_profile_screen.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/utils/shared_pref.dart';

import '../../common/widgets/toolbar.dart';

class UpdatePreferenceScreen extends StatefulWidget {
  const UpdatePreferenceScreen({super.key});

  @override
  State<StatefulWidget> createState() => _UpdatePreferenceScreenState();
}

class _UpdatePreferenceScreenState extends State<UpdatePreferenceScreen> {
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

    return Scaffold(
      backgroundColor: context.colors.onPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Toolbar('profile.actions.update_preferences'.tr(), () {
              Navigator.of(context).pop();
            }),
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
                    : JobProfileScreen(
                        employeeId: employeeId,
                        submitButtonText: 'Save',
                        showBackButtonOnLoading: false,
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
