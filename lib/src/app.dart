import 'package:ai_driven_cars/src/buttons_panel/buttons_panel.dart';
import 'package:ai_driven_cars/src/local_storage/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'controls/controls_view.dart';
import 'parameters/parameters_alert.dart';
import 'road/road.dart';
import 'road/road_view.dart';
import 'road/road_view_web.dart';
import 'utils/constants.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Providing a restorationScopeId allows the Navigator built by the
      // MaterialApp to restore the navigation stack when a user leaves and
      // returns to the app after it has been killed while running in the
      // background.
      restorationScopeId: 'app',
        // Provide the generated AppLocalizations to the MaterialApp. This
      // allows descendant Widgets to display the correct translations
      // depending on the user's locale.
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
      ],
        // Use AppLocalizations to configure the correct application title
      // depending on the user's locale.
      //
      // The appTitle is defined in .arb files found in the localization
      // directory.
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)!.appTitle,
        theme: ThemeData(primarySwatch: Colors.red,),
      debugShowCheckedModeBanner: false,
        // Define a function to handle named routes in order to support
      // Flutter web url navigation and deep linking.
      onGenerateRoute: (RouteSettings routeSettings) {
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (BuildContext context) {
            screenSize = MediaQuery.of(context).size;
            return ContainerForRefresh(routeSettings);
          },
        );
      }
    );
  }
}

class ContainerForRefresh extends StatefulWidget {
  RouteSettings routeSettings;
  ContainerForRefresh(this.routeSettings, {super.key});

  @override
  State<ContainerForRefresh> createState() => _ContainerForRefreshState();
}

class _ContainerForRefreshState extends State<ContainerForRefresh> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: WaitingRoadBuilder(widget.routeSettings, refresh)
    );
  }

  void refresh(){
    Navigator.pop(context);
    Navigator.pushNamed(context, widget.routeSettings.name!);
  }
}

class WaitingRoadBuilder extends StatelessWidget {
  RouteSettings routeSettingsFromParent;
  Function refresh;
  WaitingRoadBuilder(this.routeSettingsFromParent, this.refresh, {super.key});

  @override
  Widget build(BuildContext context) {
    RouteSettings routeSettings = routeSettingsFromParent;
    return FutureProvider(
      create: (_) => getRoad(),
      initialData: null,
      child: Consumer<Road?>(builder: (context, road, child) {
        if (road == null) {
          return const CircularProgressIndicator();
        } else {
          switch (routeSettings.name) {
            case RoadView.routeName:
              return (screenWidth > 480) ? AddButtonsPanel(
                  refresh: refresh,
                  road: road,
                  child: RoadViewWeb(road)) : 
                AddButtonsPanel(
                  refresh: refresh,
                  road: road,
                  child: RoadView(road));
            default:
              return AddButtonsPanel(
                  refresh: refresh,
                  road: road,
                  child: RoadView(road));
            }
          }
        }
      )
    );
  }

  Future<Road> getRoad() async {
    return await Road.create(
      laneCount: defaultLaneCount, 
      roadWidth: defaultRoadWidth,
    );
  }
}

class AddButtonsPanel extends StatelessWidget {
  Widget child;
  Road road;
  Function refresh;
  AddButtonsPanel({required this.child, required this.road, required this.refresh, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        ButtonsPanel(
          save: () => LocalStorageService.setBestBrain(road.cars!.first.brain!),
          delete: () => LocalStorageService.clearBestBrain(), 
          refresh: () => refresh(),
          showParameters: () => showParameters(context), 
          switchDriveMode: () => switchDriveMode(carsPerGeneration == 2),
          child: ControlsView(
            car: road.cars![1],
            child: Container(color: Colors.transparent),
          )
        )
      ]
    );
  }

  void showParameters(BuildContext context){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ParametersAlertDialog(
          road: road,
          newLaneCount: road.laneCount.toDouble(),
          newCarsPerGeneration: carsPerGeneration.toDouble(),
          newRoadWidth: road.roadWidth.toDouble(),
          newRayCount: carSensorRayCount.toDouble(),
          newFps: fps.toDouble(),
        );
      },
    );
  }

  void switchDriveMode(bool isManual){
    carsPerGeneration = isManual ? 100 : 2;
    refresh();
  }
}
