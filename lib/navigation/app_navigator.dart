import 'package:flutter/material.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

  static BuildContext? get context => navKey.currentState?.overlay?.context;
}
