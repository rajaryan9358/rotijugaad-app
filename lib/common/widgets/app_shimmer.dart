import 'package:flutter/material.dart';

import 'shimmer_loading.dart';

Color _resolvedShimmerBase(ColorScheme scheme) {
  // Many parts of the app use a custom ColorScheme that may not specify
  // Material 3 container tones. In that case, surfaceContainer* can collapse
  // to `surface`, making shimmers effectively invisible on white surfaces.
  final base = scheme.surfaceContainerHighest;
  final highlight = scheme.surfaceContainerHigh;

  final containersCollapseToSurface =
      base == scheme.surface && highlight == scheme.surface;
  if (containersCollapseToSurface) return scheme.outline;

  return base;
}

Color _resolvedShimmerHighlight(ColorScheme scheme) {
  final base = scheme.surfaceContainerHighest;
  final highlight = scheme.surfaceContainerHigh;

  final containersCollapseToSurface =
      base == scheme.surface && highlight == scheme.surface;
  if (containersCollapseToSurface) {
    return Color.lerp(scheme.outline, scheme.surface, 0.6) ?? scheme.surface;
  }

  return highlight;
}

class AppShimmer extends StatelessWidget {
  final Widget child;
  final Duration period;

  const AppShimmer({
    super.key,
    required this.child,
    this.period = const Duration(milliseconds: 1200),
  });

  Color _baseColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _resolvedShimmerBase(scheme);
  }

  Color _highlightColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _resolvedShimmerHighlight(scheme);
  }

  @override
  Widget build(BuildContext context) {
    final base = _baseColor(context);
    final highlight = _highlightColor(context);

    return ShimmerLoading(
      baseColor: base,
      highlightColor: highlight,
      period: period,
      child: child,
    );
  }
}

class AppShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  const AppShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ShimmerBox(
      width: width,
      height: height,
      borderRadius: borderRadius,
      color: _resolvedShimmerBase(scheme),
    );
  }
}
