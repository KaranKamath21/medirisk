import 'dart:io';
import 'package:medirisk/assessment/mental_health.dart';
import 'package:medirisk/homepage/notifications.dart';
import 'package:medirisk/homepage_details/disease_predictor.dart';
import 'package:medirisk/homepage_details/past_history.dart';
import 'package:medirisk/homepage_details/user_summary.dart';
import 'package:medirisk/utils/genre_container.dart';
import 'package:flutter/material.dart';
import 'package:medirisk/homepage/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/bottomNavListItems.dart';

class HomePage extends StatefulWidget {
  final User? user;

  const HomePage({required this.user});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to exit?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => exit(0),
                child: Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  // Keep track of the currently selected bottom navigation bar item
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Color(0xFFFFFFFF),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          'Hi ${widget.user?.email}!',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      GenreContainer(
                          genre: 'Disease Prediction',
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DiseasePredictor()));
                          },
                          icon: Icons.medical_information),
                      SizedBox(height: 8.0),
                      GenreContainer(
                          genre: 'Mental Health',
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        MentalHealth(user: widget.user)));
                          },
                          icon: Icons.people),
                      SizedBox(height: 8.0),
                      GenreContainer(
                          genre: 'Summary',
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        UserSummary(user: widget.user)));
                          },
                          icon: Icons.summarize),
                      SizedBox(height: 8.0),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Display the bottom navigation bar
          bottomNavigationBar: BottomNavigationBar(
            items: bottomNavigationBarItems,
            currentIndex: selectedIndex,
            selectedItemColor:
                Colors.black, // Set the desired color for the active icon
            onTap: (index) {
              // Update the selected bottom navigation bar item
              setState(() {
                selectedIndex = index;
              });

              // Navigate to the respective page based on the selected bottom navigation bar item
              switch (selectedIndex) {
                // case 0:
                //   break;
                case 1:
                  // Navigate to the past history page
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              HistoryPage(user: widget.user)));
                  break;
                case 2:
                  // Navigate to the notifications page
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              NotificationsPage(user: widget.user)));
                  break;
                case 3:
                  // Navigate to the user profile page
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ProfilePage(user: widget.user)));
                  break;
              }
            },
          ),
        ),
      ),
    );
  }
}
