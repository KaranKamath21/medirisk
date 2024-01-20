import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../homepage_details/past_history.dart';
import '../login page/loginpage.dart';
import 'homepage.dart';
import 'notifications.dart';

class ProfilePage extends StatefulWidget {
  final User? user;

  const ProfilePage({required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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

  List<BottomNavigationBarItem> bottomNavigationBarItems = [
    BottomNavigationBarItem(
        icon: Icon(Icons.home, color: Colors.black), label: 'Home'),
    BottomNavigationBarItem(
        icon: Icon(Icons.history, color: Colors.black), label: 'Past History'),
    BottomNavigationBarItem(
        icon: Icon(Icons.notifications, color: Colors.black),
        label: 'Notifications'),
    BottomNavigationBarItem(
        icon: Icon(Icons.person, color: Colors.black), label: 'User Profile'),
  ];

  // Keep track of the currently selected bottom navigation bar item
  int selectedIndex = 3;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var userData;

  Future<Map<String, dynamic>> fetchData(String userEmail) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      userData = querySnapshot.docs[0].data() as Map<String, dynamic>?;
    } else {
      print('User not found');
    }
    return userData ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: AppBar(
          backgroundColor: Color(0xFFDDDAE7),
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text('Your Profile',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              )),
        ),
        body: FutureBuilder(
          future: fetchData(widget.user?.email ?? ''),
          builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Display a loading indicator while fetching data
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Display an error message if an error occurs
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              // Build the UI using the fetched data
              userData = snapshot.data;
              return buildProfileUI();
            }
          },
        ),
      ),
    );
  }

  Widget buildProfileUI() {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Column(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Your Name'),
            subtitle: Text(userData?['username'] ?? 'N/A'),
          ),
          ListTile(
            leading: Icon(Icons.email_outlined),
            title: Text('Email'),
            subtitle: Text(widget.user?.email ?? 'N/A'),
          ),
          ListTile(
            leading: Icon(Icons.cake),
            title: Text('Age'),
            subtitle: Text(userData?['age'] ?? 'N/A'),
          ),
          ListTile(
            leading: userData?['gender'] == 'male'
                ? Icon(Icons.male)
                : Icon(Icons.female),
            title: Text('Gender'),
            subtitle: Text(userData?['gender'] ?? 'N/A'),
          ),
          Spacer(),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  await _resetPassword();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFDDDAE7),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_open, // You can choose an appropriate icon
                      color: Colors.black,
                    ),
                    SizedBox(
                        width: 8), // Adjust the spacing between icon and text
                    Text(
                      'Reset Password',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  await _logOut(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFDDDAE7),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: Colors.black,
                    ),
                    SizedBox(
                        width: 8), // Adjust the spacing between icon and text
                    Text(
                      'Log Out',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ]),
          SizedBox(height: 16.0),
        ],
      ),
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
            case 0:
              // Navigate to the home page
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomePage(
                            user: widget.user,
                          )));
              break;
            case 1:
              // Navigate to the past history page
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HistoryPage(user: widget.user)));
              break;
            case 2:
              // Navigate to the notifications page
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotificationsPage(user: widget.user)));
              break;
          }
        },
      ),
    );
  }

  Future<void> _resetPassword() async {
    bool confirmReset = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset Password'),
          content: Text('Are you sure you want to change your password?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User canceled
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );

    if (confirmReset == true) {
      try {
        await _auth.sendPasswordResetEmail(email: widget.user?.email ?? '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email sent. Check your email.'),
          ),
        );
      } catch (e) {
        print('Error sending password reset email: $e');
      }
    }
  }

  Future<void> _logOut(BuildContext context) async {
    // Show an alert dialog for confirmation
    bool confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // User canceled logout
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // User confirmed logout
              },
              child: Text('Log Out'),
            ),
          ],
        );
      },
    );

    // If the user confirmed, proceed with logout
    if (confirmLogout == true) {
      // Clear shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Navigate to the login page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }
}
