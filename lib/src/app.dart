import 'package:ai_driven_cars/src/buttons_panel/buttons_panel.dart';
import 'package:ai_driven_cars/src/local_storage/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
            return FutureBuilder<Road>(
              future: getRoad(),
              builder: (context, AsyncSnapshot<Road> snapshot) {
                if (snapshot.hasData) {
                  Road road = snapshot.data!;
                  switch (routeSettings.name) {
                    case RoadView.routeName:
                      return (screenWidth > 480) ? addButtonsPanel(RoadViewWeb(road), road) : addButtonsPanel(RoadView(road), road);
                    default:
                      return addButtonsPanel(RoadView(road), road);
                  }
                } else {
                  return const CircularProgressIndicator();
                }
              }
            );
          },
        );
      }
    );
  }

  Future<Road> getRoad() async {
    return await Road.create(
      laneCount: defaultLaneCount, 
      roadWidth: defaultRoadWidth,
    );
  }

  Widget addButtonsPanel(Widget pageView, Road road){
    return Stack(
      children: [
        pageView,
        ButtonsPanel(
          save: () => LocalStorageService.setBestBrain(road.cars!.first.brain!), 
          delete: () => LocalStorageService.clearBestBrain(), 
          showParameters: showParameters, 
          showVariation: showVariation
        )
      ]
    );
  }
  
  void showParameters(){
    print("showParameters");
    ///TODO: parameters alert
  }
  
  void showVariation(){
    print("showVariation");
    ///TODO: parameters alert
  }
}
