import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rotijugaad/employees/services/employees_service.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/utils/result.dart';

class DobRequiredDialog extends StatefulWidget {
  final int employeeId;

  const DobRequiredDialog({super.key, required this.employeeId});

  @override
  State<DobRequiredDialog> createState() => _DobRequiredDialogState();
}

class _DobRequiredDialogState extends State<DobRequiredDialog> {
  DateTime? _selectedDate;
  bool _saving = false;
  String? _error;

  static DateTime get _maxDate {
    final now = DateTime.now();
    return DateTime(now.year - 18, now.month, now.day);
  }

  String get _formattedDate {
    if (_selectedDate == null) return '';
    return '${_selectedDate!.year.toString().padLeft(4, '0')}-'
        '${_selectedDate!.month.toString().padLeft(2, '0')}-'
        '${_selectedDate!.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? _maxDate,
      firstDate: DateTime(1940),
      lastDate: _maxDate,
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (_selectedDate == null) {
      setState(() => _error = 'dob_dialog.select_dob'.tr());
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });

    final result = await EmployeesService().saveDob(
      employeeId: widget.employeeId,
      dob: _formattedDate,
    );

    if (!mounted) return;

    switch (result) {
      case Success():
        Navigator.of(context).pop(true);
      case Failure(exception: final e):
        setState(() {
          _saving = false;
          _error = e.message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayDate = _selectedDate == null
        ? 'dob_dialog.select_date'.tr()
        : DateFormat('dd MMM yyyy').format(_selectedDate!);

    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('dob_dialog.title'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'dob_dialog.message'.tr(),
              style: context.text.bodyMedium,
            ),
            SizedBox(height: context.spacing.sm),
            Container(
              padding: EdgeInsets.all(context.spacing.xs),
              decoration: BoxDecoration(
                color: context.xcolors.warningBackground,
                borderRadius: BorderRadius.circular(context.radii.sm),
              ),
              child: Text(
                'dob_dialog.warning'.tr(),
                style: context.text.bodySmall!.copyWith(
                  color: context.xcolors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: context.spacing.md),
            InkWell(
              onTap: _saving ? null : _pickDate,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: context.spacing.sm,
                  vertical: context.spacing.sm,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _error != null
                        ? context.xcolors.failure
                        : context.xcolors.stroke,
                  ),
                  borderRadius: BorderRadius.circular(context.radii.sm),
                ),
                child: Text(
                  displayDate,
                  style: context.text.bodyMedium!.copyWith(
                    color: _selectedDate == null
                        ? context.colors.onSurfaceVariant
                        : context.colors.onSurface,
                  ),
                ),
              ),
            ),
            if (_error != null) ...[
              SizedBox(height: context.spacing.xs),
              Text(
                _error!,
                style: context.text.bodySmall!.copyWith(
                  color: context.xcolors.failure,
                ),
              ),
            ],
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.colors.onPrimary,
                      ),
                    )
                  : Text('common.save'.tr()),
            ),
          ),
        ],
      ),
    );
  }
}
