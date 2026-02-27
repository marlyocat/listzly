import 'package:flutter/material.dart';

class Responsive {
  Responsive._();

  static const double tabletBreakpoint = 600.0;
  static const double maxContentWidth = 500.0;

  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).shortestSide >= tabletBreakpoint;
  }
}

/// Constrains child to [maxWidth] and centers it. No-op on phones.
class ContentConstraint extends StatelessWidget {
  final double maxWidth;
  final Widget child;

  const ContentConstraint({
    super.key,
    this.maxWidth = Responsive.maxContentWidth,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Drop-in replacement for SliverToBoxAdapter that constrains width on tablets.
class SliverContentConstraint extends StatelessWidget {
  final double maxWidth;
  final Widget child;

  const SliverContentConstraint({
    super.key,
    this.maxWidth = Responsive.maxContentWidth,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
