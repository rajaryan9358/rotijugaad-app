import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/auth/utils/account_status_guard.dart';
import 'package:rotijugaad/utils/shared_pref.dart';
import 'package:rotijugaad/common/models/id_name.dart';
import 'package:rotijugaad/common/widgets/app_dropdown.dart';
import 'package:rotijugaad/common/widgets/expected_salary_field.dart';
import 'package:rotijugaad/common/widgets/labeled_form_field.dart';
import 'package:rotijugaad/common/widgets/xicon.dart';
import 'package:rotijugaad/employees/providers/employees_provider.dart';
import 'package:rotijugaad/masters/models/document_dtos.dart';
import 'package:rotijugaad/masters/providers/masters_provider.dart';
import 'package:rotijugaad/theme/app_icons.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/utils/i18n_terms.dart';
import 'package:url_launcher/url_launcher.dart';

class AddExperienceScreen extends StatefulWidget {
  final int employeeId;
  final int? experienceId;
  final bool showAdd;
  final VoidCallback onButtonClicked;

  const AddExperienceScreen({
    super.key,
    required this.employeeId,
    this.experienceId,
    this.showAdd = true,
    required this.onButtonClicked,
  });

  @override
  State<StatefulWidget> createState() => _AddExperienceScreenState();
}

class _AddExperienceScreenState extends State<AddExperienceScreen> {
  bool _futuresInitialized = false;

  late Future<List<DocumentTypeDto>> _documentTypesFuture;
  late Future<List<WorkNatureDto>> _workNaturesFuture;

  String? _documentTypeId;
  String? _workNatureId;

  final TextEditingController _previousFirmController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  String _durationFrequency = 'months';

  File? _pickedCertificate;
  String? _existingCertificateUrl;
  final TextEditingController _certificateController = TextEditingController();

  bool get _requiresPreviousJobDetails => _asInt(_workNatureId) != null;

  int? _asInt(String? v) => v == null ? null : int.tryParse(v);

  String _pickLang(String? en, String? hi) {
    final isHindi = context.locale.languageCode.toLowerCase() == 'hi';
    final primary = (isHindi ? hi : en)?.trim() ?? '';
    if (primary.isNotEmpty) return primary;
    return ((isHindi ? en : hi) ?? '').trim();
  }

  List<IdName> _docTypesToItems(List<DocumentTypeDto> list) {
    return list
        .map(
          (d) => IdName(
            id: d.id.toString(),
            name: _pickLang(d.typeEnglish, d.typeHindi),
          ),
        )
        .where((e) => e.name.trim().isNotEmpty)
        .toList();
  }

  List<IdName> _workNaturesToItems(List<WorkNatureDto> list) {
    return list
        .map(
          (n) => IdName(
            id: n.id.toString(),
            name: _pickLang(n.natureEnglish, n.natureHindi),
          ),
        )
        .where((e) => e.name.trim().isNotEmpty)
        .toList();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void initState() {
    super.initState();

    final experienceId = widget.experienceId;
    if (experienceId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final exp = await context.read<EmployeesProvider>().fetchExperienceById(
          experienceId,
        );
        if (!mounted || exp == null) return;

        setState(() {
          _documentTypeId = exp.documentType?.id.toString();
          _workNatureId = exp.workNature?.id.toString();
          _previousFirmController.text = (exp.previousFirm ?? '').trim();

          if (exp.workDuration != null) {
            final d = exp.workDuration!;
            _durationController.text = d % 1 == 0
                ? d.toInt().toString()
                : d.toString();
          }

          final f = (exp.workDurationFrequency ?? '').trim().toLowerCase();
          if (f.isNotEmpty) _durationFrequency = f;

          final link = (exp.experienceCertificate ?? '').trim();
          if (link.isNotEmpty) {
            _existingCertificateUrl = link;
            _certificateController.text = link.split('/').last;
          }
        });
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_futuresInitialized) return;
    _futuresInitialized = true;

    final masters = context.read<MastersProvider>();
    masters.loadMasters();

    _documentTypesFuture = masters.getDocumentTypesFromDb();
    _workNaturesFuture = masters.getWorkNaturesFromDb();
  }

  Future<void> _pickCertificate() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: false,
    );

    final path = result?.files.single.path;
    if (path == null || path.trim().isEmpty) return;

    setState(() {
      _pickedCertificate = File(path);
      _certificateController.text =
          result?.files.single.name ?? path.split('/').last;
    });
  }

  Map<String, dynamic> _buildFields() {
    final fields = <String, dynamic>{};

    final docId = _asInt(_documentTypeId);
    if (docId != null) fields['document_type_id'] = docId;

    final wnId = _asInt(_workNatureId);
    if (wnId != null) fields['work_nature_id'] = wnId;

    final firm = _previousFirmController.text.trim();
    if (firm.isNotEmpty) fields['previous_firm'] = firm;

    final durationRaw = _durationController.text.replaceAll(',', '').trim();
    if (durationRaw.isNotEmpty) {
      final n = num.tryParse(durationRaw);
      if (n != null) {
        fields['work_duration'] = n;
        fields['work_duration_frequency'] = _durationFrequency;
      }
    }

    return fields;
  }

  Future<void> _submit() async {
    final isEditing = widget.experienceId != null;

    final fields = _buildFields();
    if (_asInt(_workNatureId) == null) {
      _snack('profile.flow.please_select_nature_of_work'.tr());
      return;
    }

    if (_previousFirmController.text.trim().isEmpty) {
      _snack('profile.flow.previous_firm_required'.tr());
      return;
    }

    final durationRaw = _durationController.text.replaceAll(',', '').trim();
    if (durationRaw.isEmpty || num.tryParse(durationRaw) == null) {
      _snack('profile.flow.duration_of_work_required'.tr());
      return;
    }

    if (isEditing) {
      await context.read<EmployeesProvider>().updateExperience(
        employeeId: widget.employeeId,
        experienceId: widget.experienceId!,
        fields: fields,
        certificateFile: _pickedCertificate,
      );
      await AccountStatusGuard.handleIfInactive(context);

      if (!mounted) return;
      final stillLoggedIn = SharedPrefUtils.readBool(
        SharedPrefUtils.AUTH_LOGGED_IN,
      );
      if (!stillLoggedIn) return;
    } else {
      await context.read<EmployeesProvider>().createExperience(
        employeeId: widget.employeeId,
        fields: fields,
        certificateFile: _pickedCertificate,
      );
      await AccountStatusGuard.handleIfInactive(context);

      if (!mounted) return;
      final stillLoggedIn = SharedPrefUtils.readBool(
        SharedPrefUtils.AUTH_LOGGED_IN,
      );
      if (!stillLoggedIn) return;
    }

    if (!mounted) return;
    widget.onButtonClicked();
  }

  @override
  void dispose() {
    _previousFirmController.dispose();
    _durationController.dispose();
    _certificateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.experienceId != null;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                FutureBuilder<List<DocumentTypeDto>>(
                  future: _documentTypesFuture,
                  builder: (context, snapshot) {
                    final items = _docTypesToItems(snapshot.data ?? const []);
                    return AppDropdown(
                      title: 'profile.flow.select_document_type'.tr(),
                      optional: true,
                      items: items,
                      valueId: _documentTypeId,
                      hint: 'profile.flow.select_document_type_hint'.tr(),
                      onChanged: (idName) =>
                          setState(() => _documentTypeId = idName?.id),
                    );
                  },
                ),
                SizedBox(height: context.spacing.sm),
                FutureBuilder<List<WorkNatureDto>>(
                  future: _workNaturesFuture,
                  builder: (context, snapshot) {
                    final items = _workNaturesToItems(
                      snapshot.data ?? const [],
                    );
                    return AppDropdown(
                      title: 'profile.flow.nature_of_work'.tr(),
                      items: items,
                      valueId: _workNatureId,
                      hint: 'profile.flow.nature_of_work_hint'.tr(),
                      searchable: true,
                      onChanged: (idName) =>
                          setState(() => _workNatureId = idName?.id),
                    );
                  },
                ),
                SizedBox(height: context.spacing.sm),
                LabeledFormField(
                  title: 'profile.flow.previous_firm'.tr(),
                  hintText: 'profile.flow.previous_firm_hint'.tr(),
                  optional: !_requiresPreviousJobDetails,
                  controller: _previousFirmController,
                ),
                SizedBox(height: context.spacing.sm),
                ExpectedSalaryField<String>(
                  title: 'profile.flow.duration_of_work'.tr(),
                  hintText: 'profile.flow.duration_of_work_hint'.tr(),
                  maxLength: 2,
                  amountController: _durationController,
                  selectedValue: _durationFrequency,
                  onChanged: (freq) =>
                      setState(() => _durationFrequency = freq),
                  options: const ['months', 'years'],
                  labelBuilder: (s) => I18nTerms.fromRaw(context, s),
                  optional: !_requiresPreviousJobDetails,
                ),
                SizedBox(height: context.spacing.sm),
                LabeledFormField(
                  title: 'profile.flow.upload_document'.tr(),
                  hintText: 'profile.flow.choose_file_upload'.tr(),
                  ifAny: true,
                  controller: _certificateController,
                  prefixIcon: XIcon(AppIcon.attachment),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _pickedCertificate = null;
                        _certificateController.text = '';
                      });
                    },
                    icon: XIcon(AppIcon.clear),
                  ),
                  readOnly: true,
                  onTap: _pickCertificate,
                ),
                if (_existingCertificateUrl != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () async {
                        final uri = Uri.tryParse(_existingCertificateUrl!);
                        if (uri == null) return;
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      child: Text('profile.flow.view_document'.tr()),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (widget.showAdd) ...[
          SizedBox(height: context.spacing.sm),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.onPrimary,
                    foregroundColor: context.colors.primary,
                    side: BorderSide(color: context.colors.primary),
                    elevation: 0,
                  ),
                  onPressed: widget.onButtonClicked,
                  child: Text(
                    isEditing ? 'common.cancel'.tr() : 'common.skip'.tr(),
                  ),
                ),
              ),
              SizedBox(width: context.spacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(
                    isEditing
                        ? 'common.save'.tr()
                        : 'profile.flow.add_experience'.tr(),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing.sm),
        ],
      ],
    );
  }
}
