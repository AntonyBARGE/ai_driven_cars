
import 'package:flutter/material.dart';

import '../car/car.dart';
import 'controls.dart';

class ControlsViewWeb extends StatelessWidget {
  Car car;
  Widget child;

  ControlsViewWeb({
    Key? key,
    required this.child,
    required this.car
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKey: (event) {
        if (car.road.cars!.length == 1 && !car.isAI) {
          Controls inputControls = car.inputControls;

          var keyPressed = event.logicalKey.keyLabel;
          switch(keyPressed) {
            case "Arrow Right": {
              if (!event.repeat) {
                inputControls.right = !inputControls.right;
              }
            }
            break;
            case "Arrow Left": {
              if (!event.repeat) {
                inputControls.left = !inputControls.left;
              }
            }
            break;
            case "Arrow Up": {
              if (!event.repeat) {
                inputControls.forward = !inputControls.forward;
              }
            }
            break;
            case "Arrow Down": {
              if (!event.repeat) {
                inputControls.reverse = !inputControls.reverse;
              }
            }
            break;
            default: {
            }
            break;
          }
        }
      },
      child: child,
    );
  }
}