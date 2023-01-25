import 'dart:async';

import 'package:ai_driven_cars/src/utils/constants.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class ButtonsPanel extends StatefulWidget {
  Function save;
  Function delete;
  Function refresh;
  Function showParameters;
  Function switchDriveMode;
  Widget child;

  ButtonsPanel({Key? key, required this.save, required this.delete, required this.refresh,
  required this.showParameters, required this.switchDriveMode, required this.child}) : super(key: key);

  @override
  _ButtonsPanelState createState() => _ButtonsPanelState();
}

class _ButtonsPanelState extends State<ButtonsPanel> with TickerProviderStateMixin {
  final autoSizeGroup = AutoSizeGroup();
  int _bottomNavIndex = 0; //default index of a first screen
  bool isManual = (carsPerGeneration == 2);

  late AnimationController _fabAnimationController;
  late AnimationController _borderRadiusAnimationController;
  late Animation<double> fabAnimation;
  late Animation<double> borderRadiusAnimation;
  late CurvedAnimation fabCurve;
  late CurvedAnimation borderRadiusCurve;
  late AnimationController _hideBottomBarAnimationController;

  late List<IconData> iconList;
  late List<String> textList;
  late List<Function> functionList;

  @override
  void initState() {
    super.initState();
    iconList = [Icons.settings, isManual ? Icons.engineering : Icons.precision_manufacturing, Icons.save, Icons.delete,];
    textList = ["Paramètres", isManual ? "Manual" : "Auto", "Sauvegarder", "Supprimer"];
    functionList = [widget.showParameters, widget.switchDriveMode, widget.save, widget.delete,];

    final systemTheme = SystemUiOverlayStyle.light.copyWith(
      systemNavigationBarColor: secondaryColor,
      systemNavigationBarIconBrightness: Brightness.light,
    );
    SystemChrome.setSystemUIOverlayStyle(systemTheme);

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _borderRadiusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    fabCurve = CurvedAnimation(
      parent: _fabAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );
    borderRadiusCurve = CurvedAnimation(
      parent: _borderRadiusAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );

    fabAnimation = Tween<double>(begin: 0, end: 1).animate(fabCurve);
    borderRadiusAnimation = Tween<double>(begin: 0, end: 1).animate(
      borderRadiusCurve,
    );

    _hideBottomBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    Future.delayed(
      const Duration(milliseconds: 200),
      () => _fabAnimationController.forward(),
    );
    Future.delayed(
      const Duration(milliseconds: 200),
      () => _borderRadiusAnimationController.forward(),
    );
  }

  bool onScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification &&
        notification.metrics.axis == Axis.vertical) {
      switch (notification.direction) {
        case ScrollDirection.forward:
          _hideBottomBarAnimationController.reverse();
          _fabAnimationController.forward(from: 0);
          break;
        case ScrollDirection.reverse:
          _hideBottomBarAnimationController.forward();
          _fabAnimationController.reverse(from: 1);
          break;
        case ScrollDirection.idle:
          break;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: NotificationListener<ScrollNotification>(
        onNotification: onScrollNotification,
        child: widget.child,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(
          Icons.replay,
          color: secondaryColor,
        ),
        onPressed: () {
          widget.refresh();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: iconList.length,
        tabBuilder: (int index, bool isActive) {
          return tabButton(index, isActive);
        },
        backgroundColor: secondaryColor,
        activeIndex: _bottomNavIndex,
        splashColor: primaryColor,
        notchAndCornersAnimation: borderRadiusAnimation,
        splashSpeedInMilliseconds: 300,
        notchSmoothness: NotchSmoothness.defaultEdge,
        gapLocation: GapLocation.center,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: (index) => setState(() {
          _bottomNavIndex = index;
          functionList[index]();
        }),
        hideAnimationController: _hideBottomBarAnimationController,
        shadow: const BoxShadow(
          offset: Offset(0, 1),
          blurRadius: 12,
          spreadRadius: 0.5,
          color: Colors.white,
        ),
      ),
    );
  }
  
  Widget tabButton(int index, bool isActive) {
    final color = isActive ? primaryColor : Colors.white;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          iconList[index],
          size: 24,
          color: color,
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: AutoSizeText(
            textList[index],
            maxLines: 1,
            style: TextStyle(color: color),
            group: autoSizeGroup,
          ),
        )
      ],
    );
  }
}