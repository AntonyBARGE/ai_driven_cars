import 'dart:math';

import 'package:flutter/animation.dart';

import '../car/car.dart';
import '../local_storage/local_storage_service.dart';
import '../neural_network/neural_network.dart';
import '../segment/segment.dart';
import '../utils/constants.dart';

class Road {
  double roadWidth;
  int laneCount;
  List<Segment>? borders;
  List<Segment>? laneLines;
  List<Car>? cars; /// first car is best car
  List<Car>? traffic; /// first car is reference car
  List<Segment>? obstacles;
  List<Segment> hitboxes = [];
  List<bool> trafficWaves = [true, false, false];
  bool isSymmetrical = false;
  int score = 0;
  late int bestScore;

  /// Private constructor qui remplace l'original
  Road._create(this.roadWidth, this.laneCount) : assert(laneCount > 2){

    /// Définit les 2 bords
    borders = List.generate(2, 
      (index) => Segment(
        Offset(getBorderDxOffset(index), -1000000),
        Offset(getBorderDxOffset(index), 1000000),
      )
    );

    /// Définit les lignes d'interfile
    laneLines = List.generate(laneCount-1, 
      (laneIndex) => Segment(
        Offset(getLaneLineDxOffset(laneIndex), 0),
        Offset(getLaneLineDxOffset(laneIndex), screenHeight),
        isDotted: true,
      )
    );
  }

  /// Public factory pour pouvoir faire un constructeur avec un await
  static Future<Road> create({required double roadWidth, required int laneCount}) async {
    Road road = Road._create(roadWidth, laneCount);

    road.bestScore = await LocalStorageService.getPersonalRecord();

    /// Définit les voitures de la route
    road.cars = await generateCarGeneration(road);

    /// Définit les voitures obstacles du traffic
    road.traffic = road.generateTraffic();

    /// Définit les voitures obstacles sous forme de segments
    /// pour pouvoir calculer les collisions
    road.obstacles = road.createObstacles();

    /// Définit les voitures sous forme de segments
    /// pour pouvoir afficher les hitboxes
    road.hitboxes = road.createHitboxes();

    return road;
  }
  
  double getBorderDxOffset(int index) {
    return (0.025 + 0.95 * index) * roadWidth;
  }
  
  double getLaneLineDxOffset(int laneIndex) {
    double laneWidth = 0.95*roadWidth/laneCount;
    double leftOffset = getBorderDxOffset(0);
    return leftOffset + (laneIndex+1) * laneWidth;
  }

  double getLaneCenter(int laneIndex) {
    double laneWidth = 0.95*roadWidth/laneCount;
    double leftOffset = getLaneLineDxOffset(laneIndex);
    return leftOffset - laneWidth/2;
  }

  static Future<List<Car>?> generateCarGeneration(Road road) async {
    NeuralNetwork bestBrain = await LocalStorageService.getBestBrain();
    if(isManual){
      return [
        Car(road: road,
          x: road.getLaneCenter(road.laneCount~/2),
          y: 0.3*screenHeight,
          brain: bestBrain,
          isAI: true
        ),
        Car(road: road,
          x: road.getLaneCenter(road.laneCount~/2),
          y: 0.3*screenHeight,
        ),
      ];
    }
    return List.generate(carsPerGeneration, (index) {
        NeuralNetwork brain = (index == 0) ? bestBrain :
          (road.isSymmetrical ? NeuralNetwork.symmetricalMutate(bestBrain.copy(), carsBrainMutationPercentage/100) : 
                                NeuralNetwork.mutate(bestBrain.copy(), carsBrainMutationPercentage/100));
        var car = Car(road: road,
        x: road.getLaneCenter(road.laneCount~/2),
        y: 0.3*screenHeight,
        isAI: true,
        brain: brain
      );
      return car;
      }
    );
  }
  
  List<Car> generateTraffic() {
    return [Car(road: this,
      x: getLaneCenter(laneCount~/2),
      y: 0.0,
      maxSpeed: 3.0, 
      speed: 1.0, 
      isMain: false,
      )
    ];
  }

  List<Segment> createObstacles(){
    List<Segment> obstacleCars = [];
    for (var obstacleCar in traffic!) {
      for (var segment in obstacleCar.polygon!) {
        obstacleCars.add(segment);
      }
    }
    return borders! + obstacleCars;
  }

  void updateRoad(){
    deleteBadCars();
    focusOnBestCar();
    for (var car in traffic!){
      car.carUpdate();
    }
    for (var car in cars!){
      car.carUpdate();
    }
    obstacles = createObstacles();
    hitboxes = createHitboxes();
  }
  
  List<Segment> createHitboxes() {
    List<Segment> hitboxesCar = [];
    for (var hitboxCar in cars!) {
      for (var segment in hitboxCar.polygon!) {
        hitboxesCar.add(segment);
      }
    }
    return hitboxesCar;
  }

  void updateTraffic() {
    double position = (-0.6 - ((cars!.first.y - traffic!.first.y)/(screenHeight/2)));
    int index = (position+1).toInt();
    if (index < 0) {
      index = 0;
    }
    if (index > score){
      LocalStorageService.setPersonalRecord(index);
      bestScore = index;
    }
    score = index;
    for (var i = 0; i <= score; i++) {
      if (!trafficWaves[score]) {
        trafficWaves[score] = true;
      }
    }

    bool waveBeforeJustGotPassed = trafficWaves[trafficWaves.length-3] && !trafficWaves[trafficWaves.length-2] && !trafficWaves[trafficWaves.length-1];
    if (waveBeforeJustGotPassed){
      generateCarWave(score);
      deleteExcessCarWave(score);
    }
  }
  
  void generateCarWave(int index) {
    trafficWaves.add(false);
    List<bool> carsInLane = [];
    int numberOfCarsOnWave = Random().nextInt(laneCount-2)+2;

    for (var i = 0; i < laneCount; i++) {
      carsInLane.add(false);
    }
    for (var i = 0; i < numberOfCarsOnWave; i++) {
      carsInLane[i] = true;
    }
    carsInLane.shuffle();

    for (var i = 0; i < carsInLane.length; i++) {
      if (carsInLane[i]){
        traffic!.add(
          Car(road: this, 
            x: getLaneCenter(i),
            y: - (screenHeight/2 * (index + 1)) + traffic!.first.y,
            maxSpeed: 3.0, 
            speed: 1.0, 
            isMain: false,
          )
        );
      }
    }
  }
  
  void deleteExcessCarWave(int index) {
    int carExcess = traffic!.length - 5*(laneCount-1);
    if (carExcess > 0){
      for (var i = 0; i < carExcess; i++) {
        traffic!.removeAt(1);
      }
    }
  }
  
  void deleteBadCars() {
    if (cars!.length > 2) {
      cars!.removeWhere((car) => (car.isDamaged || car.y > 0.3*screenHeight) && car != cars!.first);
    }
  }
  
  void focusOnBestCar() {
    if(isManual){
      if (cars!.first.isAI) {
        final Car temp = cars!.first;
        cars!.first = cars![1];
        cars![1] = temp;
      }
    } else {
      int bestCarIndex = cars!.indexWhere((car) => car.y == cars!.map((car) => car.y).reduce(min));
      final Car temp = cars!.first;
      cars!.first = cars![bestCarIndex];
      cars![bestCarIndex] = temp;
    }
  }
}