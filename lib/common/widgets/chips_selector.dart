// lib/widgets/chips_selector.dart
import 'package:flutter/material.dart';
import 'package:rotijugaad/common/widgets/xicon.dart';
import 'package:rotijugaad/theme/app_icons.dart';
import '../models/id_name.dart';
import 'form_label.dart';

class ChipsSelector extends StatelessWidget {
  final String title;
  final List<IdName> options;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onChanged;
  final bool optional;

  const ChipsSelector({
    super.key,
    required this.title,
    required this.options,
    required this.selectedIds,
    required this.onChanged,
    this.optional = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormLabel(title, optional: optional),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((opt) {
              final selected = selectedIds.contains(opt.id);

              return FilterChip(
                selected: selected,
                showCheckmark: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: cs.primary, width: 1.3),
                ),
                backgroundColor: Colors.white,
                selectedColor: cs.primary,
                selectedShadowColor: cs.primary.withOpacity(0.3),
                labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                label: Text(
                  opt.name,
                  style: tt.bodyMedium?.copyWith(
                    color: selected ? cs.onPrimary : cs.onPrimaryContainer,
                  ),
                ),
                deleteIcon: selected
                    ? Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: XIcon(
                    AppIcon.clear,
                    size: 16,
                    color: cs.onPrimary,
                  ),
                )
                    : null,
                onDeleted: selected
                    ? () {
                  final next = {...selectedIds}..remove(opt.id);
                  onChanged(next);
                } : null,
                onSelected: (bool v) {
                  final next = {...selectedIds};
                  if (v) {
                    next.add(opt.id);
                  } else {
                    next.remove(opt.id);
                  }
                  onChanged(next);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
