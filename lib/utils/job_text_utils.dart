import 'package:easy_localization/easy_localization.dart';

String formatVacancyCountText(
  int? count, {
  bool padToTwoDigits = false,
  bool vacanciesLeft = false,
}) {
  if (count == null) return '-';

  final value = padToTwoDigits ? count.toString().padLeft(2, '0') : '$count';

  if (vacanciesLeft) {
    return count == 1
        ? 'applications.vacancy_left'.tr(args: [value])
        : 'applications.vacancies_left'.tr(args: [value]);
  }

  return count == 1
      ? 'common.vacancy'.tr(args: [value])
      : 'common.vacancies'.tr(args: [value]);
}

String formatVacancyRawText(String? raw, {bool vacanciesLeft = false}) {
  final value = (raw ?? '').trim();
  if (value.isEmpty) return '-';

  final count = int.tryParse(value);
  if (count == null) {
    return vacanciesLeft
        ? 'applications.vacancies_left'.tr(args: [value])
        : 'common.vacancies'.tr(args: [value]);
  }

  return formatVacancyCountText(count, vacanciesLeft: vacanciesLeft);
}
