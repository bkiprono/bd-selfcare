import 'package:flutter/material.dart';

/// Reusable draggable bottom sheet with a draggable handle that can also be used to scroll
class CustomDraggableBottomSheet extends StatelessWidget {
  final Widget child;
  final double minChildSize;
  final double maxChildSize;
  final double initialChildSize;
  final bool expand;

  const CustomDraggableBottomSheet({
    super.key,
    required this.child,
    this.minChildSize = 0.2,    // 20% of screen
    this.maxChildSize = 0.9,    // 90% of screen
    this.initialChildSize = 0.4, // start at 40%
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: expand,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      initialChildSize: initialChildSize,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle that can also be used to scroll
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: (details) {
                  // Forward drag events to the scroll controller
                  if (scrollController.hasClients) {
                    scrollController.position.moveTo(
                      scrollController.position.pixels - details.delta.dy,
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  height: 24,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}