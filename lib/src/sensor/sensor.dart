import 'dart:math';

import 'package:flutter/animation.dart';

import '../car/car.dart';
import '../segment/segment.dart';
import '../touch/touch.dart';
import '../utils/constants.dart';
import '../utils/utils.dart';

class Sensor {
  Car car;
  int rayCount = carSensorRayCount;
  double rayLength = defaultRayLength;
  double raySpread = 2*pi/5;
  List<Segment> rays = [];
  List<Segment> displayRays = [];
  List<double> detectedObstacleDistance = [];
  int inputCount = inputSensorCount;
  
  Sensor(this.car) {
    if (car.isMain) updateRays(this);
  }
  
  static List<Segment> updateRays(Sensor sensor) {
    sensor.rays.clear();
    sensor.displayRays = List.generate(sensor.inputCount, (index) => Segment(const Offset(0,0), const Offset(0,0)));
    for (var rayIndex = 0; rayIndex < sensor.rayCount; rayIndex++) {
      num rayAngle = lerp(sensor.raySpread, -sensor.raySpread, rayIndex/(sensor.rayCount-1));
      Offset rayStart = Offset(sensor.car.x, sensor.car.y);
      Offset rayEnd = rayStart.translate(-sensor.rayLength * sin(rayAngle + sensor.car.angle), -sensor.rayLength * cos(rayAngle + sensor.car.angle));
      sensor.rays.add(Segment(rayStart, rayEnd));
      
      if (rayIndex < sensor.inputCount){
        num newRayAngle = lerp(sensor.raySpread, -sensor.raySpread, rayIndex/(sensor.inputCount-1));
        Offset newRayStart = Offset(sensor.car.x, sensor.car.y);
        Offset newRayEnd = rayStart.translate(-sensor.rayLength * sin(newRayAngle + sensor.car.angle), -sensor.rayLength * cos(newRayAngle + sensor.car.angle));
        sensor.displayRays[rayIndex] = Segment(newRayStart, newRayEnd);
        sensor.displayRays[rayIndex].percentageColored = 1;
      }
    }
    return sensor.rays;
  }

  List<double> detectObstacles(){
    detectedObstacleDistance = List.generate(inputCount, (index) => 0.0);

    for (var rayIndex = 0; rayIndex < rayCount; rayIndex++) {
      List<Touch> touches = [];
      for (var obstacle in car.road.obstacles!) {
        Touch? touch = rays[rayIndex].getIntersection(obstacle);
        if (touch != null){
          touches.add(touch);
        }
      }
      double rayPercentageDistance = 1;
      if (touches.isNotEmpty){
        rayPercentageDistance = touches.reduce((minimum, touch) => minimum.percentage > touch.percentage ? touch : minimum).percentage;
      }
      rays[rayIndex].percentageColored = rayPercentageDistance;

      int portion = (inputCount*lerp(raySpread, 0, rayIndex/(rayCount-1)))~/raySpread;
      if (portion == inputCount){
        portion -= 1;
      }
      if (rayPercentageDistance < displayRays[portion].percentageColored!) {
        displayRays[inputCount - 1 - portion].percentageColored = rayPercentageDistance;
        detectedObstacleDistance[inputCount - 1 - portion] = rayPercentageDistance;
      }
    }
    return detectedObstacleDistance;
  }    
}