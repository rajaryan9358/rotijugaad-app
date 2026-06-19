import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

import '../../common/widgets/app_button_child.dart';
import '../../users/services/users_service.dart';
import '../../utils/result.dart';
import '../../utils/shared_pref.dart';

class RateReviewDialog extends StatefulWidget {
  const RateReviewDialog({super.key});

  @override
  State<StatefulWidget> createState() => _RateReviewDialogState();
}

class _RateReviewDialogState extends State<RateReviewDialog> {
  final TextEditingController _commentController = TextEditingController();
  double _rating = 5.0;
  bool _isSubmitting = false;

  int? get _userId {
    final user = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_USER_JSON);
    final raw = user?['id'] ?? user?['user_id'] ?? user?['userId'];
    final id = int.tryParse(raw?.toString() ?? '');
    return (id != null && id > 0) ? id : null;
  }

  String get _userType =>
      SharedPrefUtils.readStr(SharedPrefUtils.USER_TYPE).trim().toLowerCase();

  Future<void> _openStoreReview() async {
    final link = Platform.isAndroid
        ? 'https://play.google.com/store/apps/details?id=com.rotijugaad.app&pcampaignid=web_share'
        : Platform.isIOS
        ? 'https://apps.apple.com/ca/app/bookmyplay/id1661801133'
        : null;

    if (link == null) return;

    final uri = Uri.tryParse(link);
    if (uri == null) return;

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Best-effort; no blocking UI.
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final userId = _userId;
    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('errors.unable_to_load_user_id'.tr())),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final ratingInt = _rating.round().clamp(1, 5);
    final reviewText = _commentController.text.trim();

    final result = await UsersService().submitReview(
      userId: userId,
      rating: ratingInt,
      review: reviewText,
      userType: _userType,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case Success():
        if (ratingInt >= 4) {
          await _openStoreReview();
        }
        if (mounted) {
          Navigator.of(context).pop(ratingInt <= 3);
        }
        break;
      case Failure(exception: final e):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
        break;
    }
  }

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
            Text(
              'profile.rate_review.title'.tr(),
              style: context.text.bodyMedium!.copyWith(
                color: context.colors.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: context.spacing.sm),
            Text(
              'profile.rate_review.subtitle'.tr(),
              textAlign: TextAlign.center,
              style: context.text.bodySmall!.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) =>
                  Icon(Icons.star, color: context.colors.primary),
              onRatingUpdate: (rating) {
                setState(() => _rating = rating);
              },
            ),

            Text(
              'profile.rate_review.review_label'.tr(),
              style: context.text.bodyMedium!.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: context.spacing.sm),
            TextFormField(
              controller: _commentController,
              minLines: 4,
              maxLines: 6,
              keyboardType: TextInputType.multiline,
              style: context.text.bodyMedium,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'profile.rate_review.comment_hint'.tr(),
                filled: true,
                fillColor: context.colors.surface,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: context.spacing.md,
                  vertical: context.spacing.md,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.radii.md),
                  borderSide: BorderSide(color: context.colors.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.radii.md),
                  borderSide: BorderSide(
                    color: context.colors.primary,
                    width: 1.4,
                  ),
                ),
              ),
            ),
            SizedBox(height: context.spacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: AppButtonChild(
                  label: 'common.submit'.tr(),
                  isLoading: _isSubmitting,
                ),
              ),
            ),
            SizedBox(height: context.spacing.xs),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        Navigator.of(context).pop();
                      },
                child: Text('common.maybe_later'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
