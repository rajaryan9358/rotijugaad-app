import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

class I18nTerms {
  static String fromRaw(BuildContext context, String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) return '';

    final key = value.toLowerCase();
    switch (key) {
      case 'employer':
        return 'terms.employer'.tr();
      case 'employee':
        return 'terms.employee'.tr();

      case 'male':
        return 'terms.male'.tr();
      case 'female':
        return 'terms.female'.tr();
      case 'both':
        return 'terms.both'.tr();
      case 'other':
        return 'terms.other'.tr();

      case 'any':
        return 'terms.any'.tr();

      case 'monthly':
        return 'terms.monthly'.tr();
      case 'month':
        return 'terms.month'.tr();
      case 'months':
        return 'terms.months'.tr();
      case 'weekly':
        return 'terms.weekly'.tr();
      case 'yearly':
        return 'terms.yearly'.tr();
      case 'week':
        return 'terms.week'.tr();
      case 'weeks':
        return 'terms.weeks'.tr();
      case 'year':
        return 'terms.year'.tr();
      case 'years':
        return 'terms.years'.tr();
      case 'daily':
        return 'terms.daily'.tr();
      case 'day':
        return 'terms.day'.tr();
      case 'days':
        return 'terms.days'.tr();

      case 'per month':
      case '/month':
      case '/months':
        return 'terms.monthly'.tr();
      case 'per week':
      case '/week':
      case '/weeks':
        return 'terms.weekly'.tr();
      case 'per day':
      case '/day':
      case '/days':
        return 'terms.daily'.tr();

      case 'pending':
        return 'terms.pending'.tr();
      case 'verified':
        return 'terms.verified'.tr();
      case 'rejected':
        return 'terms.rejected'.tr();
      case 'approved':
        return 'terms.approved'.tr();

      case 'active':
        return 'terms.active'.tr();
      case 'inactive':
        return 'terms.inactive'.tr();
      case 'expired':
        return 'terms.expired'.tr();
      case 'applied':
        return 'terms.applied'.tr();
      case 'hired':
        return 'terms.hired'.tr();

      case 'shortlisted':
        return 'terms.shortlisted'.tr();

      case 'success':
        return 'terms.success'.tr();
      case 'failed':
        return 'terms.failed'.tr();
      case 'init':
        return 'terms.init'.tr();

      case 'job':
        return 'terms.job'.tr();
    }

    return value;
  }
}
