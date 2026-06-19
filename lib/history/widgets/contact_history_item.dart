import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/widgets/icon_text.dart';
import '../../common/widgets/xicon.dart';
import '../../theme/app_icons.dart';
import '../../utils/i18n_terms.dart';
import '../../utils/job_text_utils.dart';

class ContactHistoryItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const ContactHistoryItem({super.key, required this.item});

  Map<String, dynamic>? _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
    return null;
  }

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    final raw = v.toString().trim();
    if (raw.isEmpty) return null;
    final direct = int.tryParse(raw);
    if (direct != null) return direct;
    final decimal = num.tryParse(raw);
    return decimal?.toInt();
  }

  DateTime? _asDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString())?.toLocal();
  }

  String _formatDateTime(dynamic v) {
    final dt = _asDate(v);
    if (dt == null) return '—';
    return DateFormat('hh:mm a, d MMM y').format(dt);
  }

  String _formatTimeRange(dynamic from, dynamic to) {
    DateTime? parse(dynamic value) {
      final raw = (value ?? '').toString().trim();
      if (raw.isEmpty) return null;
      for (final pattern in const ['HH:mm:ss', 'HH:mm']) {
        try {
          return DateFormat(pattern).parseStrict(raw);
        } catch (_) {}
      }
      return null;
    }

    final start = parse(from);
    final end = parse(to);
    if (start == null && end == null) return '—';
    if (start != null && end != null) {
      return '${DateFormat('h:mm a').format(start)} - ${DateFormat('h:mm a').format(end)}';
    }

    final raw = [
      (from ?? '').toString().trim(),
      (to ?? '').toString().trim(),
    ].where((e) => e.isNotEmpty).join(' - ');

    return raw.isEmpty ? '—' : raw;
  }

  String _salaryText(BuildContext context, Map<String, dynamic>? job) {
    final min = _asInt(job?['salary_min']);
    final max = _asInt(job?['salary_max']);
    final salaryType = _asMap(job?['SalaryType']);
    final rawFreq =
        (salaryType?['type_english'] ??
                salaryType?['type_hindi'] ??
                job?['salary_type'])
            ?.toString()
            .trim();
    final freq = I18nTerms.fromRaw(context, rawFreq);

    String withFreq(String text) {
      if (freq.isEmpty) return text;
      return '$text/$freq';
    }

    if (min == null && max == null) return '—';
    if (min != null && max != null && min != max) {
      return withFreq(
        '₹${NumberFormat.decimalPattern('en_IN').format(min)} - ₹${NumberFormat.decimalPattern('en_IN').format(max)}',
      );
    }

    final value = min ?? max!;
    return withFreq('₹${NumberFormat.decimalPattern('en_IN').format(value)}');
  }

  String _locationText(Map<String, dynamic>? job) {
    final state = _asMap(job?['JobState']);
    final city = _asMap(job?['JobCity']);
    final cityText = (city?['city_english'] ?? city?['city_hindi'] ?? '')
        .toString()
        .trim();
    final stateText = (state?['state_english'] ?? state?['state_hindi'] ?? '')
        .toString()
        .trim();

    final parts = [cityText, stateText].where((e) => e.isNotEmpty).toList();
    return parts.isEmpty ? '—' : parts.join(', ');
  }

  String _addressWithLocation(Map<String, dynamic>? job) {
    final address =
        (job?['job_address_english'] ?? job?['job_address_hindi'] ?? '')
            .toString()
            .trim();
    final location = _locationText(job);

    if (address.isEmpty) {
      return location;
    }
    if (location == '—') {
      return address;
    }

    return '$address, $location';
  }

  String _phoneText(String rawPhone) {
    final raw = rawPhone.trim();
    if (raw.isEmpty) return '—';
    if (raw.startsWith('+')) return raw;

    final digits = raw.replaceAll(RegExp(r'\D+'), '');
    if (digits.length == 10) return '+91 $digits';
    if (digits.length == 12 && digits.startsWith('91')) {
      return '+91 ${digits.substring(2)}';
    }

    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final contact = _asMap(item['contact']);
    final job = _asMap(item['job']);
    final employer = _asMap(item['employer']);

    final title = (item['job_profile_name'] ?? '').toString().trim();
    final org = (item['organization_name'] ?? '').toString().trim();
    final unlockedAt = _formatDateTime(contact?['unlocked_at']);
    final timeRange = _formatTimeRange(
      job?['work_start_time'],
      job?['work_end_time'],
    );
    final vacancies = _asInt(job?['no_vacancy']);
    final address = _addressWithLocation(job);
    final phone = (employer?['phone'] ?? '').toString().trim();
    final isEmployerDeleted = phone.isNotEmpty &&
        (phone.startsWith('-') ||
            (num.tryParse(phone.replaceAll(RegExp(r'\s'), '')) ?? 0) < 0);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.xcolors.stroke, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(context.radii.sm)),
        color: context.colors.onPrimary,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.sm,
        vertical: context.spacing.sm,
      ),
      margin: EdgeInsets.symmetric(vertical: context.spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'history.contact_details'.tr(),
            style: context.text.bodyMedium!.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: context.spacing.sm),
          Text(
            'history.unlocked_on'.tr(args: [unlockedAt]),
            style: context.text.bodySmall,
          ),
          SizedBox(height: context.spacing.md),
          Text(
            title.isEmpty ? '—' : title,
            style: context.text.bodyLarge!.copyWith(
              color: context.colors.primary,
            ),
          ),
          Text(
            org.isEmpty ? '—' : org,
            style: context.text.bodyMedium!.copyWith(
              color: context.colors.secondary,
            ),
          ),
          SizedBox(height: context.spacing.md),
          Row(
            children: [
              Expanded(
                child: IconText(
                  XIcon(AppIcon.location, size: 16),
                  _locationText(job),
                ),
              ),
              SizedBox(width: context.spacing.md),
              Expanded(
                child: IconText(XIcon(AppIcon.jobTime, size: 16), timeRange),
              ),
            ],
          ),
          SizedBox(height: context.spacing.sm),
          Row(
            children: [
              Expanded(
                child: IconText(
                  XIcon(AppIcon.salary, size: 16),
                  _salaryText(context, job),
                ),
              ),
              SizedBox(width: context.spacing.md),
              Expanded(
                child: IconText(
                  XIcon(AppIcon.vacancy, size: 16),
                  vacancies == null
                      ? '—'
                      : formatVacancyCountText(vacancies, padToTwoDigits: true),
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing.md),
          Text(
            address.isEmpty ? '—' : address,
            style: context.text.bodyMedium!.copyWith(
              color: context.colors.primary,
            ),
          ),
          if (!isEmployerDeleted) ...[
            SizedBox(height: context.spacing.sm),
            GestureDetector(
              onTap: phone.isEmpty
                  ? null
                  : () {
                      final digits = phone.replaceAll(RegExp(r'\s+'), '');
                      launchUrl(Uri(scheme: 'tel', path: digits));
                    },
              child: Row(
                children: [
                  XIcon(AppIcon.callFilled, color: context.colors.primary),
                  SizedBox(width: context.spacing.xs),
                  Text(
                    _phoneText(phone),
                    style: context.text.bodyMedium!.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
