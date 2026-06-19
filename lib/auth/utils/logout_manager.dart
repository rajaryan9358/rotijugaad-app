import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/applicants/providers/applicants_provider.dart';
import 'package:rotijugaad/auth/providers/auth_provider.dart';
import 'package:rotijugaad/auth/screens/auth_screen.dart';
import 'package:rotijugaad/auth/screens/signin_screen.dart';
import 'package:rotijugaad/candidates/providers/candidates_provider.dart';
import 'package:rotijugaad/employees/providers/employees_provider.dart';
import 'package:rotijugaad/employers/providers/employers_provider.dart';
import 'package:rotijugaad/jobs/providers/jobs_provider.dart';
import 'package:rotijugaad/masters/providers/masters_provider.dart';
import 'package:rotijugaad/navigation/app_page_route.dart';
import 'package:rotijugaad/settings/providers/app_settings_provider.dart';
import 'package:rotijugaad/settings/providers/language_provider.dart';
import 'package:rotijugaad/stories/providers/stories_provider.dart';
import 'package:rotijugaad/storage/app_database.dart';
import 'package:rotijugaad/utils/shared_pref.dart';

class LogoutManager {
  static Future<void> clearLocalSession(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final language = context.read<LanguageProvider>();
    final settings = context.read<AppSettingsProvider>();
    final masters = context.read<MastersProvider>();
    final employees = context.read<EmployeesProvider>();
    final employers = context.read<EmployersProvider>();
    final stories = context.read<StoriesProvider>();
    final jobs = context.read<JobsProvider>();
    final applicants = context.read<ApplicantsProvider>();
    final candidates = context.read<CandidatesProvider>();

    await SharedPrefUtils.clear();
    try {
      await AppDatabase.delete();
    } catch (_) {
      // Best-effort; app can still proceed with provider resets.
    }

    auth.reset();
    masters.reset();
    employees.reset();
    employers.reset();
    stories.reset();
    jobs.reset();
    applicants.reset();
    candidates.reset();
    settings.reset();

    // Reset language after clearing SharedPreferences.
    await language.setLanguage(AppLanguage.en);
  }

  static Future<void> logout(BuildContext context) async {
    await clearLocalSession(context);

    if (!context.mounted) return;

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      AppPageRoute.slideFade(page: SignInScreen()),
      (_) => false,
    );
  }

  static Future<void> logoutToAuthScreen(BuildContext context) async {
    await clearLocalSession(context);

    if (!context.mounted) return;

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      AppPageRoute.slideFade(page: AuthScreen()),
      (_) => false,
    );
  }
}
