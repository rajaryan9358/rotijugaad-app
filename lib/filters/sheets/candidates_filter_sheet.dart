import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rotijugaad/theme/context_ext.dart';

import '../../common/widgets/labeled_form_field.dart';
import '../../common/widgets/xicon.dart';
import '../../theme/app_icons.dart';
import '../models/filter_section.dart';

class CandidatesFilterSheet extends StatefulWidget {
  final List<FilterSection> sections;
  final Map<String, Set<String>> initial;
  const CandidatesFilterSheet({required this.sections, required this.initial});

  @override
  State<StatefulWidget> createState() => _CandidatesFilterSheetState();
}

class _CandidatesFilterSheetState extends State<CandidatesFilterSheet> {
  late int _activeIndex;
  late Map<String, Set<String>> _selected;
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _activeIndex = 0;
    _searchController = TextEditingController();
    _selected = {
      for (final s in widget.sections) s.id: {...(widget.initial[s.id] ?? {})},
    };
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _selectionCount(String sectionId) => _selected[sectionId]?.length ?? 0;

  FilterSection _sectionById(String sectionId) {
    return widget.sections.firstWhere((section) => section.id == sectionId);
  }

  void _setActiveIndex(int index) {
    setState(() {
      _activeIndex = index;
      _query = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final txt = Theme.of(context).textTheme;
    final radius = const Radius.circular(16);

    final section = widget.sections[_activeIndex];
    final all = section.options;
    final filtered = _query.isEmpty
        ? all
        : all
              .where(
                (o) => o.label.toLowerCase().contains(_query.toLowerCase()),
              )
              .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollCtrl) {
        return Material(
          color: cs.surface,
          elevation: 8,
          borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
                  child: Row(
                    children: [
                      Text(
                        'filters.advance_filter'.tr(),
                        style: txt.titleMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: context.xcolors.stroke),

                Expanded(
                  child: Row(
                    children: [
                      // left menu
                      SizedBox(
                        width: 140,
                        child: ListView.separated(
                          controller: scrollCtrl,
                          itemCount: widget.sections.length,
                          separatorBuilder: (_, __) => SizedBox(),
                          itemBuilder: (_, i) {
                            final s = widget.sections[i];
                            final bool active = i == _activeIndex;
                            final selectedCount = _selectionCount(s.id);
                            return InkWell(
                              onTap: () => _setActiveIndex(i),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        s.title.tr(),
                                        style: txt.bodyMedium?.copyWith(
                                          color: active
                                              ? cs.primary
                                              : cs.onSurface,
                                          fontWeight: active
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (selectedCount > 0) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: active
                                              ? cs.primary
                                              : cs.secondaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Text(
                                          '$selectedCount',
                                          style: txt.labelSmall?.copyWith(
                                            color: active
                                                ? cs.onPrimary
                                                : cs.onSecondaryContainer,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      Container(width: 1, color: context.xcolors.stroke),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // search
                              LabeledFormField(
                                title: '',
                                hintText: 'filters.search'.tr(),
                                prefixIcon: XIcon(AppIcon.search),
                                controller: _searchController,
                                onChanged: (value) {
                                  setState(() {
                                    _query = value.trim().toLowerCase();
                                  });
                                },
                              ),
                              const SizedBox(height: 12),

                              Expanded(
                                child: ListView.separated(
                                  itemCount: filtered.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 4),
                                  itemBuilder: (_, i) {
                                    final opt = filtered[i];
                                    final isChecked = _selected[section.id]!
                                        .contains(opt.id);
                                    return InkWell(
                                      onTap: () => _toggle(section.id, opt.id),
                                      child: Row(
                                        children: [
                                          Checkbox(
                                            value: isChecked,
                                            onChanged: (_) =>
                                                _toggle(section.id, opt.id),
                                            activeColor: cs.primary,
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            visualDensity: const VisualDensity(
                                              horizontal: -4,
                                              vertical: -2,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              opt.label,
                                              style: txt.bodyMedium?.copyWith(
                                                fontWeight: isChecked
                                                    ? FontWeight.w600
                                                    : FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: context.xcolors.stroke),
                SizedBox(height: context.spacing.md),
                Container(
                  color: context.colors.onPrimary,
                  margin: EdgeInsets.symmetric(horizontal: context.spacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _clearAllAndClose,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: cs.primary),
                          ),
                          child: Text(
                            'filters.clear'.tr(),
                            style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, _selected),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text('filters.apply'.tr()),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.spacing.md),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggle(String sectionId, String optionId) {
    final set = _selected[sectionId]!;
    final section = _sectionById(sectionId);

    if (section.singleSelect) {
      if (set.contains(optionId)) {
        set.clear();
      } else {
        set
          ..clear()
          ..add(optionId);
      }
    } else {
      set.contains(optionId) ? set.remove(optionId) : set.add(optionId);
    }

    setState(() {});
  }

  void _clearActive() {
    for (final section in widget.sections) {
      _selected[section.id]?.clear();
    }
    _query = '';
    _searchController.clear();
    if (!mounted) return;
    Navigator.pop(context, _selected);
  }

  void _clearAllAndClose() => _clearActive();
}
