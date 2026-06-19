import 'filter_option.dart';

class FilterSection {
  final String id;
  final String title;
  final List<FilterOption> options;
  final bool singleSelect;

  FilterSection({
    required this.id,
    required this.title,
    required this.options,
    this.singleSelect = false,
  });
}
