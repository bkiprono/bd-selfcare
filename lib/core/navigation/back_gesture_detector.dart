import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A full-screen back gesture detector for iOS-like navigation.
/// Allows swiping from anywhere on the screen to go back.
class FullScreenBackGestureDetector<T> extends StatefulWidget {
  const FullScreenBackGestureDetector({
    super.key,
    required this.child,
    required this.onBackGestureStarted,
    required this.onBackGestureUpdated,
    required this.onBackGestureEnded,
    required this.enabledCallback,
  });

  final Widget child;
  final VoidCallback onBackGestureStarted;
  final ValueChanged<double> onBackGestureUpdated;
  final ValueChanged<double> onBackGestureEnded;
  final ValueGetter<bool> enabledCallback;

  @override
  State<FullScreenBackGestureDetector<T>> createState() =>
      _FullScreenBackGestureDetectorState<T>();
}

class _FullScreenBackGestureDetectorState<T>
    extends State<FullScreenBackGestureDetector<T>> {
  HorizontalDragGestureRecognizer? _recognizer;

  @override
  void initState() {
    super.initState();
    _recognizer = HorizontalDragGestureRecognizer(debugOwner: this)
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..onCancel = _handleDragCancel;
  }

  @override
  void dispose() {
    _recognizer?.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    widget.onBackGestureStarted();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    // Normalize drag distance based on screen width
    widget.onBackGestureUpdated(
      details.primaryDelta! / MediaQuery.of(context).size.width,
    );
  }

  void _handleDragEnd(DragEndDetails details) {
    widget.onBackGestureEnded(
      details.velocity.pixelsPerSecond.dx / MediaQuery.of(context).size.width,
    );
  }

  void _handleDragCancel() {
    widget.onBackGestureEnded(0.0);
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (widget.enabledCallback()) {
      _recognizer?.addPointer(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handlePointerDown,
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}

/// A wrapper that manages the back gesture animation controller.
class FullScreenBackGestureWrapper<T> extends StatelessWidget {
  const FullScreenBackGestureWrapper({
    super.key,
    required this.child,
    required this.route,
  });

  final Widget child;
  final PageRoute<T> route;

  @override
  Widget build(BuildContext context) {
    return FullScreenBackGestureDetector<T>(
      enabledCallback: () => _isPopGestureEnabled(route),
      onBackGestureStarted: () => _handleBackGestureStarted(route),
      onBackGestureUpdated: (double delta) => _handleBackGestureUpdated(route, delta),
      onBackGestureEnded: (double velocity) => _handleBackGestureEnded(route, velocity),
      child: child,
    );
  }

  static bool _isPopGestureEnabled<T>(PageRoute<T> route) {
    // Disable if there is no previous route or it's being popped
    if (route.isFirst || route.willHandlePopInternally) {
      return false;
    }
    // Disable if the route specifically disallows it
    if (route.popGestureInProgress) {
      return false;
    }
    return true;
  }

  static void _handleBackGestureStarted<T>(PageRoute<T> route) {
    route.navigator?.didStartUserGesture();
  }

  static void _handleBackGestureUpdated<T>(PageRoute<T> route, double delta) {
    // The animation controller for the route.
    // We need to proxy the drag to the animation.
    final controller = route.controller;
    if (controller != null) {
      controller.value -= delta;
    }
  }

  static void _handleBackGestureEnded<T>(PageRoute<T> route, double velocity) {
    final controller = route.controller;
    if (controller == null) return;

    if (velocity > 1.0 || (velocity >= 0.0 && controller.value < 0.5)) {
      // Complete the pop
      controller.reverse().then((_) {
        // Only pop if we actually reversed the animation to completion
        if (controller.status == AnimationStatus.dismissed) {
          route.navigator?.pop();
        }
      });
    } else {
      // Cancel the pop, snap back to full screen
      controller.forward();
    }
    route.navigator?.didStopUserGesture();
  }
}
