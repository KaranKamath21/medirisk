import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../homepage/homepage.dart';
import 'functions.dart';

class UI extends StatefulWidget {
  final User? user;
  const UI({required this.user});

  // const UI({super.key});

  @override
  State<UI> createState() => _UIState();
}

class _UIState extends State<UI> {
  // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final LocationFunctions locationFunctions = LocationFunctions();

  @override
  void initState() {
    super.initState();
    _initLocationTracking();
  }

  Future<void> _initLocationTracking() async {
    await Future.delayed(Duration(seconds: 1)); // Add a delay

    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // locationFunctions
      //     .showPermissionDialog(navigatorKey.currentState!.context);
      locationFunctions.showPermissionDialog(context);
    } else {
      final notificationPermission = await Permission.notification.request();
      if (notificationPermission != PermissionStatus.granted) {
        locationFunctions.showNotificationPermissionDialog(context);
        // locationFunctions.showNotificationPermissionDialog(
        //     navigatorKey.currentState!.context);
      } else {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        await locationFunctions.startTrackingLocation(context, widget.user!);
        // await locationFunctions.startTrackingLocation(
        //     navigatorKey.currentState!.context, widget.user!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(user: widget.user)));
        return false; // Prevent default back button behavior
      },
      child: MaterialApp(
        // navigatorKey: navigatorKey,
        home: Builder(
          builder: (context) =>
              HomePage(user: widget.user), // Pass your user data here
        ),
      ),
    );
  }
}
