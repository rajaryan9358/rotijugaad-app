import 'package:flutter/material.dart';

class AppPageRoute {
  static PageRoute<T> slideFade<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 260),
    Duration reverseDuration = const Duration(milliseconds: 220),
    Curve curve = Curves.easeOutCubic,
    Offset beginOffset = const Offset(0.08, 0.0),
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: reverseDuration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: curve,
          reverseCurve: Curves.easeInCubic,
        );

        final slide = Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(curved);
        final fade = Tween<double>(begin: 0.0, end: 1.0).animate(curved);

        return SlideTransition(
          position: slide,
          child: FadeTransition(opacity: fade, child: child),
        );
      },
    );
  }
}
