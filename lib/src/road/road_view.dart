import 'dart:async';

import 'package:flutter/material.dart';
import '../car/car_view.dart';
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
  late Timer timer;

  @override
  void initState() {
    super. initState();
    timer = Timer.periodic(frameRefreshFrequency, (timer) => 
      setState(() {
        widget.road.updateTraffic();
        widget.road.updateRoad();
      })
    ); 
  }

  @override
  void dispose() {
    timer.cancel();
    timer;
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    Road road = widget.road;
    return Scaffold(
      backgroundColor: Colors.grey[700],
      body: Center(
        child: Container(
          width: road.roadWidth,
          color: Colors.grey[400],
          child: Stack(
            children: displaySegments() + displayCars() + displayScore()
          ),
        )
      ),
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
    List<List<Segment>> carsSensors = List.generate(road.cars!.length, (index) => road.cars!.first.sensor!.displayRays);
    List<Segment> segmentsToDisplay = road.laneLines! + road.borders!;
    if (!isManual) {
      for (var rayList in carsSensors) {
        for (var ray in rayList) {
          segmentsToDisplay.add(ray);
        }
      }
    }
    return [SegmentsView(
      segmentsToDisplay, 
      drawingTopOffset: defaultCarY - road.cars!.first.y,
    )];
  }
  
  List<Widget> displayScore() {
    bool isLeft = true;
    return [
      displayPoints(isLeft),
      displayPoints(!isLeft)
    ];
  }
  
  Widget displayPoints(bool isLeft) {
    MainAxisAlignment mainAxisAlignment = isLeft ? MainAxisAlignment.start : MainAxisAlignment.end;
    Alignment beginning = isLeft ? Alignment.centerLeft : Alignment.centerRight;
    Alignment ending = isLeft ? Alignment.centerRight : Alignment.centerLeft;
    String content = isLeft ? "PR : ${widget.road.bestScore}" : "${widget.road.score}";
    content += " pts";

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 4*sh,
          margin: EdgeInsets.only(top: 7*sh),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: beginning,
              end: ending,
              colors: [
                primaryColor.withOpacity(0.7),
                secondaryColor.withOpacity(0.7),
              ],
            ),
          ),
          child: FittedBox(
            fit: BoxFit.fitHeight,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(content,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: "Ubuntu",
                  fontWeight: FontWeight.w700
                )
              ),
            )
          )
        )
      ]
    );
  }
}