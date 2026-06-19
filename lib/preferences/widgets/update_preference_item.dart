import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class UpdatePreferenceItem extends StatelessWidget {
  final bool isSelected;
  final String title;
  final String imageAssetPath;
  final String? imageUrl;

  const UpdatePreferenceItem(
    this.isSelected, {
    super.key,
    this.title = 'House Maid',
    this.imageAssetPath = 'assets/images/img_welcome.png',
    this.imageUrl,
  });

  static const Color _selectedColor = Color(0xFF005AA3);

  @override
  Widget build(BuildContext context) {
    final url = (imageUrl ?? '').trim();
    final Widget image = url.isNotEmpty
        ? Image.network(
            url,
            width: 72,
            height: 72,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Image.asset(
              imageAssetPath,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
            ),
          )
        : Image.asset(
            imageAssetPath,
            width: 72,
            height: 72,
            fit: BoxFit.cover,
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(context.spacing.xs),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(context.radii.sm)),
            border: isSelected
                ? Border.all(color: _selectedColor, width: 2)
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(context.radii.sm)),
            child: image,
          ),
        ),
        SizedBox(height: context.spacing.xs),
        Flexible(
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodyMedium!.copyWith(
              color: isSelected
                  ? _selectedColor
                  : context.colors.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
