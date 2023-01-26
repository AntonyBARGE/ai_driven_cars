import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../road/road.dart';
import '../utils/constants.dart';

class ParametersAlertDialog extends StatefulWidget {
  Road road;
  double newLaneCount;
  double newCarsPerGeneration;
  double newFps;
  ParametersAlertDialog({required this.road, required this.newLaneCount, required this.newCarsPerGeneration, required this.newFps, super.key});

  @override
  State<ParametersAlertDialog> createState() => _ParametersAlertDialogState();
}

class _ParametersAlertDialogState extends State<ParametersAlertDialog> {
  @override
  Widget build(BuildContext context) {
    // set up the buttons
    Widget symmetricalToggle = Row(
      children: [
        const Text("Symmétrie des neurones : "),
        Switch(
          value: widget.road.isSymmetrical,
          onChanged: (_) => setState(() => widget.road.isSymmetrical = !widget.road.isSymmetrical)
        )
      ],
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
          onChanged: (dynamic value) => setState(() => widget.newFps = value),
        ),
        const Divider(),
      ]
    );

    Widget variationSlider = Column(
      children: [
        const Text("Pourcentage de variation de l'IA :"),
        SfSlider(
          min: 0.0,
          max: 100.0,
          value: carsBrainMutationPercentage.toDouble(),
          interval: 10,
          stepSize: 0.5,
          showLabels: true,
          enableTooltip: true,
          minorTicksPerInterval: 1,
          onChanged: (dynamic value) => setState(() => carsBrainMutationPercentage = value.toInt())
        )
      ]
    );

    Widget saveButton = TextButton(
      child: const Text("Sauvegarder"),
      onPressed: () {
        defaultLaneCount = widget.newLaneCount.toInt();
        carsPerGeneration = widget.newCarsPerGeneration.toInt();
        fps = widget.newFps.toInt();
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Paramètres"),
      actions: [
        symmetricalToggle,
        laneCountSlider,
        carsPerGenerationSlider,
        fpsSlider,
        variationSlider,
        saveButton,
      ],
    );

    // show the dialog
    return alert;
  }
}