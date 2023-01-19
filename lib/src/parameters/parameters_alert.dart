import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../road/road.dart';
import '../utils/constants.dart';

class ParametersAlertDialog extends StatefulWidget {
  Road road;
  double newLaneCount;
  double newCarsPerGeneration;
  double newRoadWidth;
  double newRayCount;
  double newFps;
  ParametersAlertDialog({required this.road, required this.newLaneCount, required this.newCarsPerGeneration, required this.newRoadWidth, required this.newRayCount, required this.newFps, super.key});

  @override
  State<ParametersAlertDialog> createState() => _ParametersAlertDialogState();
}

class _ParametersAlertDialogState extends State<ParametersAlertDialog> {
  @override
  Widget build(BuildContext context) {
    // set up the buttons
    Widget roadWidthSlider = Column(
      children: [
        const Text("Largeur de la route :"),
        SfSlider(
          min: 0,
          max: 100,
          value: widget.newRoadWidth/10,
          interval: 25,
          stepSize: 1,
          showLabels: true,
          enableTooltip: true,
          onChanged: (dynamic value) => setState(() {value == 0? 1 : widget.newRoadWidth = (10*value).toDouble();}),
        ),
        const Divider(),
      ]
    );

    Widget laneCountSlider = Column(
      children: [
        const Text("Nombre de voies :"),
        SfSlider(
          min: 3,
          max: 10,
          value: widget.newLaneCount,
          interval: 1,
          stepSize: 1,
          showLabels: true,
          onChanged: (dynamic value) => setState(() {widget.newLaneCount = value;}),
        ),
        const Divider(),
      ]
    );

    Widget carsPerGenerationSlider = Column(
      children: [
        const Text("Nombre de voitures par génération :"),
        SfSlider(
          min: 0,
          max: 200,
          value: widget.newCarsPerGeneration,
          interval: 50,
          stepSize: 1,
          showLabels: true,
          enableTooltip: true,
          onChanged: (dynamic value) => setState(() {value == 0? 1 : widget.newCarsPerGeneration = value;}),
        ),
        const Divider(),
      ]
    );

    Widget rayCountSlider = Column(
      children: [
        const Text("Nombre de capteurs :"),
        SfSlider(
          min: 3,
          max: 11,
          value: widget.newRayCount,
          interval: 2,
          stepSize: 1,
          showLabels: true,
          enableTooltip: true,
          onChanged: (dynamic value) => setState(() {widget.newRayCount = value;}),
        ),
        const Divider(),
      ]
    );

    Widget fpsSlider = Column(
      children: [
        const Text("FPS :"),
        SfSlider(
          min: 10,
          max: 100,
          value: widget.newFps,
          interval: 30,
          stepSize: 1,
          showLabels: true,
          enableTooltip: true,
          onChanged: (dynamic value) => setState(() {widget.newFps = value;}),
        ),
        const Divider(),
      ]
    );

    Widget saveButton = TextButton(
      child: const Text("Sauvegarder"),
      onPressed: () {
        widget.road.laneCount = widget.newLaneCount.toInt();
        carsPerGeneration = widget.newCarsPerGeneration.toInt();
        widget.road.roadWidth = widget.newRoadWidth;
        carSensorRayCount = widget.newRayCount.toInt();
        fps = widget.newFps.toInt();
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Paramètres"),
      actions: [
        roadWidthSlider,
        laneCountSlider,
        carsPerGenerationSlider,
        rayCountSlider,
        fpsSlider,
        saveButton
      ],
    );

    // show the dialog
    return alert;
  }
}