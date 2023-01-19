import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../neural_network/neural_network.dart';

class LocalStorageService {
  static Future<void> setBestBrain(NeuralNetwork bestBrain) async {
    /// Convertit le neuralNetwork au format JSON dans une String
    /// pour qu'il puisse être sauvegardé en local.
    String bestBrainJSON = jsonEncode(NeuralNetwork.toJson(bestBrain));

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('bestBrain', bestBrainJSON);
  }

  static Future<NeuralNetwork> getBestBrain() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bestBrainJSON = prefs.getString('bestBrain'); 
    if(bestBrainJSON == null) return NeuralNetwork();

    /// Convertit le String du JSON du neuralNetwork
    /// pour qu'il puisse être récupéré sous une forme utilisable.
    NeuralNetwork bestBrain = NeuralNetwork.fromJson(jsonDecode(bestBrainJSON));
    return bestBrain;
  }

  static Future<void> clearBestBrain() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('bestBrain');
  }
}
