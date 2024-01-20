// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:sensors/sensors.dart';
// import 'package:audioplayers/audioplayers.dart';
//
// void main() {
//   runApp(FallDetectionApp());
// }
//
// class FallDetectionApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: FallDetectionHomePage(),
//     );
//   }
// }
//
// class FallDetectionHomePage extends StatefulWidget {
//   @override
//   _FallDetectionHomePageState createState() => _FallDetectionHomePageState();
// }
//
// class _FallDetectionHomePageState extends State<FallDetectionHomePage> {
//   static const double fallThreshold = 8.0;
//   static const double uprightThreshold = 8.0;
//   static const int uprightDuration = 500;
//   static const int fallCooldown = 20000;
//   static const int alarmDuration = 30; // Duration of the alarm in seconds
//   DateTime? lastUprightTime;
//   DateTime? lastFallTime;
//   bool isAlarmStopped =
//       false; // Flag to indicate whether the alarm has been stopped
//   final audioCache = AudioCache();
//   final messaging = FirebaseMessaging.instance; // Initialize FCM
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Listen for accelerometer events
//     accelerometerEvents.listen((AccelerometerEvent event) {
//       if (isUpright(event)) {
//         lastUprightTime = DateTime.now();
//       } else if (isFallDetected(event)) {
//         if (lastUprightTime != null &&
//             DateTime.now().difference(lastUprightTime!) <
//                 Duration(milliseconds: uprightDuration)) {
//           // Fall detected within the upright duration
//           if (lastFallTime == null ||
//               DateTime.now().difference(lastFallTime!) >
//                   Duration(milliseconds: fallCooldown)) {
//             print("fall detected");
//             // Check if there's a cooldown period after the last fall
//             lastFallTime = DateTime.now();
//             print("trying to play the audio");
//             _startAlarm();
//             print("audio played");
//
//             // Send fall detected notification to the user
//             _sendFallDetectedNotification();
//           }
//         }
//       }
//     });
//
//     // Listen for notification tap events in the foreground
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       if (message.data['action'] == 'stopAlarm') {
//         // Stop the alarm and update notification status
//         setState(() {
//           isAlarmStopped = true;
//         });
//
//         // Update notification status in Firebase
//         _updateNotificationStatus(isAlarmStopped);
//       }
//     });
//
//     _checkInitialAlarmStatus();
//   }
//
//   void _checkInitialAlarmStatus() async {
//     final userDoc = await FirebaseFirestore.instance
//         .collection('users')
//         .doc('user_id')
//         .get();
//
//     final isAlarmHandled = userDoc['isAlarmHandled'];
//
//     if (isAlarmHandled) {
//       // If the alarm is already handled, stop the alarm
//       setState(() {
//         isAlarmStopped = true;
//       });
//     }
//   }
//
//   void _startAlarm() {
//     print("playing the audio");
//     // Play the alarm sound
//     audioCache.play('fall_ringtone.mp3');
//   }
//
//   bool isUpright(AccelerometerEvent event) {
//     double magnitude =
//         event.x * event.x + event.y * event.y + event.z * event.z;
//     return magnitude < uprightThreshold;
//   }
//
//   bool isFallDetected(AccelerometerEvent event) {
//     double magnitude =
//         event.x * event.x + event.y * event.y + event.z * event.z;
//     return magnitude > fallThreshold;
//   }
//
//   void _sendFallDetectedNotification() async {
//     final fcmToken = await messaging.getToken();
//     final userDoc = await FirebaseFirestore.instance
//         .collection('users')
//         .doc('user_id')
//         .get();
//
//     final familyMemberEmail = userDoc['familyMemberEmail'];
//
//     // Check if the family member email is present
//     if (familyMemberEmail != null && familyMemberEmail.isNotEmpty) {
//       final familyMemberDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .where('email', isEqualTo: familyMemberEmail)
//           .get();
//
//       if (familyMemberDoc.docs.isNotEmpty) {
//         final familyMemberFcmToken = familyMemberDoc.docs.first['fcmToken'];
//
//         final message = RemoteMessage(
//           notification: RemoteNotification(
//             title: 'Fall Detected',
//             body: 'Tap here to STOP the alarm.',
//           ),
//           data: {
//             'action': 'stopAlarm',
//             'fcmToken': fcmToken, // Send user's FCM token to identify the user
//           },
//         );
//
//         // Send fall detected notification to the family member
//         await FirebaseMessaging.instance.sendToDevice(
//           familyMemberFcmToken,
//           message.data!,
//         );
//       }
//     }
//   }
//
//   void _updateNotificationStatus(bool isAlarmStopped) async {
//     // Update notification status in Firebase based on the user's action
//     await FirebaseFirestore.instance.collection('users').doc('user_id').update({
//       'isAlarmHandled': isAlarmStopped,
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Fall Detection App'),
//       ),
//       body: Center(
//         child: Text(
//           'Fall Detection App',
//           style: TextStyle(fontSize: 24),
//         ),
//       ),
//     );
//   }
// }
