import 'package:flutter/material.dart';
import 'package:rotijugaad/common/widgets/xicon.dart';
import 'package:rotijugaad/theme/app_icons.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:url_launcher/url_launcher.dart';

class DialDialog extends StatelessWidget {
  final String? phone;
  final String? address;
  final double? lat;
  final double? lng;

  const DialDialog({
    super.key,
    this.phone,
    this.address,
    this.lat,
    this.lng,
  });

  @override
  Widget build(BuildContext context) {
    final showAddress = (address ?? '').trim().isNotEmpty;

    return Dialog(
      backgroundColor: context.colors.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            XIcon(AppIcon.success, size: 48, color: context.xcolors.success),
            SizedBox(height: context.spacing.sm),
            Text(
              'Contact is Unlocked!',
              style: context.text.bodyMedium!.copyWith(
                color: context.colors.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacing.sm),
            if (showAddress) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      address!.trim(),
                      textAlign: TextAlign.center,
                      style: context.text.bodySmall!.copyWith(fontWeight: FontWeight.w400),
                    ),
                  ),
                  if (lat != null && lng != null) ...[
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () async {
                        final uri = Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
                        );
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                      child: XIcon(
                        AppIcon.location,
                        size: 20,
                        color: context.colors.primary,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: context.spacing.md),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (phone ?? '').trim().isEmpty ? null : () => Navigator.of(context).pop(true),
                child: const Text('Dial'),
              ),
            ),
            SizedBox(height: context.spacing.xs),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.secondaryContainer,
                  elevation: 0,
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Done', style: context.text.bodyMedium),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
