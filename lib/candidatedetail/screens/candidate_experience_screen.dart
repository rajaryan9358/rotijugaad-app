import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/candidate_detail_models.dart';
import '../widgets/candidate_experience_item.dart';
import '../../network/api_client.dart';
import '../../theme/context_ext.dart';
import '../../utils/i18n_terms.dart';

class CandidateExperienceScreen extends StatelessWidget {
  final List<CandidateExperienceDto> experiences;

  const CandidateExperienceScreen({super.key, required this.experiences});

  String _durationText(BuildContext context, CandidateExperienceDto e) {
    final d = e.workDuration;
    final freq = (e.workDurationFrequency ?? '').trim();
    if (d == null) return '-';

    final value = (d % 1 == 0) ? d.toInt().toString() : d.toString();
    if (freq.isEmpty) return value;
    return '$value ${I18nTerms.fromRaw(context, freq)}';
  }

  String? _certificateName(String? path) {
    final raw = (path ?? '').trim();
    if (raw.isEmpty) return null;
    final parts = raw.split('/');
    return parts.isEmpty ? raw : parts.last;
  }

  String? _certificateUrl(String? path) {
    final raw = (path ?? '').trim();
    if (raw.isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;

    final base = ApiClient.baseUrl.endsWith('/')
        ? ApiClient.baseUrl.substring(0, ApiClient.baseUrl.length - 1)
        : ApiClient.baseUrl;
    return raw.startsWith('/') ? '$base$raw' : '$base/$raw';
  }

  Future<void> _openCertificate(BuildContext context, String? path) async {
    final rawUrl = _certificateUrl(path);
    if (rawUrl == null || rawUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Certificate link unavailable')),
      );
      return;
    }

    final uri = Uri.tryParse(rawUrl);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open certificate')),
      );
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open certificate')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final isHindi = context.locale.languageCode.toLowerCase() == 'hi';

    if (experiences.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          left: spacing.md,
          right: spacing.md,
          top: spacing.lg,
          bottom: spacing.xxxl,
        ),
        children: [
          Center(
            child: Text(
              'candidates.detail.no_experience_added'.tr(),
              style: context.text.bodyMedium,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        left: spacing.md,
        right: spacing.md,
        top: spacing.md,
        bottom: spacing.xxxl,
      ),
      itemCount: experiences.length,
      itemBuilder: (context, index) {
        final e = experiences[index];
        final title =
            ((isHindi ? e.workNatureHindi : e.workNatureEnglish) ??
                    e.workNatureEnglish ??
                    e.workNatureHindi ??
                    'candidates.detail.experience'.tr())
                .trim();
        return CandidateExperienceItem(
          title: title.isEmpty ? 'candidates.detail.experience'.tr() : title,
          firm: e.previousFirm,
          duration: _durationText(context, e),
          certificateName: _certificateName(e.experienceCertificate),
          onCertificateTap: () =>
              _openCertificate(context, e.experienceCertificate),
        );
      },
    );
  }
}
