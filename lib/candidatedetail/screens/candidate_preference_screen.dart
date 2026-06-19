import 'package:flutter/widgets.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../preferences/widgets/update_preference_item.dart';
import '../../theme/context_ext.dart';
import '../../candidates/models/candidate_summary.dart';

class CandidatePreferenceScreen extends StatelessWidget {
  final List<CandidateJobProfileDto> jobProfiles;

  const CandidatePreferenceScreen({super.key, required this.jobProfiles});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final isHindi = context.locale.languageCode.toLowerCase() == 'hi';

    if (jobProfiles.isEmpty) {
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
              'candidates.detail.no_preferences_found'.tr(),
              style: context.text.bodyMedium,
            ),
          ),
        ],
      );
    }

    return Container(
      margin: EdgeInsets.only(
        left: spacing.md,
        right: spacing.md,
        top: spacing.md,
        bottom: spacing.xxxl,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: jobProfiles.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.62,
        ),
        itemBuilder: (context, index) {
          final p = jobProfiles[index];
          final selectedTitle = (isHindi ? p.profileHindi : p.profileEnglish)
              .trim();
          final fallbackTitle = (isHindi ? p.profileEnglish : p.profileHindi)
              .trim();
          final title = selectedTitle.isEmpty
              ? fallbackTitle.isEmpty
                    ? '-'
                    : fallbackTitle
              : selectedTitle;
          return UpdatePreferenceItem(false, title: title, imageUrl: p.profileImage);
        },
      ),
    );
  }
}
