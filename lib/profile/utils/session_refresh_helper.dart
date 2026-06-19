import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../employees/providers/employees_provider.dart';
import '../../employers/providers/employers_provider.dart';
import '../../users/services/users_service.dart';
import '../../utils/result.dart';
import '../../utils/shared_pref.dart';
import 'profile_status_helper.dart';

class SessionRefreshHelper {
  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static Future<void> refreshCurrentSession(BuildContext context) async {
    final currentUser = SharedPrefUtils.readJson(
      SharedPrefUtils.AUTH_USER_JSON,
    );
    final userId = _asInt(currentUser?['id'] ?? currentUser?['userId']);

    if (userId != null && userId > 0) {
      final result = await UsersService().getUserById(userId);
      switch (result) {
        case Success(value: final user):
          await SharedPrefUtils.saveJson(
            SharedPrefUtils.AUTH_USER_JSON,
            user.toJson(),
          );
          final type = (user.userType ?? '').trim();
          if (type.isNotEmpty) {
            await SharedPrefUtils.saveStr(SharedPrefUtils.USER_TYPE, type);
          }
          break;
        case Failure():
          break;
      }
    }

    var userType = SharedPrefUtils.readStr(
      SharedPrefUtils.USER_TYPE,
    ).trim().toLowerCase();
    if (userType.isEmpty) {
      userType = SharedPrefUtils.readStr(
        SharedPrefUtils.AUTH_PROFILE_TYPE,
      ).trim().toLowerCase();
    }

    final profileJson = SharedPrefUtils.readJson(
      SharedPrefUtils.AUTH_PROFILE_JSON,
    );
    final profileId = _asInt(
      profileJson?['id'] ??
          profileJson?['employeeId'] ??
          profileJson?['employerId'],
    );

    if (profileId != null && profileId > 0) {
      if (userType == 'employer') {
        await context.read<EmployersProvider>().refreshEmployerDetail(
          profileId,
        );
      } else {
        await context.read<EmployeesProvider>().refreshEmployeeDetail(
          profileId,
        );
      }
    }

    await SharedPrefUtils.saveBool(
      SharedPrefUtils.AUTH_PROFILE_COMPLETED,
      ProfileStatusHelper.isProfileCompleted(
        user: SharedPrefUtils.readJson(SharedPrefUtils.AUTH_USER_JSON),
        profile: SharedPrefUtils.readJson(SharedPrefUtils.AUTH_PROFILE_JSON),
      ),
    );
  }
}
