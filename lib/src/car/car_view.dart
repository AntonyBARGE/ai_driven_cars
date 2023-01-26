import 'package:ai_driven_cars/src/utils/constants.dart';
import 'package:flutter/material.dart';
import 'car.dart';


class CarView extends StatelessWidget {
  Car car;
  CarView({required this.car, super.key});

  @override
  Widget build(BuildContext context) {
    String carImage = "assets/images/";
    carImage += car.isMain ? (car.isDamaged ? 'fefedead.png' : 'fefe.png') : 'obstacle.png';
    double topOffset = 0.7 * screenHeight - car.road.cars!.first.y - car.height!/2;
    double leftOffset = -car.width!/2;

    return Positioned(
      left: car.x + leftOffset,
      top: car.y + topOffset,
      child: SizedBox(
        width: car.width,
        height: car.height,
        child: Transform.rotate(
          angle: -car.angle,
          child: Opacity(
            opacity: (!car.isMain || car == car.road.cars!.first) ? 1: 0.2,
            child: Container(
              alignment: FractionalOffset.topCenter,
              child: Image(
                fit: BoxFit.fitWidth,
                image: AssetImage(carImage)
              )
            )
          )
        ),
      )
    );
  }
}