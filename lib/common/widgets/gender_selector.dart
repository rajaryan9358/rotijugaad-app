// lib/widgets/gender_selector.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'form_label.dart';

enum Gender { male, female, other }

class GenderSelector extends StatelessWidget {
  final String title;
  final Gender? value;
  final ValueChanged<Gender> onChanged;
  final bool optional;
  final bool enabled;

  const GenderSelector({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.optional = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormLabel(title, optional: optional),
          const SizedBox(height: 8),

          // 👇 full width
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<Gender>(
              segments: [
                ButtonSegment(
                  value: Gender.male,
                  label: Text('terms.male'.tr()),
                ),
                ButtonSegment(
                  value: Gender.female,
                  label: Text('terms.female'.tr()),
                ),
              ],
              selected: {if (value != null) value!},
              emptySelectionAllowed: true,
              onSelectionChanged: enabled
                  ? (set) {
                      if (set.isNotEmpty) onChanged(set.first);
                    }
                  : null,
              multiSelectionEnabled: false,
              showSelectedIcon: false,

              // 🎨 Custom style for selected / unselected
              style: ButtonStyle(
                // smaller radius
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                // outline is always primary
                side: MaterialStatePropertyAll(
                  BorderSide(color: cs.primary, width: 1.2),
                ),

                // bg: selected -> primary, else white
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  final selected = states.contains(MaterialState.selected);
                  return selected ? cs.primary : Colors.white;
                }),

                // text/icon color: selected -> onPrimary, else primary
                foregroundColor: MaterialStateProperty.resolveWith((states) {
                  final selected = states.contains(MaterialState.selected);
                  return selected ? cs.onPrimary : cs.primary;
                }),
                // optional: keep heights tidy
                padding: const MaterialStatePropertyAll(
                  EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                ),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
