
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

import '../car/car.dart';
import 'controls.dart';

class ControlsView extends StatelessWidget {
  Widget child;
  Car car;
  ControlsView({required this.child, required this.car, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double percentageVariation = 0.15;

    return JoystickArea(
      mode: JoystickMode.all,
      initialJoystickAlignment: const Alignment(-5,-5),
      listener: (details) {
        if (car.road.cars!.length == 1 && !car.isAI) {
          Controls inputControls = car.inputControls;
          if (details.x > percentageVariation) {
            inputControls.right = true;
            inputControls.left = false;
          } 
          else if (details.x < -percentageVariation) {
            inputControls.left = true;
            inputControls.right = false;
          }
          else {
            inputControls.right = false;
            inputControls.left = false;
          }
          if (details.y < -0) {
            inputControls.forward = true;
            inputControls.reverse = false;
          } 
          else if (details.y > 0) {
            inputControls.reverse = true;
            inputControls.forward = false;
          }
          else {
            inputControls.reverse = false;
            inputControls.forward = false;
          }
        }
      },
      child: child,
    );
  }
}