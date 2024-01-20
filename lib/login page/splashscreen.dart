import 'dart:async';
import 'package:flutter/material.dart';
import 'loginpage.dart';

class UIConstants {
  static const double ASSUMED_SCREEN_HEIGHT = 640.0;
  static const double ASSUMED_SCREEN_WIDTH = 360.0;

  static _fitContext(BuildContext context, assumedValue, currentValue, value) =>
      (value / assumedValue) * currentValue;

  static fitToWidth(value, BuildContext context) => _fitContext(
      context, ASSUMED_SCREEN_WIDTH, MediaQuery.of(context).size.width, value);

  static fitToHeight(value, BuildContext context) => _fitContext(context,
      ASSUMED_SCREEN_HEIGHT, MediaQuery.of(context).size.height, value);

  static const splashScreenLogo = 'assets/splash_logo.png';
}

class SplashScreen extends StatefulWidget {
  static String id = 'splash';
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    startTime();
    super.initState();
  }

  startTime() async {
    var duration = new Duration(seconds: 3);
    return new Timer(duration, navigate);
  }

  void navigate() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset('assets/splash_logo.png'),
          ]),
        ),
      ),
    );
  }
}
