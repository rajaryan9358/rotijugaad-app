import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/auth/utils/account_status_guard.dart';
import 'package:rotijugaad/utils/shared_pref.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rotijugaad/common/models/id_name.dart';
import 'package:rotijugaad/common/widgets/app_dropdown.dart';
import 'package:rotijugaad/editprofile/widgets/add_document_item.dart';
import 'package:rotijugaad/editprofile/widgets/added_document_item.dart';
import 'package:rotijugaad/employees/providers/employees_provider.dart';
import 'package:rotijugaad/masters/models/document_dtos.dart';
import 'package:rotijugaad/masters/providers/masters_provider.dart';
import 'package:rotijugaad/common/dialogs/primary_dialog.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class DocumentsScreen extends StatefulWidget {
  final int employeeId;
  final VoidCallback onButtonClicked;
  final bool showContinueActions;

  const DocumentsScreen({
    super.key,
    required this.employeeId,
    required this.onButtonClicked,
    this.showContinueActions = true,
  });

  @override
  State<StatefulWidget> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  bool _futuresInitialized = false;
  bool _isSubmittingForReview = false;
  late Future<List<DocumentTypeDto>> _documentTypesFuture;

  String? _documentTypeId;
  File? _selectedFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeesProvider>().fetchDocuments(widget.employeeId);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_futuresInitialized) return;
    _futuresInitialized = true;

    final masters = context.read<MastersProvider>();
    _documentTypesFuture = () async {
      await masters.loadMasters();
      return masters.getAdditionalDocumentTypesFromDb();
    }();
  }

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

  String _bytesLabel(int? bytes) {
    final b = bytes ?? 0;
    if (b <= 0) return '';
    if (b < 1024) return '$b B';
    final kb = b / 1024.0;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024.0;
    return '${mb.toStringAsFixed(1)} MB';
  }

  Future<File?> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: false,
    );
    final path = result?.files.single.path;
    if (path == null || path.trim().isEmpty) return null;
    return File(path);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<bool> _confirmDeleteDocument() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('common.delete'.tr()),
        content: Text('profile.flow.delete_experience_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('common.delete'.tr()),
          ),
        ],
      ),
    );

    return result == true;
  }

  Future<void> _handleSelectFile() async {
    final picked = await _pickFile();
    if (picked == null || !mounted) return;
    setState(() => _selectedFile = picked);
  }

  Future<void> _handleUploadDocument(int typeId, File file) async {
    setState(() => _isUploading = true);
    final provider = context.read<EmployeesProvider>();
    await provider.uploadDocument(
      employeeId: widget.employeeId,
      documentTypeId: typeId,
      file: file,
    );
    if (!mounted) return;
    await AccountStatusGuard.handleIfInactive(context);
    if (!mounted) return;
    final stillLoggedIn = SharedPrefUtils.readBool(SharedPrefUtils.AUTH_LOGGED_IN);
    if (!stillLoggedIn) return;
    setState(() {
      _isUploading = false;
      _selectedFile = null;
      _documentTypeId = null;
    });
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => PrimaryDialog(
        'profile.additional_documents.document_uploaded_success'.tr(),
      ),
    );
  }

  Future<void> _handleDeleteDocument(int docId) async {
    final shouldDelete = await _confirmDeleteDocument();
    if (!shouldDelete || !mounted) return;

    final provider = context.read<EmployeesProvider>();
    await provider.deleteDocument(docId, employeeId: widget.employeeId);
    if (!mounted) return;
    await AccountStatusGuard.handleIfInactive(context);
    if (!mounted) return;
    final stillLoggedIn = SharedPrefUtils.readBool(SharedPrefUtils.AUTH_LOGGED_IN);
    if (!stillLoggedIn) return;
  }

  Future<void> _openDocument(String? link) async {
    final raw = (link ?? '').trim();
    if (raw.isEmpty) {
      _snack('common.link_unavailable'.tr(args: ['Document']));
      return;
    }

    final uri = Uri.tryParse(raw);
    if (uri == null) {
      _snack('common.could_not_open_link'.tr(args: ['Document']));
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      _snack('common.could_not_open_link'.tr(args: ['Document']));
    }
  }

  Future<void> _submitForReviewAndContinue() async {
    if (_isSubmittingForReview) return;

    setState(() => _isSubmittingForReview = true);

    final provider = context.read<EmployeesProvider>();
    final submitted = await provider.submitProfileForReview(widget.employeeId);

    if (!mounted) return;

    setState(() => _isSubmittingForReview = false);

    if (!submitted) {
      _snack(provider.lastError?.message ?? 'Unable to submit profile');
      return;
    }

    widget.onButtonClicked();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmployeesProvider>(
      builder: (context, provider, _) {
        final documents = provider.documents;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'profile.additional_documents.upload_new_document'.tr(),
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colors.primary,
                      ),
                    ),
                    SizedBox(height: context.spacing.sm),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(context.spacing.sm),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(context.radii.sm),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Text(
                        'profile.additional_documents.note'.tr(),
                        style: context.text.bodySmall!.copyWith(
                          color: const Color(0xFF92400E),
                        ),
                      ),
                    ),
                    SizedBox(height: context.spacing.md),
                    FutureBuilder<List<DocumentTypeDto>>(
                      future: _documentTypesFuture,
                      builder: (context, snapshot) {
                        final items = _docTypesToItems(
                          snapshot.data ?? const [],
                        );
                        return AppDropdown(
                          title:
                              'profile.additional_documents.select_document_type'
                                  .tr(),
                          items: items,
                          valueId: _documentTypeId,
                          hint:
                              'profile.additional_documents.select_document_type_hint'
                                  .tr(),
                          onChanged: (idName) =>
                              setState(() => _documentTypeId = idName?.id),
                        );
                      },
                    ),
                    SizedBox(height: context.spacing.sm),
                    AddDocumentItem(
                      _selectedFile != null
                          ? _selectedFile!.path.split('/').last
                          : 'profile.additional_documents.no_file_selected'.tr(),
                      onTap: _handleSelectFile,
                    ),
                    SizedBox(height: context.spacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isUploading
                            ? null
                            : () {
                                final typeId = _asInt(_documentTypeId);
                                final file = _selectedFile;
                                if (typeId == null) {
                                  _snack(
                                    'profile.additional_documents.please_select_document_type'
                                        .tr(),
                                  );
                                  return;
                                }
                                if (file == null) {
                                  _snack(
                                    'profile.additional_documents.no_file_selected'
                                        .tr(),
                                  );
                                  return;
                                }
                                _handleUploadDocument(typeId, file);
                              },
                        child: _isUploading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'profile.additional_documents.upload_document_btn'
                                    .tr(),
                              ),
                      ),
                    ),
                    if (documents.isNotEmpty) ...[
                      SizedBox(height: context.spacing.lg),
                      Text(
                        'profile.additional_documents.uploaded_documents'.tr(),
                        style: context.text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.primary,
                        ),
                      ),
                      SizedBox(height: context.spacing.sm),
                      ListView.separated(
                        itemCount: documents.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (context, index) =>
                            SizedBox(height: context.spacing.sm),
                        itemBuilder: (context, index) {
                          final doc = documents[index];
                          final name = (doc.documentName ?? '').trim();
                          final title = name.isEmpty
                              ? 'profile.flow.document'.tr()
                              : name;

                          final size = _bytesLabel(doc.documentSize);
                          final dt = _pickLang(
                            doc.documentTypeMeta?.typeEnglish,
                            doc.documentTypeMeta?.typeHindi,
                          );
                          final subtitle = [
                            if (dt.trim().isNotEmpty) dt.trim(),
                            if (size.trim().isNotEmpty) size.trim(),
                          ].join(' • ');

                          return AddedDocumentItem(
                            title: title,
                            subtitle: subtitle.isEmpty ? '-' : subtitle,
                            onTap: () => _openDocument(doc.documentLink),
                            onDelete: () => _handleDeleteDocument(doc.id),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (widget.showContinueActions) ...[
              SizedBox(height: context.spacing.md),
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
                      onPressed: _isSubmittingForReview
                          ? null
                          : _submitForReviewAndContinue,
                      child: Text('common.skip'.tr()),
                    ),
                  ),
                  SizedBox(width: context.spacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmittingForReview
                          ? null
                          : _submitForReviewAndContinue,
                      child: Text('common.next'.tr()),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.spacing.md),
            ],
          ],
        );
      },
    );
  }
}
