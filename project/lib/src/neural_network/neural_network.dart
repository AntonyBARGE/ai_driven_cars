import 'dart:convert';
import 'dart:math';

import 'package:ai_driven_cars/src/utils/constants.dart';

import '../utils/utils.dart';
import '../level/level.dart';


class NeuralNetwork {
  List<int> neurons;
  List<Level>? levels;

  NeuralNetwork({neurons, this.levels}) : neurons = neurons ?? [inputSensorCount, inputSensorCount+2, 4]{
      NeuralNetwork.initialize(this);
  }

  static void initialize(NeuralNetwork neuralNetwork) {
    List neurons = neuralNetwork.neurons;
    neuralNetwork.levels ??= List.generate(neurons.length-1, (i) => Level(neurons[i], neurons[i+1]));
  }

  static List feedForward(List givenInputs, NeuralNetwork neuralNetwork){
    List outputs = Level.feedForward(givenInputs, neuralNetwork.levels![0]);
    for (var i = 1; i < neuralNetwork.levels!.length; i++) {
      outputs = Level.feedForward(outputs, neuralNetwork.levels![i]);
    }
    return outputs;
  }

  static NeuralNetwork mutate(NeuralNetwork network, double amount){
    for (var level in network.levels!) {
      for (var i = 0; i < level.biases!.length; i++) {
        level.biases![i] = lerp(level.biases![i], Random().nextDouble()*2-1, amount);
      }
      for (var i = 0; i < level.weights!.length; i++) {
        for (var j = 0; j < level.weights![i].length; j++) {
          level.weights![i][j] = lerp(level.weights![i][j], Random().nextDouble()*2-1, amount);
        }
      }
    }
    return network;
  }

  static NeuralNetwork symmetricalMutate(NeuralNetwork network, double amount){
    for (var level in network.levels!) {
      double half = level.biases!.length/2;
      for (var i = 0; i < half; i++) {
        level.biases![i] = lerp(level.biases![i], Random().nextDouble()*2-1, amount);
        level.biases![level.biases!.length-1 - i] = level.biases![i];
      }
      for (var i = 0; i < level.weights!.length; i++) {
        level.weights![level.weights!.length-1 - i] = level.weights![i];
        for (var j = 0; j < level.weights![i].length; j++) {
          level.weights![i][j] = lerp(level.weights![i][j], Random().nextDouble()*2-1, amount);
        }
      }
    }
    return network;
  }

  NeuralNetwork copy(){
    return NeuralNetwork.fromJson(toJson(this));
  }

  static Map<String, dynamic> toJson(NeuralNetwork neuralNetwork) {
    var jsonLevels = neuralNetwork.levels!.map((Level level) => 
      {
        'inputCount': level.inputCount,
        'outputCount': level.outputCount,
        'inputs': level.inputs,
        'outputs': level.outputs,
        'biases': level.biases,
        'weights': level.weights
      }
    ).toList();
    return {
      'neurons': jsonEncode(neuralNetwork.neurons),
      'levels': jsonEncode(jsonLevels),
    };
  }

  factory NeuralNetwork.fromJson(Map<String, dynamic> json) {
    List<dynamic> neuronsJson = jsonDecode(json["neurons"]);
    List<int> neurons = List.generate(neuronsJson.length, (index) => neuronsJson[index]);

    
    List<dynamic> levelsJson = jsonDecode(json["levels"]);
    List<Level> levels = List.generate(levelsJson.length, 
      (index) {
        return Level(levelsJson[index]["inputCount"], levelsJson[index]["outputCount"],
          inputs: levelsJson[index]["inputs"],
          outputs: levelsJson[index]["outputs"],
          biases: levelsJson[index]["biases"],
          weights: levelsJson[index]["weights"],
        );
      }
    );
    NeuralNetwork neuralNetwork = NeuralNetwork(neurons: neurons, levels: levels);
    return neuralNetwork;
  }
}