import 'package:flutter/material.dart';
import 'src/app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// Forces portrait-only mode application-wide
/// Use this Mixin on the main app widget i.e. app.dart
/// Flutter's 'App' has to extend Stateless widget.
///
/// Call `super.build(context)` in the main build() method
/// to enable portrait only mode
mixin PortraitModeMixin on StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _portraitModeOnly();
    return const MyApp();
  }
}

/// blocks rotation; sets orientation to: portrait
void _portraitModeOnly() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

/// Main App widget
class App extends StatelessWidget with PortraitModeMixin {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const MyApp();
  }
}


void main() async {
  runApp(const App());
}
