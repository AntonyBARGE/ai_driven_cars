import 'dart:async';

import 'package:flutter/material.dart';
import '../car/car_view.dart';
import '../controls/controls_view.dart';
import '../segment/segment.dart';
import '../segment/segments_view.dart';
import '../utils/constants.dart';
import 'road.dart';

class RoadView extends StatefulWidget {
  Road road;
  RoadView(this.road, {super.key});

  static const routeName = '/road';

  @override
  State<RoadView> createState() => _RoadViewState();
}

class _RoadViewState extends State<RoadView> {
  @override
  void initState() {
    super. initState();
    Timer.periodic(frameRefreshFrequency, (Timer t) => 
      setState(() {
        widget.road.updateTraffic();
        widget.road.updateRoad();
      })
    );
  }
  
  @override
  Widget build(BuildContext context) {
    Road road = widget.road;
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey[700],
          body: ControlsView(
            car: road.cars![0],
            child: Container(
              width: road.roadWidth,
              color: Colors.grey[400],
              child: Stack(
                children: displaySegments() + displayCars()
              ),
            ),
          ),
        ),
      ]
    );
  }
  
  List<Widget> displayCars() {
    var cars =  widget.road.cars!;
    var carsViews = List.generate(cars.length, (carIndex) => CarView(car: cars[carIndex]));
    var traffic =  widget.road.traffic!;
    var trafficViews = List.generate(traffic.length, (carIndex) => CarView(car: traffic[carIndex]));
    List<Widget> result = carsViews + trafficViews;
    return result;
  }

  List<Widget> displaySegments() {
    Road road = widget.road;
    List<List<Segment>> carsSensors = List.generate(road.cars!.length, (index) => road.cars![0].sensor!.rays);
    List<Segment> segmentsToDisplay = road.obstacles! + road.laneLines! + road.hitboxes;
    for (var rayList in carsSensors) {
      for (var ray in rayList) {
        segmentsToDisplay.add(ray);
      }
    }
    return [SegmentsView(
      segmentsToDisplay, 
      drawingTopOffset: defaultCarY - road.cars!.first.y,
    )];
  }
  
  void save() {print("save");}
  
  void delete() {print("delete");}
  
  void showParameters() {print("showParameters");}
  
  void showVariation() {print("showVariation");}
}