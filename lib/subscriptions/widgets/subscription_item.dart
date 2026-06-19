import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rotijugaad/theme/context_ext.dart';

import '../../common/widgets/app_button_child.dart';
import '../../common/widgets/xicon.dart';
import '../../theme/app_icons.dart';

class SubscriptionItem extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool isActive;
  final bool isLoading;
  final VoidCallback? onPressed;

  const SubscriptionItem({
    super.key,
    required this.plan,
    required this.isActive,
    this.isLoading = false,
    this.onPressed,
  });

  int _asInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    final s = (v ?? '').toString().trim();
    if (s.isEmpty) return fallback;
    return int.tryParse(s) ?? fallback;
  }

  num _asNum(dynamic v, {num fallback = 0}) {
    if (v is num) return v;
    final s = (v ?? '').toString().trim();
    if (s.isEmpty) return fallback;
    return num.tryParse(s) ?? fallback;
  }

  String _formatPrice(dynamic v) {
    final price = _asNum(v);
    if (price == price.roundToDouble()) {
      return price.toInt().toString();
    }
    return price.toStringAsFixed(2);
  }

  String _asText(dynamic v) => (v ?? '').toString().trim();

  List<Map<String, dynamic>> _asMapList(dynamic v) {
    if (v is List) {
      return v
          .whereType<Map>()
          .map(
            (item) => item.map((key, value) => MapEntry(key.toString(), value)),
          )
          .toList();
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = context.locale.languageCode == 'hi';
    final planName = _asText(
      (isHindi ? plan['plan_name_hindi'] : plan['plan_name_english']) ??
          plan['plan_name_english'] ??
          plan['plan_name_hindi'] ??
          plan['plan_name'] ??
          plan['name'],
    );
    final validityDays = _asInt(plan['plan_validity_days'] ?? plan['validity']);
    final originalPriceValue = _asNum(plan['plan_price'] ?? plan['price']);
    final discountedPriceRaw = plan['discounted_price'];
    final discountedPriceValue = _asNum(
      discountedPriceRaw,
      fallback: originalPriceValue,
    );
    final hasDiscount =
        discountedPriceRaw != null &&
        discountedPriceValue > 0 &&
        discountedPriceValue != originalPriceValue;
    final price = _formatPrice(
      hasDiscount ? discountedPriceValue : originalPriceValue,
    );
    final benefitTexts = _asMapList(plan['plan_benefits'] ?? plan['benefits'])
        .map(
          (benefit) => _asText(
            (isHindi ? benefit['benefit_hindi'] : benefit['benefit_english']) ??
                benefit['benefit_english'] ??
                benefit['benefit_hindi'],
          ),
        )
        .where((text) => text.isNotEmpty)
        .toList();

    final tagline = _asText(
      (isHindi ? plan['plan_tagline_hindi'] : plan['plan_tagline_english']) ??
          plan['plan_tagline_english'] ??
          plan['plan_tagline_hindi'],
    );

    final seenPoints = <String>{};
    final points = benefitTexts
        .where((point) => seenPoints.add(point.toLowerCase()))
        .toList();

    final buttonBackgroundColor = isActive
        ? context.colors.primaryContainer
        : context.colors.primary;
    final buttonTextColor = isActive
        ? context.colors.primary
        : context.colors.onPrimary;
    final disabledBackgroundColor = isLoading
        ? context.colors.primary
        : buttonBackgroundColor;
    final loaderColor = isLoading && !isActive
        ? context.colors.onPrimary
        : buttonTextColor;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.xcolors.stroke, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(context.radii.sm)),
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
            planName.isNotEmpty ? planName : 'subscriptions.plan_fallback'.tr(),
            style: context.text.bodyMedium!.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              if (hasDiscount) ...[
                Text(
                  '₹${_formatPrice(originalPriceValue)}',
                  style: context.text.bodyMedium!.copyWith(
                    color: context.colors.onSurfaceVariant,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                SizedBox(width: context.spacing.xs),
              ],
              Text(
                '₹$price',
                style: context.text.titleLarge!.copyWith(
                  color: context.colors.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: context.spacing.xs),
              Text(
                validityDays > 0
                    ? 'subscriptions.valid_for_days'.tr(
                        args: [validityDays.toString()],
                      )
                    : '',
                style: context.text.bodyMedium,
              ),
            ],
          ),
          if (tagline.isNotEmpty) ...[
            SizedBox(height: context.spacing.xs),
            Text(
              tagline,
              style: context.text.bodySmall!.copyWith(
                color: context.colors.secondary,
              ),
            ),
          ],
          SizedBox(height: context.spacing.md),
          DottedBorder(
            dashPattern: const [6, 3],
            strokeWidth: 1.5,
            color: context.colors.primary,
            customPath: (size) => Path()
              ..moveTo(0, 0)
              ..lineTo(size.width, 0),
            child: const SizedBox(width: double.infinity, height: 0),
          ),
          SizedBox(height: context.spacing.sm),
          if (points.isNotEmpty)
            Column(
              children: points
                  .map(
                    (p) => Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: context.spacing.xxs,
                      ),
                      child: Row(
                        children: [
                          XIcon(
                            AppIcon.success,
                            color: context.colors.primary,
                            size: 18,
                          ),
                          SizedBox(width: context.spacing.sm),
                          Expanded(
                            child: Text(p, style: context.text.bodySmall),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          SizedBox(height: context.spacing.sm),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBackgroundColor,
                disabledBackgroundColor: disabledBackgroundColor,
                disabledForegroundColor: buttonTextColor,
                elevation: 0,
                padding: EdgeInsets.zero,
                side: BorderSide(
                  color: isActive
                      ? context.colors.primary.withValues(alpha: 0.35)
                      : context.colors.primary,
                ),
              ),
              onPressed: isActive || isLoading ? null : onPressed,
              child: AppButtonChild(
                label: isActive
                    ? 'subscriptions.active_plan'.tr()
                    : 'subscriptions.buy_plan'.tr(),
                isLoading: isLoading,
                loaderColor: loaderColor,
                textStyle: context.text.bodyMedium!.copyWith(
                  color: buttonTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
