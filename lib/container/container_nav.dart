import 'package:flutter/foundation.dart';

/// Shared tab-switch signal for MainContainer / EmployerContainer.
/// Set [pendingTabIndex] to a non-null value to request a tab switch;
/// the container will consume it (reset to null) once applied.
class ContainerNav {
  ContainerNav._();

  static final ValueNotifier<int?> pendingTabIndex = ValueNotifier<int?>(null);

  static void switchTab(int index) {
    pendingTabIndex.value = index;
  }
}
