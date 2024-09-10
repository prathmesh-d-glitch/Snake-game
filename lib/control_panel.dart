import 'package:flutter/material.dart';
import 'direction.dart';

class ControlPanel extends StatelessWidget {
  final void Function(Direction direction)? onTapped;

  const ControlPanel({Key? key, this.onTapped}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 0) {
          // Swipe Right
          if (onTapped != null) onTapped!(Direction.right);
        } else if (details.delta.dx < 0) {
          // Swipe Left
          if (onTapped != null) onTapped!(Direction.left);
        }
      },
      onVerticalDragUpdate: (details) {
        if (details.delta.dy > 0) {
          // Swipe Down
          if (onTapped != null) onTapped!(Direction.down);
        } else if (details.delta.dy < 0) {
          // Swipe Up
          if (onTapped != null) onTapped!(Direction.up);
        }
      },
      child: Container(
        color: Colors.transparent, // Full screen swipeable area
        child: Center(
          child: null,
        ),
      ),
    );
  }
}
