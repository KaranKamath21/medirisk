import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../homepage/user_profile.dart';
import '../homepage/homepage.dart';
import '../homepage/notifications.dart';
import '../homepage_details/past_history.dart';
// import 'add_disease_page.dart';

class NotificationsPage extends StatefulWidget {
  final User? user;

  const NotificationsPage({required this.user});
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int selectedIndex = 2;
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

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xFFDDDAE7),
        title: Text('Notifications',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            )),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder(
        // Fetch and display existing diseases from Firebase
        // Implement Firebase fetching logic here
        future:
            usersCollection.where('email', isEqualTo: widget.user?.email).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Text('User document not found.');
          } else {
            final userData =
                snapshot.data?.docs.first.data() as Map<String, dynamic>?;

            // Check if the user data exists
            if (userData!.containsKey('notifications')) {
              final List<Map<String, dynamic>> notifications =
                  List.from(userData['notifications']);

              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final String title = notification['title'];
                  final String body = notification['body'];
                  final DateTime timestamp = notification['timestamp'].toDate();

                  return ListTile(
                    title: Text(title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(body),
                        SizedBox(height: 4),
                        Text(
                          'Date: ${DateFormat.yMd().add_jm().format(timestamp)}',
                        ),
                      ],
                    ),
                  );
                },
              );
            } else {
              return Text('No notifications found.');
            }
          }
        },
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
                      builder: (context) => HistoryPage(
                            user: widget.user,
                          )));
              break;
            // case 2:
            //   // Navigate to the notifications page
            //   Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) =>
            //               NotificationsPage(user: widget.user)));
            //   break;
            case 3:
              // Navigate to the user profile page
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePage(
                            user: widget.user,
                          )));
              break;
          }
        },
      ),
    );
  }
}
