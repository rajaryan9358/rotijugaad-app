// lib/widgets/labeled_form_field.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rotijugaad/theme/context_ext.dart';

enum FieldPickerMode { none, date, time, dateTime }

class LabeledFormField extends StatefulWidget {
  // Label
  final String title;
  final bool optional;
  final bool ifAny;

  // Text field core
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final int maxLines;
  final bool enabled; // editable vs non-editable
  final bool readOnly; // blocks keyboard but allows onTap

  // Password
  final bool isPassword;
  final double? height;

  // Icons
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  // Picker
  final FieldPickerMode pickerMode;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateFormat? dateFormat; // default: yyyy-MM-dd
  final DateFormat? timeFormat; // default: hh:mm a

  // Callbacks
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final VoidCallback? onTap; // custom tap if you want to handle yourself

  const LabeledFormField({
    super.key,
    required this.title,
    this.optional = false,
    this.ifAny = false,
    this.controller,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
    this.maxLines = 1,
    this.enabled = true,
    this.readOnly = false,
    this.isPassword = false,
    this.height = 48,
    this.prefixIcon,
    this.suffixIcon,
    this.pickerMode = FieldPickerMode.none,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.dateFormat,
    this.timeFormat,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
  });

  @override
  State<LabeledFormField> createState() => _LabeledFormFieldState();
}

class _LabeledFormFieldState extends State<LabeledFormField> {
  late bool _obscure;

  ThemeData _timePickerTheme(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color resolveSelectedText(Set<MaterialState> states) {
      return states.contains(MaterialState.selected)
          ? colorScheme.onSecondary
          : colorScheme.onSurface;
    }

    Color resolveSelectedFill(Set<MaterialState> states) {
      return states.contains(MaterialState.selected)
          ? colorScheme.secondary
          : colorScheme.surfaceContainerHighest;
    }

    return theme.copyWith(
      timePickerTheme: theme.timePickerTheme.copyWith(
        backgroundColor: colorScheme.surface,
        dialHandColor: colorScheme.secondary,
        dialBackgroundColor: colorScheme.surfaceContainerHighest,
        hourMinuteColor: MaterialStateColor.resolveWith(resolveSelectedFill),
        hourMinuteTextColor: MaterialStateColor.resolveWith(
          resolveSelectedText,
        ),
        dayPeriodColor: MaterialStateColor.resolveWith(resolveSelectedFill),
        dayPeriodTextColor: MaterialStateColor.resolveWith(resolveSelectedText),
        entryModeIconColor: colorScheme.secondary,
      ),
      colorScheme: colorScheme.copyWith(
        primary: colorScheme.secondary,
        onPrimary: colorScheme.onSecondary,
      ),
    );
  }

  String _formatTimeDisplay(DateFormat format, DateTime value) {
    final raw = format.format(value);
    return raw.replaceAllMapped(
      RegExp(r'\b(am|pm)\b', caseSensitive: false),
      (match) => (match.group(0) ?? '').toUpperCase(),
    );
  }

  DateTime _resolveInitialDate(DateTime fallback) {
    final firstDate = widget.firstDate ?? DateTime(1900);
    final lastDate = widget.lastDate ?? DateTime(2100);

    DateTime? initial = widget.initialDate;
    if (initial == null) {
      final raw = widget.controller?.text.trim() ?? '';
      if (raw.isNotEmpty) {
        initial = DateTime.tryParse(raw);
      }
    }

    initial ??= fallback;

    if (initial.isBefore(firstDate)) return firstDate;
    if (initial.isAfter(lastDate)) return lastDate;
    return initial;
  }

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  Future<void> _handleTap(BuildContext context) async {
    // If user provided custom onTap, call it first
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }

    if (widget.pickerMode == FieldPickerMode.none) return;

    final controller = widget.controller ?? TextEditingController();
    final df = widget.dateFormat ?? DateFormat('yyyy-MM-dd');
    final tf = widget.timeFormat ?? DateFormat('hh:mm a');

    final now = DateTime.now();
    final resolvedInitialDate = _resolveInitialDate(now);

    switch (widget.pickerMode) {
      case FieldPickerMode.date:
        {
          final picked = await showDatePicker(
            context: context,
            initialDate: resolvedInitialDate,
            firstDate: widget.firstDate ?? DateTime(1900),
            lastDate: widget.lastDate ?? DateTime(2100),
          );
          if (picked != null) controller.text = df.format(picked);
          break;
        }
      case FieldPickerMode.time:
        {
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(resolvedInitialDate),
            builder: (context, child) =>
                Theme(data: _timePickerTheme(context), child: child!),
          );
          if (picked != null) {
            final dt = DateTime(
              now.year,
              now.month,
              now.day,
              picked.hour,
              picked.minute,
            );
            controller.text = _formatTimeDisplay(tf, dt);
          }
          break;
        }
      case FieldPickerMode.dateTime:
        {
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: resolvedInitialDate,
            firstDate: widget.firstDate ?? DateTime(1900),
            lastDate: widget.lastDate ?? DateTime(2100),
          );
          if (pickedDate == null) break;
          final pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(resolvedInitialDate),
            builder: (context, child) =>
                Theme(data: _timePickerTheme(context), child: child!),
          );
          if (pickedTime != null) {
            final dt = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
            controller.text = '${df.format(dt)} ${_formatTimeDisplay(tf, dt)}';
          } else {
            controller.text = df.format(pickedDate);
          }
          break;
        }
      case FieldPickerMode.none:
        // handled above
        break;
    }

    // If we created a temp controller just for formatting, sync back
    if (widget.controller == null) {
      // no-op; typically you pass a controller to read value
    }

    // notify change
    widget.onChanged?.call((widget.controller ?? controller).text);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final controller = widget.controller;

    // Eye icon for password (only if no custom suffix provided)
    final eye = IconButton(
      icon: Icon(
        _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
      ),
      onPressed: !widget.enabled
          ? null
          : () => setState(() => _obscure = !_obscure),
      tooltip: _obscure ? 'Show' : 'Hide',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + Optional
        if (widget.title.isNotEmpty)
          Row(
            children: [
              Text(
                widget.title,
                style: tt.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                ),
              ),
              const Spacer(),
              if (widget.optional)
                Text(
                  'common.optional'.tr(),
                  style: tt.labelMedium?.copyWith(color: cs.onPrimaryContainer),
                ),
              if (widget.ifAny)
                Text(
                  'if any',
                  style: tt.labelMedium?.copyWith(
                    color: cs.onSurface.withOpacity(0.6),
                  ),
                ),
            ],
          ),
        if (widget.title.isNotEmpty) const SizedBox(height: 6),

        // Field
        SizedBox(
          height: widget.height,
          child: TextFormField(
            controller: controller,
            enabled: widget.enabled,
            focusNode: widget.focusNode,
            readOnly:
                widget.readOnly || widget.pickerMode != FieldPickerMode.none,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            maxLength: widget.maxLength,
            inputFormatters: widget.inputFormatters,
            maxLines: widget.isPassword ? 1 : widget.maxLines,
            obscureText: _obscure,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onFieldSubmitted,
            onTap:
                (widget.readOnly || widget.pickerMode != FieldPickerMode.none)
                ? () => _handleTap(context)
                : widget.onTap, // fall back to custom if provided
            style: context.text.bodyMedium!.copyWith(
              color: context.colors.onPrimaryContainer,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: widget.enabled
                  ? context.text.bodyMedium!.copyWith(
                      color: context.colors.onPrimaryContainer,
                    )
                  : null,
              counterText: '',
              prefixIcon: widget.prefixIcon,
              // contentPadding: EdgeInsets.zero,
              // if isPassword and no custom suffix provided, show eye
              suffixIcon: widget.suffixIcon ?? (widget.isPassword ? eye : null),
            ),
          ),
        ),
      ],
    );
  }
}
