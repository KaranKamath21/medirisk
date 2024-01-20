// functions.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationFunctions {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  double? previousLatitude;
  double? previousLongitude;
  late num aqi;

  void createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'location_updates',
      'Location Updates',
      description: 'Receive notifications when your location changes',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> startTrackingLocation(BuildContext context, User? user) async {
    final locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied ||
        locationPermission == LocationPermission.deniedForever) {
      showPermissionDialog(context);
    } else {
      Timer.periodic(const Duration(seconds: 15), (timer) async {
        final position = await Geolocator.getCurrentPosition();

        if (previousLatitude != null && previousLongitude != null) {
          double distance = await Geolocator.distanceBetween(
            previousLatitude!,
            previousLongitude!,
            position.latitude,
            position.longitude,
          );

          // Fetch user data including 'isRespiratory'
          final userData = await fetchUserData(user);

          if (userData != null && userData.containsKey('isRespiratory')) {
            bool isRespiratory = userData['isRespiratory'];

            if (distance > 25 && isRespiratory) {
              await fetchAndSetAqi(position);
              await showNotification(position, user);

              previousLatitude = position.latitude;
              previousLongitude = position.longitude;
            }
          }
        } else {
          // First Time
          await fetchAndSetAqi(position);
          await showNotification(position, user);
          previousLatitude = position.latitude;
          previousLongitude = position.longitude;
        }
      });
    }
  }

  Future<Map<String, dynamic>?> fetchUserData(User? user) async {
    try {
      // Access the Firestore collection for users
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');

      // Fetch the current user's document from Firestore based on email
      QuerySnapshot userSnapshot =
          await usersCollection.where('email', isEqualTo: user?.email).get();

      if (userSnapshot.docs.isNotEmpty) {
        // Get the first document (assuming there's only one matching user)
        DocumentSnapshot userDocument = userSnapshot.docs.first;

        // Check if the 'isRespiratory' field exists
        Map<String, dynamic>? userData =
            userDocument.data() as Map<String, dynamic>?;

        return userData;
      }
    } catch (error) {
      print('Error fetching user data: $error');
      return null;
    }
  }

  Future<num> fetchAirQuality(Position position) async {
    try {
      final response = await http.get(Uri.parse(
          'http://api.openweathermap.org/data/2.5/air_pollution/forecast?lat=${position.latitude}&lon=${position.longitude}&appid=9a735dbff7fc997dd33d03275fd1d93e'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['list'][0]['main']['aqi'] as num;
      } else {
        throw Exception('Failed to load air quality data');
      }
    } catch (error) {
      print('Error fetching air quality: $error');
      throw error;
    }
  }

  Future<num> fetchUVIndex(Position position) async {
    try {
      final response = await http.get(Uri.parse(
          'http://api.openweathermap.org/data/2.5/uvi/forecast?lat=${position.latitude}&lon=${position.longitude}&appid=9a735dbff7fc997dd33d03275fd1d93e'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['list'][0]['main']['aqi'] as num;
      } else {
        throw Exception('Failed to load air quality data');
      }
    } catch (error) {
      print('Error fetching air quality: $error');
      throw error;
    }
  }

  Future<void> showPermissionDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
            'This app needs location and notification permissions to function. Please grant permissions in the app settings.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Open Settings'),
            onPressed: () => openAppSettings(),
          ),
        ],
      ),
    );
  }

  Future<void> showNotificationPermissionDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Permission Required'),
        content: const Text(
            'This app needs notification permission to show location updates. Please grant notification permission in the app settings.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Open Settings'),
            onPressed: () => openAppSettings(),
          ),
        ],
      ),
    );
  }

  Future<void> fetchAndSetAqi(Position position) async {
    final fetchedAqi = await fetchAirQuality(position);
    aqi = fetchedAqi;
  }

  Future<void> fetchAndSetUvIndex(Position position) async {
    final fetchedUvIndex = await fetchUVIndex(position);
    aqi = fetchedUvIndex;
  }

  Future<void> showNotification(Position position, User? user) async {
    String aqiDescription;
    switch (aqi.toInt()) {
      case 1:
        aqiDescription = 'Good';
        break;
      case 2:
        aqiDescription = 'Fair';
        break;
      case 3:
        aqiDescription = 'Moderate';
        break;
      case 4:
        aqiDescription = 'Poor';
        break;
      case 5:
        aqiDescription = 'Very Poor';
        break;
      default:
        aqiDescription = 'Unknown';
        break;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'location_updates',
      'Location Updates',
      channelDescription: 'Receive notifications when your location changes',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    String body =
        'Dear user, The climate conditions of your area seem to be $aqiDescription. Being a person who had/has respiratory diseases, we urge you to take necessary precautions.';

    await flutterLocalNotificationsPlugin.show(
      0,
      'Weather Update',
      '$body',
      //New position: ${position.latitude}, ${position.longitude}, AQI: $aqiDescription
      platformChannelSpecifics,
    );

    await saveNotificationToFirestore('Weather Update', body, user);
  }

  Future<void> saveNotificationToFirestore(
      String title, String body, User? user) async {
    try {
      // Access the Firestore collection for users
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');

      // Fetch the current user's document from Firestore based on email
      QuerySnapshot userSnapshot =
          await usersCollection.where('email', isEqualTo: user?.email).get();

      if (userSnapshot.docs.isNotEmpty) {
        // Get the first document (assuming there's only one matching user)
        DocumentSnapshot userDocument = userSnapshot.docs.first;

        // Check if the 'notifications' field exists
        Map<String, dynamic>? userData =
            userDocument.data() as Map<String, dynamic>?;

        // Explicitly cast 'notifications' to the expected type
        List<Map<String, dynamic>> notificationsList =
            List<Map<String, dynamic>>.from(userData?['notifications'] ?? []);

        // Get the current time
        DateTime currentTime = DateTime.now();

        // Create a new notification document
        Map<String, dynamic> notificationData = {
          'title': '$title',
          'body': '$body',
          'timestamp': currentTime,
        };

        // Add the new notification to the list
        notificationsList.add(notificationData);

        // Update the user's document in Firestore with the new notifications list
        await usersCollection.doc(userDocument.id).update({
          'notifications': notificationsList,
        });

        print('Notification saved to Firestore');
      } else {
        print('User document not found.');
      }
    } catch (error) {
      print('Error saving notification to Firestore: $error');
    }
  }
}
