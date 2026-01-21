import 'dart:io';
import 'package:flutter/cupertino.dart';

/// Platform-adaptive page route that automatically uses:
/// - CupertinoPageRoute on iOS (with swipe-back gesture)
/// - MaterialPageRoute on Android (with system back button)
class AdaptivePageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  final String? title;

  AdaptivePageRoute({
    required this.builder,
    this.title,
    super.settings,
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration {
    if (Platform.isIOS) {
      return const Duration(milliseconds: 350);
    }
    return const Duration(milliseconds: 300);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (Platform.isIOS) {
      // iOS-style slide transition with swipe-back support
      return CupertinoPageTransition(
        primaryRouteAnimation: animation,
        secondaryRouteAnimation: secondaryAnimation,
        linearTransition: false,
        child: child,
      );
    }

    // Android-style fade + slide transition
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 0.1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          ),
        ),
        child: child,
      ),
    );
  }
}
