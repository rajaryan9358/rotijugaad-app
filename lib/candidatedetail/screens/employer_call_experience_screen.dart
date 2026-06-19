import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import '../../common/dialogs/primary_dialog.dart';
import '../../common/widgets/toolbar.dart';
import '../../employers/services/employers_service.dart';
import '../../masters/models/misc_dtos.dart';
import '../../masters/providers/masters_provider.dart';
import '../../theme/context_ext.dart';
import '../../utils/custom_exception.dart';
import '../../utils/result.dart';
import '../../utils/shared_pref.dart';
import 'package:rotijugaad/common/widgets/app_button_child.dart';
import 'package:rotijugaad/common/widgets/app_shimmer_placeholders.dart';

class EmployerCallExperienceScreen extends StatefulWidget {
  final int candidateId;

  const EmployerCallExperienceScreen({super.key, required this.candidateId});

  @override
  State<StatefulWidget> createState() => _EmployerCallExperienceScreenState();
}

class _EmployerCallExperienceScreenState
    extends State<EmployerCallExperienceScreen> {
  final EmployersService _service = EmployersService();

  bool _isLoading = false;
  CustomException? _error;

  List<CallExperienceDto> _options = const [];
  int? _selectedId;

  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    final t = message.trim();
    if (t.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Future<void> _loadOptions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final masters = context.read<MastersProvider>();
      final list = await masters.getEmployerCallExperiencesFromDb();
      if (!mounted) return;
      setState(() {
        _options = list;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = CustomException(
          code: 'MASTERS',
          message:
              '${'candidates.call_experience.failed_load_options'.tr()}: $e',
        );
      });
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  String _label(BuildContext context, CallExperienceDto dto) {
    final isHindi = context.locale.languageCode.toLowerCase() == 'hi';
    final en = (dto.experienceEnglish ?? '').trim();
    final hi = (dto.experienceHindi ?? '').trim();
    if (isHindi) {
      if (hi.isNotEmpty) return hi;
      if (en.isNotEmpty) return en;
    } else {
      if (en.isNotEmpty) return en;
      if (hi.isNotEmpty) return hi;
    }
    return 'candidates.call_experience.option_fallback'.tr(args: ['${dto.id}']);
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final employerId = SharedPrefUtils.readInt('auth_employer_id');
    if (employerId <= 0) {
      _showSnack('candidates.send_interest.no_employer_id'.tr());
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final result = await _service.saveEmployerCandidateCallExperience(
      employerId: employerId,
      candidateId: widget.candidateId,
      callExperienceId: _selectedId,
      review: _commentController.text,
    );

    if (!mounted) return;

    switch (result) {
      case Success():
        await showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (_) => PrimaryDialog(
            'candidates.call_experience.submitted_successfully'.tr(),
          ),
        );
        if (!mounted) return;
        Navigator.of(context).pop(true);
        break;
      case Failure(exception: final e):
        _showSnack(e.message);
        break;
    }

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.onPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Toolbar('', () {
              Navigator.of(context).pop();
            }),
            Divider(color: context.colors.secondaryContainer),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: context.spacing.md),
                child: _isLoading
                    ? const AppFormShimmer()
                    : (_error != null)
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _error?.message ??
                                  'candidates.call_experience.failed_load_options'
                                      .tr(),
                              style: context.text.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: context.spacing.md),
                            ElevatedButton(
                              onPressed: _loadOptions,
                              child: Text('common.retry'.tr()),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'candidates.call_experience.share_title'.tr(),
                            style: context.text.bodyMedium!.copyWith(
                              color: context.colors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: context.spacing.md),
                          if (_options.isEmpty)
                            Text(
                              'candidates.call_experience.no_options'.tr(),
                              style: context.text.bodyMedium,
                            )
                          else
                            GridView.builder(
                              itemCount: _options.length,
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 3.5,
                                  ),
                              itemBuilder: (context, index) {
                                final item = _options[index];
                                final selected = item.id == _selectedId;

                                return GestureDetector(
                                  onTap: () => setState(() {
                                    _selectedId = item.id;
                                  }),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? context.colors.primary
                                          : context.colors.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: selected
                                            ? context.colors.primary
                                            : context.colors.outline,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      _label(context, item),
                                      textAlign: TextAlign.center,
                                      style: context.text.bodySmall!.copyWith(
                                        color: selected
                                            ? context.colors.onPrimary
                                            : context.colors.onSurface,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          SizedBox(height: context.spacing.md),
                          Text(
                            'candidates.call_experience.add_review'.tr(),
                            style: context.text.bodyMedium!.copyWith(
                              color: context.colors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: context.spacing.sm),
                          TextFormField(
                            controller: _commentController,
                            minLines: 4,
                            maxLines: 6,
                            keyboardType: TextInputType.multiline,
                            style: context.text.bodyMedium,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                              hintText:
                                  'candidates.call_experience.add_comments'
                                      .tr(),
                              filled: true,
                              fillColor: context.colors.surface,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: context.spacing.md,
                                vertical: context.spacing.md,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  context.radii.md,
                                ),
                                borderSide: BorderSide(
                                  color: context.colors.outline,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  context.radii.md,
                                ),
                                borderSide: BorderSide(
                                  color: context.colors.primary,
                                  width: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.md,
                vertical: context.spacing.sm,
              ),
              child: Column(
                children: [
                  Divider(color: context.colors.secondaryContainer),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: AppButtonChild(
                        isLoading: _isSubmitting,
                        label: 'common.submit'.tr(),
                        loaderColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
