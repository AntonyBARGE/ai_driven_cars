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
  List<double> detectedObstacleDistance = [];
  
  Sensor(this.car) {
    if (car.isMain) updateRays(this);
  }
  
  static List<Segment> updateRays(Sensor sensor) {
    sensor.rays.clear();
    for (var rayIndex = 0; rayIndex < sensor.rayCount; rayIndex++) {
      num rayAngle = lerp(sensor.raySpread, -sensor.raySpread, rayIndex/(sensor.rayCount-1));
      Offset rayStart = Offset(sensor.car.x, sensor.car.y);
      Offset rayEnd = rayStart.translate(-sensor.rayLength * sin(rayAngle + sensor.car.angle), -sensor.rayLength * cos(rayAngle + sensor.car.angle));
      sensor.rays.add(Segment(rayStart, rayEnd));
    }
    return sensor.rays;
  }

  List<double> detectObstacles(){
    detectedObstacleDistance.clear();

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
      detectedObstacleDistance.add(rayPercentageDistance);
      rays[rayIndex].percentageColored = rayPercentageDistance;
    }
    return detectedObstacleDistance;
  }    
}