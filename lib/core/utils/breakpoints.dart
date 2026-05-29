import 'package:flutter/material.dart';

/// Breakpoint helpers for responsive layouts.
class Breakpoints {
  static const double desktop = 900;
  static const double tablet = 600;
}

extension BreakpointContext on BuildContext {
  bool get isDesktop => MediaQuery.sizeOf(this).width >= Breakpoints.desktop;
  bool get isTablet => MediaQuery.sizeOf(this).width >= Breakpoints.tablet;
  double get screenWidth => MediaQuery.sizeOf(this).width;
}
