import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A production-ready full-screen back gesture detector for iOS-like navigation.
/// Allows swiping from anywhere on the screen to go back with premium physics.
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
  bool _wasGestureStarted = false;
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
    _wasGestureStarted = true;
    HapticFeedback.lightImpact(); // Tactile feedback on start
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_wasGestureStarted) return;
    // Normalize drag distance based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 0) {
      widget.onBackGestureUpdated(details.primaryDelta! / screenWidth);
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_wasGestureStarted) return;
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 0) {
      widget.onBackGestureEnded(
        details.velocity.pixelsPerSecond.dx / screenWidth,
      );
    }
    _wasGestureStarted = false;
  }

  void _handleDragCancel() {
    if (!_wasGestureStarted) return;
    widget.onBackGestureEnded(0.0);
    _wasGestureStarted = false;
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

/// A premium wrapper that manages the back gesture animation controller with spring physics.
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
    // Basic connectivity and state guards
    if (route.navigator == null || route.isFirst || route.willHandlePopInternally) {
      return false;
    }
    
    // Disable if the gesture is already in progress or if the route is being disposed
    if (route.popGestureInProgress || !route.isActive) {
      return false;
    }
    
    return true;
  }

  static void _handleBackGestureStarted<T>(PageRoute<T> route) {
    route.navigator?.didStartUserGesture();
  }

  static void _handleBackGestureUpdated<T>(PageRoute<T> route, double delta) {
    final controller = (route as dynamic).controller as AnimationController?;
    if (controller != null && controller.isAnimating == false) {
      // Direct proxy of drag to animation value
      controller.value = (controller.value - delta).clamp(0.0, 1.0);
    }
  }

  static void _handleBackGestureEnded<T>(PageRoute<T> route, double velocity) {
    final controller = (route as dynamic).controller as AnimationController?;
    if (controller == null) return;

    // Premium snapping logic: 
    // - If flipped fast enough (> 1.0 normalized velocity), always complete.
    // - Otherwise, check if we've crossed the halfway mark.
    final bool shouldPop = velocity > 1.0 || (velocity >= 0.0 && controller.value < 0.5);

    if (shouldPop) {
      // Crossing threshold haptic
      if (controller.value > 0.1) {
         HapticFeedback.mediumImpact();
      }
      
      // Use fling for a natural "thrown" feeling if velocity is available
      final TickerFuture future = velocity > 0.0 
          ? controller.fling(velocity: -velocity) 
          : controller.reverse();
      
      future.then((_) {
        if (route.navigator != null && controller.status == AnimationStatus.dismissed) {
          route.navigator?.pop();
        }
      });
    } else {
      // Snap back to full screen
      controller.forward();
    }
    
    route.navigator?.didStopUserGesture();
  }
}
