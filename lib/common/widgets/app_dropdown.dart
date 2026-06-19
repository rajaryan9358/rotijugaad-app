import 'package:flutter/material.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import '../models/id_name.dart';
import 'form_label.dart';

class AppDropdown extends StatelessWidget {
  final String title;
  final List<IdName> items;
  final String? valueId;
  final ValueChanged<IdName?> onChanged;
  final String? hint;
  final bool optional;
  final bool enabled;
  final bool searchable;

  /// If inside a Row, set expand: true so it takes available width safely.
  final bool expand;

  const AppDropdown({
    super.key,
    required this.title,
    required this.items,
    required this.onChanged,
    this.valueId,
    this.hint,
    this.optional = false,
    this.enabled = true,
    this.searchable = false,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.text;

    final selected = items.firstWhere(
      (e) => e.id == valueId,
      orElse: () => const IdName(id: '', name: ''),
    );
    final hasValue = valueId != null && selected.id.isNotEmpty;

    final baseTextStyle = textTheme.bodyMedium!;
    final disabledTextColor = colors.onSurface.withOpacity(0.4);
    final enabledTextColor = colors.onPrimaryContainer;
    final effectiveHint = hint ?? 'Select option';

    InputDecoration buildDecoration() {
      return InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        filled: true,
        fillColor: enabled ? colors.surface : colors.surface.withOpacity(0.6),
        enabled: enabled,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primary),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: context.xcolors.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primary, width: 1.4),
        ),
      );
    }

    final field = searchable
        ? _SearchableDropdownField(
            title: title,
            items: items,
            selected: hasValue ? selected : null,
            onChanged: onChanged,
            enabled: enabled,
            hint: effectiveHint,
            baseTextStyle: baseTextStyle,
            enabledTextColor: enabledTextColor,
            disabledTextColor: disabledTextColor,
            decoration: buildDecoration(),
          )
        : DropdownButtonFormField<IdName>(
            value: hasValue ? selected : null,
            isExpanded: true,

            style: baseTextStyle.copyWith(
              color: enabled ? enabledTextColor : disabledTextColor,
            ),

            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: enabled
                  ? colors.onSurface
                  : colors.onSurface.withOpacity(0.3),
            ),

            hint: Text(
              effectiveHint,
              style: baseTextStyle.copyWith(
                color: enabled ? colors.onPrimaryContainer : disabledTextColor,
              ),
            ),

            disabledHint: hasValue
                ? Text(
                    selected.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: baseTextStyle.copyWith(color: disabledTextColor),
                  )
                : Text(
                    effectiveHint,
                    style: baseTextStyle.copyWith(color: disabledTextColor),
                  ),

            items: items.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    e.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
              );
            }).toList(),

            onChanged: enabled ? onChanged : null,
            decoration: buildDecoration(),
          );

    Widget constrainedField = field;
    if (expand) {
      constrainedField = Expanded(child: constrainedField);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormLabel(title, optional: optional),
          const SizedBox(height: 6),
          constrainedField,
        ],
      ),
    );
  }
}

class _SearchableDropdownField extends StatelessWidget {
  final String title;
  final List<IdName> items;
  final IdName? selected;
  final ValueChanged<IdName?> onChanged;
  final bool enabled;
  final String hint;
  final TextStyle baseTextStyle;
  final Color enabledTextColor;
  final Color disabledTextColor;
  final InputDecoration decoration;

  const _SearchableDropdownField({
    required this.title,
    required this.items,
    required this.selected,
    required this.onChanged,
    required this.enabled,
    required this.hint,
    required this.baseTextStyle,
    required this.enabledTextColor,
    required this.disabledTextColor,
    required this.decoration,
  });

  Future<void> _openPicker(BuildContext context) async {
    if (!enabled) return;

    final picked = await showModalBottomSheet<IdName>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.onPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _SearchableDropdownSheet(
        title: title,
        items: items,
        selectedId: selected?.id,
      ),
    );

    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => _openPicker(context) : null,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        isEmpty: selected == null,
        decoration: decoration.copyWith(
          suffixIcon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: enabled
                ? context.colors.onSurface
                : context.colors.onSurface.withOpacity(0.3),
          ),
        ),
        child: Text(
          selected?.name ?? hint,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: baseTextStyle.copyWith(
            color: enabled
                ? (selected == null ? enabledTextColor : enabledTextColor)
                : disabledTextColor,
          ),
        ),
      ),
    );
  }
}

class _SearchableDropdownSheet extends StatefulWidget {
  final String title;
  final List<IdName> items;
  final String? selectedId;

  const _SearchableDropdownSheet({
    required this.title,
    required this.items,
    required this.selectedId,
  });

  @override
  State<_SearchableDropdownSheet> createState() =>
      _SearchableDropdownSheetState();
}

class _SearchableDropdownSheetState extends State<_SearchableDropdownSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.text;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final query = _searchController.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? widget.items
        : widget.items
              .where((e) => e.name.toLowerCase().contains(query))
              .toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: MaterialLocalizations.of(
                      context,
                    ).searchFieldLabel,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No results found',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onSurface.withOpacity(0.7),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final isSelected = item.id == widget.selectedId;
                          return ListTile(
                            title: Text(
                              item.name,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check, color: colors.primary)
                                : null,
                            onTap: () => Navigator.of(context).pop(item),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
