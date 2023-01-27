import 'dart:math';

class Level {
  int inputCount;
  int outputCount;
  List? inputs;
  List? outputs;
  List? biases;
  List? weights;

  Level(this.inputCount, this.outputCount, {this.inputs, this.outputs, this.biases, this.weights}){
    Level.initialize(this);
    bool hasToBeRandomize = true;
    for (var bias in biases!) {
      if (bias != 0){
        hasToBeRandomize = false;
      }
    }
    if (hasToBeRandomize) {
      Level.randomize(this);
    }
  }

  static void initialize(Level level) {
    level.inputs ??= List.filled(level.inputCount, 0.0);
    level.outputs ??= List.filled(level.outputCount, false);
    level.biases ??= List.filled(level.outputCount, 0.0);
    level.weights ??= List.generate(level.inputCount, (_) => List.filled(level.outputCount, 0.0));
  }
  
  static void randomize(Level level) {
    for (var i = 0; i < level.inputs!.length; i++) {
      for (var o = 0; o < level.outputs!.length; o++) {
        level.weights![i][o] = Random().nextDouble()*2 - 1;
      }
    }
    for (var o = 0; o < level.biases!.length; o++) {
      level.biases![o] = Random().nextDouble()*2 - 1;
    }
  }

  static List feedForward(List givenInputs, Level level){
    for (var i = 0; i < level.inputs!.length; i++) {
      level.inputs![i] = givenInputs[i];
    }

    for (var o = 0; o < level.outputs!.length; o++) {
      double sum = 0;
      for (var i = 0; i < level.inputs!.length; i++) {
        sum += level.inputs![i] * level.weights![i][o];
      }

      if (sum > level.biases![o]){
        level.outputs![o] = 1;
      }
      else {
        level.outputs![o] = 0;
      }
    }
    return level.outputs!;
  }
}