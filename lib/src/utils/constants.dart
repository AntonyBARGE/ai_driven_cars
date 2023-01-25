
import 'package:flutter/material.dart';

Size? screenSize;
double screenWidth = screenSize!.width;
double screenHeight = screenSize!.height;
double sw = screenWidth/100;
double sh = screenHeight/100;

double defaultRoadWidth = 95*sw;
const int defaultLaneCount = 5;
double defaultCarWidth = defaultRoadWidth/(2*(defaultLaneCount - 1));

double defaultCarY = 0.7*screenHeight;
const double defaultAngleSpeed = 0.003;
const double carAcceleration = 0.2;
const double carMaxSpeed = 6.0;
const double obstacleCarMaxSpeed = carMaxSpeed/2;
const double carBackwardMaxSpeedCoef = 0.6;
const double airFriction = 0.1;

int fps = 60;
Duration frameRefreshFrequency = Duration(milliseconds: 1000~/fps);
int carsPerGeneration = 100;
int carsBrainMutationPercentage = 20;
int carSensorRayCount = 21;
int inputSensorCount = 5;
double defaultRayLength= screenHeight/2;

const Color primaryColor = Colors.pinkAccent;
const Color secondaryColor = Color(0xFF373A36);