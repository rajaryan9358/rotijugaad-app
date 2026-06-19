import "package:flutter/material.dart";
import "package:rotijugaad/theme/context_ext.dart";

class ShiftDayItem extends StatelessWidget {
  final String label;
  final bool isChecked;
  final ValueChanged<bool> onCheckChange;

  const ShiftDayItem(
    this.label,
    this.isChecked,
    this.onCheckChange, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: context.spacing.xs),
      child: Row(
        children: [
          Checkbox(
            value: isChecked,
            onChanged: (checked) => onCheckChange(checked ?? false),
            activeColor: context.colors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: context.text.bodyMedium?.copyWith(
                fontWeight: isChecked ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
