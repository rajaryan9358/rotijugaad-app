// lib/widgets/expected_salary_field.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class ExpectedSalaryField<T> extends StatelessWidget {
  final String title;
  final TextEditingController? amountController;

  final T? selectedValue; // current selected item
  final List<T> options; // list of ANY items
  final String Function(T) labelBuilder; // convert item → label text
  final ValueChanged<T> onChanged;

  final bool optional;
  final String? hintText;
  final int? maxLength;

  const ExpectedSalaryField({
    super.key,
    required this.title,
    required this.options,
    required this.labelBuilder,
    required this.onChanged,
    this.selectedValue,
    this.amountController,
    this.optional = false,
    this.hintText,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title + Optional
          Row(
            children: [
              Text(
                title,
                style: tt.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                ),
              ),
              const Spacer(),
              if (optional)
                Text(
                  'common.optional'.tr(),
                  style: tt.labelMedium?.copyWith(
                    color: cs.onSurface.withOpacity(.6),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),

          /// Field Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: amountController,
                  maxLength: maxLength,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                  ],
                  style: context.text.bodyMedium!.copyWith(
                    color: context.colors.onPrimaryContainer,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText ?? '20,000',
                    hintStyle: context.text.bodyMedium!.copyWith(
                      color: context.colors.onPrimaryContainer,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.only(
                      left: 12,
                      right: 4,
                      bottom: 12,
                      top: 4,
                    ),
                    counterText: '',

                    /// Dropdown inside suffix
                    suffixIcon: Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      margin: const EdgeInsets.only(right: 8),
                      child: Center(
                        child: DropdownButtonFormField<T>(
                          value: selectedValue,
                          isExpanded: true,

                          style: context.text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.colors.onPrimary,
                          ),

                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: context.colors.onPrimary,
                          ),

                          dropdownColor: context.colors.primary,

                          items: options
                              .map(
                                (e) => DropdownMenuItem<T>(
                                  value: e,
                                  child: Text(
                                    labelBuilder(e),
                                    overflow: TextOverflow.ellipsis,
                                    style: context.text.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: context.colors.onPrimary,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),

                          onChanged: (v) {
                            if (v != null) onChanged(v);
                          },

                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: context.colors.primary,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: context.colors.onPrimary.withOpacity(
                                  0.25,
                                ),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: context.colors.onPrimary.withOpacity(
                                  0.6,
                                ),
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: context.colors.onPrimary.withOpacity(
                                  0.25,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
