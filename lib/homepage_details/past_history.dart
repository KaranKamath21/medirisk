import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medirisk/homepage/user_profile.dart';
import '../homepage/homepage.dart';
import '../homepage/notifications.dart';
import 'add_disease_page.dart';

class HistoryPage extends StatefulWidget {
  final User? user;

  const HistoryPage({required this.user});
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int selectedIndex = 1;
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
        title: Text('Past History',
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
        future: usersCollection
            .where('email', isEqualTo: widget.user?.email)
            .get(), // Use the user's email for comparison
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Text('User document not found.');
          } else {
            final userData =
                snapshot.data?.docs.first.data() as Map<String, dynamic>?;

            // Check if the user data exists
            if (userData != null) {
              if (userData.containsKey('diseases')) {
                final List<Map<String, dynamic>> diseases =
                    List.from(userData['diseases']);

                return ListView.builder(
                  itemCount: diseases.length,
                  itemBuilder: (context, index) {
                    final disease = diseases[index];
                    final String diseaseName = disease['name'];
                    final bool isResp = disease['isRespiratory'];
                    final bool isCard = disease['isCardiovascular'];
                    return ListTile(
                      title: Text(diseaseName),
                      subtitle: Text(() {
                        if (isResp && isCard) {
                          return 'Respiratory and Cardiovascular Disease';
                        } else if (isResp) {
                          return 'Respiratory Disease';
                        } else if (isCard) {
                          return 'Cardiovascular Disease';
                        } else {
                          return 'Non-Respiratory and Non-Cardiovascular Disease';
                        }
                      }()),
                    );
                  },
                );
              } else {
                return Text(
                    'You have not yet added a past history or you don\'t have one perhaps :)');
              }
            } else {
              return Text('User data not found.');
            }
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the page for adding new diseases
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddDiseasePage(user: widget.user),
            ),
          ).then((result) {
            // This block will be executed after the AddDiseasePage is popped
            if (result != null && result is bool && result) {
              // Perform your refresh or any other action here
              setState(() {
                // Your refresh logic for PastHistory page
              });
            }
          });
        },
        child: Icon(Icons.add),
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
            // case 1:
            // // Navigate to the past history page
            //   Navigator.pushNamed(context, '/past_history');
            //   break;
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
