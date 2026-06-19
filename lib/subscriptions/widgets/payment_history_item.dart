import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../common/widgets/xicon.dart';
import '../../theme/app_icons.dart';
import '../../theme/context_ext.dart';

class PaymentHistoryItem extends StatelessWidget {
  final Map<String, dynamic> payment;
  final VoidCallback? onDownload;

  const PaymentHistoryItem({super.key, required this.payment, this.onDownload});

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return double.tryParse(v.toString())?.toInt();
  }

  DateTime? _asDate(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v.toString()).toLocal();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = context.locale.languageCode.toLowerCase() == 'hi';
    final planName =
        ((isHindi
                    ? (payment['plan_name_hindi'] ?? payment['planNameHindi'])
                    : (payment['plan_name_english'] ??
                          payment['planNameEnglish'])) ??
                payment['plan_name'] ??
                payment['planName'] ??
                payment['plan_name_english'] ??
                payment['plan_name_hindi'])
            ?.toString()
            .trim() ??
        '';
    final safePlanName = planName.isEmpty ? '—' : planName;

    final price = _asInt(payment['price_total']);
    final priceText = price == null
        ? '—'
        : '₹${NumberFormat.decimalPattern('en_IN').format(price)}';

    final orderId = (payment['order_id'] ?? '').toString().trim();
    final safeOrderId = orderId.isEmpty ? '—' : orderId;

    final createdAt = _asDate(payment['created_at']);
    final paidAtText = createdAt == null
        ? 'subscriptions.payment_history.paid_at'.tr(args: ['—'])
        : 'subscriptions.payment_history.paid_at'.tr(
            args: [DateFormat('hh:mm a, d MMM y').format(createdAt)],
          );

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        safePlanName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyMedium!.copyWith(
                          color: context.colors.secondary,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: context.spacing.xs),
                        child: Text(
                          priceText,
                          style: context.text.bodyLarge!.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: onDownload,
                    icon: XIcon(
                      AppIcon.download,
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.spacing.xs),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'subscriptions.payment_history.order_id'.tr(
                        args: [safeOrderId],
                      ),
                      style: context.text.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: context.spacing.xs),
                  GestureDetector(
                    onTap: orderId.isEmpty
                        ? null
                        : () async {
                            await Clipboard.setData(
                              ClipboardData(text: orderId),
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'subscriptions.payment_history.order_id_copied'
                                        .tr(),
                                  ),
                                ),
                              );
                            }
                          },
                    child: Text(
                      'common.copy'.tr(),
                      style: context.text.bodyMedium!.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.spacing.xs),
              Text(paidAtText, style: context.text.bodyMedium),
            ],
          ),
        ),
        SizedBox(height: context.spacing.sm),
        Divider(color: context.xcolors.stroke),
      ],
    );
  }
}
