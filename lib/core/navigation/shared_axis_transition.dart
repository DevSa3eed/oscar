import 'package:flutter/material.dart';

/// Shared Axis Transition - Clean, professional transitions with fade + scale + directional motion
/// Similar to Microsoft's design language for unified app experience
///
/// Usage with AutoRoute:
/// CustomRoute(
///   page: YourPage,
///   transitionsBuilder: sharedAxisTransition,
///   durationInMilliseconds: 280,
/// )
Widget sharedAxisTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  // Simple fade transition to avoid GlobalKey conflicts
  // The Stack approach was causing both pages to be in the tree simultaneously

  // Forward animation: fade in with subtle scale
  final fadeAnimation = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOut,
  );

  final scaleAnimation = Tween<double>(
    begin: 0.95,
    end: 1.0,
  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

  // Only render the incoming page to avoid GlobalKey conflicts
  return FadeTransition(
    opacity: fadeAnimation,
    child: ScaleTransition(scale: scaleAnimation, child: child),
  );
}
