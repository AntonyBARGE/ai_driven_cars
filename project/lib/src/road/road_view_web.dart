import 'package:ai_driven_cars/src/road/road.dart';
import 'package:flutter/material.dart';

import '../controls/controls_view_web.dart';
import '../segment/segments_view.dart';
class RoadViewWeb extends StatefulWidget {
  Road road;
  RoadViewWeb(this.road, {super.key});
  
  static const routeName = '/road';

  @override
  State<RoadViewWeb> createState() => _RoadViewWebState();
}

class _RoadViewWebState extends State<RoadViewWeb> {
  @override
  Widget build(BuildContext context) {
    Road road = widget.road;
    return Scaffold(
      backgroundColor: Colors.grey[700],
      body: ControlsViewWeb(
        car: road.cars![0],
        child: Container(
          width: road.roadWidth,
          color: Colors.grey[400],
          child: SegmentsView(road.borders! + road.laneLines! + road.obstacles!),
        )
      ),
    );
  }
}