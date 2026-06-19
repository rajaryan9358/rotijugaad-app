import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/dialogs/primary_dialog.dart';
import '../../common/widgets/toolbar.dart';
import '../../common/widgets/app_button_child.dart';
import '../../common/widgets/app_shimmer_placeholders.dart';
import '../../masters/models/misc_dtos.dart';
import '../../masters/providers/masters_provider.dart';
import '../../theme/context_ext.dart';
import '../../utils/custom_exception.dart';
import '../providers/job_details_provider.dart';

class CallExperienceScreen extends StatefulWidget {
  final int jobId;
  final int employeeId;
  final JobDetailsProvider? provider;

  const CallExperienceScreen({
    super.key,
    required this.jobId,
    required this.employeeId,
    this.provider,
  });

  @override
  State<StatefulWidget> createState() => _CallExperienceScreenState();
}

class _CallExperienceScreenState extends State<CallExperienceScreen> {
  bool _isLoading = false;
  CustomException? _error;

  List<CallExperienceDto> _options = const [];
  int? _selectedId;

  final TextEditingController _commentController = TextEditingController();

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

  String _label(CallExperienceDto dto) {
    final en = (dto.experienceEnglish ?? '').trim();
    final hi = (dto.experienceHindi ?? '').trim();
    return en.isNotEmpty ? en : (hi.isNotEmpty ? hi : 'Option #${dto.id}');
  }

  Future<void> _loadOptions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final masters = context.read<MastersProvider>();
      final list = await masters.getEmployeeCallExperiencesFromDb();
      if (!mounted) return;
      setState(() {
        _options = list;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = CustomException(
          code: 'MASTERS',
          message: 'Failed to load call experiences: $e',
        );
      });
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _submit() async {
    final provider = widget.provider ?? context.read<JobDetailsProvider>();

    final ok = await provider.saveContactCallExperience(
      jobId: widget.jobId,
      employeeId: widget.employeeId,
      callExperienceId: _selectedId,
      review: _commentController.text,
    );

    if (!mounted) return;

    if (!ok) {
      _showSnack(
        provider.lastError?.message ?? 'Failed to submit call experience',
      );
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) =>
          const PrimaryDialog('Call experience submitted successfully'),
    );

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;

    Widget content() {
      return Consumer<JobDetailsProvider>(
        builder: (context, provider, _) {
          final isSubmitting = provider.isActionLoading;

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
                      margin: EdgeInsets.symmetric(
                        horizontal: context.spacing.md,
                      ),
                      child: _isLoading
                          ? const AppFormShimmer()
                          : (_error != null)
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _error?.message ?? 'Failed to load options',
                                    style: context.text.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: context.spacing.md),
                                  ElevatedButton(
                                    onPressed: _loadOptions,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Share your call experience',
                                  style: context.text.bodyMedium!.copyWith(
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: context.spacing.md),
                                if (_options.isEmpty)
                                  Text(
                                    'No options available.',
                                    style: context.text.bodyMedium,
                                  )
                                else
                                  GridView.builder(
                                    itemCount: _options.length,
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
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
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          decoration: BoxDecoration(
                                            color: selected
                                                ? context.colors.primary
                                                : context.colors.surface,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: selected
                                                  ? context.colors.primary
                                                  : context.colors.outline,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            _label(item),
                                            textAlign: TextAlign.center,
                                            style: context.text.bodySmall!
                                                .copyWith(
                                                  color: selected
                                                      ? context.colors.onPrimary
                                                      : context
                                                            .colors
                                                            .onSurface,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                SizedBox(height: context.spacing.md),
                                Text(
                                  'Add detailed review',
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
                                    hintText: 'Add comments',
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
                            onPressed: isSubmitting ? null : _submit,
                            child: AppButtonChild(
                              label: 'Submit',
                              isLoading: isSubmitting,
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
        },
      );
    }

    if (provider != null) {
      return ChangeNotifierProvider<JobDetailsProvider>.value(
        value: provider,
        child: content(),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => JobDetailsProvider(),
      child: content(),
    );
  }
}
