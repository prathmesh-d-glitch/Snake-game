import 'package:flutter/material.dart';
import 'control_button.dart';
import 'direction.dart';

class ControlPanel extends StatelessWidget {
  final void Function(Direction direction)? onTapped;

  const ControlPanel({Key? key, this.onTapped}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 50.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(),
                ),
                ControlButton(
                  icon: Icon(Icons.arrow_left),
                  onPressed: () {
                    if (onTapped != null) onTapped!(Direction.left);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                ControlButton(
                  icon: Icon(Icons.arrow_drop_up_sharp),
                  onPressed: () {
                    if (onTapped != null) onTapped!(Direction.up);
                  },
                ),
                SizedBox(
                  height: 75.0,
                ),
                ControlButton(
                  icon: Icon(Icons.arrow_drop_down_sharp),
                  onPressed: () {
                    if (onTapped != null) onTapped!(Direction.down);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                ControlButton(
                  icon: Icon(Icons.arrow_right),
                  onPressed: () {
                    if (onTapped != null) onTapped!(Direction.right);
                  },
                ),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
