
import 'dart:math';
import 'dart:ui';

import '../controls/controls.dart';
import '../neural_network/neural_network.dart';
import '../road/road.dart';
import '../segment/segment.dart';
import '../sensor/sensor.dart';
import '../touch/touch.dart';
import '../utils/constants.dart';

class Car {
  final Road road;
  double? width;
  double? height;

  double x;
  double y;
  double speed;
  double angle = 0;

  final double maxSpeed;
  final double acceleration = carAcceleration;
  final double angleSpeed = defaultAngleSpeed;
  final double backwardMaxSpeedCoef = carBackwardMaxSpeedCoef;
  final double friction = airFriction;

  List<Segment>? polygon;
  bool isDamaged = false;
  final bool isMain;
  final bool isAI;
  Sensor? sensor;
  final Controls inputControls = Controls();

  NeuralNetwork? brain;

  Car({required this.road, x, y, speed, maxSpeed, isMain, isAI, this.brain}) : 
    speed = speed ?? 0.0, x = x ?? 0.0, y = y ?? 0.0, maxSpeed = maxSpeed ?? carMaxSpeed, 
    isAI = isAI ?? false, isMain = isMain ?? true
    {
      width ??= defaultCarWidth;
      height = 2*width!;
      polygon ??= createPolygon();
      sensor ??= Sensor(this);
      brain ??= NeuralNetwork(neurons: [
        sensor!.rayCount, // inputs
        sensor!.rayCount + 1 + sensor!.rayCount.remainder(2), // firstLevel
        4, // outputs
      ]);
  }

  List<Segment>? createPolygon(){
    double rad = 0.9*sqrt(pow(width!, 2) + pow(height!, 2))/2;
    double alpha = atan2(width!, height!);

    List<Offset> corners = [];
    //bottomRight
    corners.add(Offset(x - sin(pi + angle - alpha)*rad, y - cos(pi + angle - alpha)*rad));
    //bottomLeft
    corners.add(Offset(x - sin(pi + angle + alpha)*rad, y - cos(pi + angle + alpha)*rad));
    //topLeft
    corners.add(Offset(x - sin(angle - alpha)*rad, y - cos(angle - alpha)*rad));
    //topRight
    corners.add(Offset(x - sin(angle + alpha)*rad, y - cos(angle + alpha)*rad));

    polygon = [];
    for (var i = 0; i < corners.length - 1; i++) {
      polygon!.add(Segment(corners[i], corners[i+1]));
    }
    polygon!.add(Segment(corners[corners.length - 1], corners[0]));
    return polygon;
  } 

  void carUpdate(){
    Sensor.updateRays(sensor!);
    if (isAI) {
      List inputs = sensor!.detectObstacles();
      List outputs = NeuralNetwork.feedForward(inputs, brain!);
      inputControls.forward = outputs[0] == 1;
      inputControls.right = outputs[1] == 1;
      inputControls.left = outputs[2] == 1;
      inputControls.reverse = outputs[3] == 1;
    }
    
    if(!isDamaged) {
      carMovementUpdate();
    }
    if (isMain) {
      assessCarDamage();
    }
    polygon = createPolygon();
  }

  void carMovementUpdate(){
    ///forward and backward
    speedUpdate();
    x += speed * - sin(angle);
    y -= speed * cos(angle);
    //left and right
    if (isMain) {
      turn();
    }
  }

  void speedUpdate() {
    if (isMain) {
      if (inputControls.forward) {
        speed += acceleration;
      }
      if (inputControls.reverse) {
        speed -= acceleration;
      }
    }
    else {
      speed += acceleration;
    }
    addFriction();
    limitSpeed();
  }

  void addFriction() {
    if (speed > 0){
      speed -= friction;
    }
    if (speed < 0){
      speed += friction;
    }
    if (speed.abs() < friction) {
      speed = 0;
    }
  }

  void limitSpeed() {
    if (speed > maxSpeed){
      speed = maxSpeed;
    }
    if (speed < -maxSpeed * backwardMaxSpeedCoef){
      speed = -maxSpeed * backwardMaxSpeedCoef;
    }
  }
  void turn() {
    int flip = (inputControls.reverse ? -1 : 1);
    double corrected = flip * speed.abs();
    if (inputControls.right) {
      angle -= angleSpeed * corrected;
    }
    if (inputControls.left) {
      angle += angleSpeed * corrected;
    }
  }
  
  void assessCarDamage() {
    for (var obstacle in road.obstacles!) {
      Touch? touch = getPolygonIntersection(polygon!, obstacle);
      if (touch != null){
        isDamaged = true;
      }
    }
  }

  Touch? getPolygonIntersection(List<Segment> polygon, Segment obstacle) {
    for (var segment in polygon) {
      Touch? touch = segment.getIntersection(obstacle);
      if(touch != null){
        return touch;
      }
    }
    return null;
  }
}