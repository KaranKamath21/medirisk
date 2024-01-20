import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medirisk/homepage/homepage.dart';

class UserSummary extends StatefulWidget {
  final User? user;

  const UserSummary({required this.user});

  @override
  State<UserSummary> createState() => _UserSummaryState();
}

class _UserSummaryState extends State<UserSummary> {
  late String summary = '';

  @override
  void initState() {
    super.initState();
  }

  String generateSummary(Map<String, dynamic> user) {
    String respiratory = user['isRespiratory'].toString().toLowerCase();
    String cardiovascular = user['isCardiovascular'].toString().toLowerCase();
    String mentalHealth = user['mental_health'];
    final List<Map<String, dynamic>> diseases = List.from(user['diseases']);
    String respiratory_names = '';
    String cardiovascular_names = '';

    for (int i = 0; i < diseases.length; i++) {
      if (diseases[i]['isRespiratory'] == true) {
        respiratory_names += diseases[i]['name'] + ', ';
      } else if (diseases[i]['isCardiovascular'] == true) {
        cardiovascular_names += diseases[i]['name'] + ', ';
      }
    }

    if (respiratory_names.isNotEmpty) {
      respiratory_names =
          respiratory_names.substring(0, respiratory_names.length - 2);
    }
    if (cardiovascular_names.isNotEmpty) {
      cardiovascular_names =
          cardiovascular_names.substring(0, cardiovascular_names.length - 2);
    }

    summary =
        'Username - ${user['username']} \nGender - (${user['gender']}) \nAge - (${user['age']} years old)\n \nYou have ';

    if (respiratory == 'true' && cardiovascular == 'true') {
      summary +=
          'both respiratory and cardiovascular diseases. As per your past history, you were/are facing from respiratory diseases namely - $respiratory_names and cardiovascular diseases namely $cardiovascular_names. \nPrecautions: Maintain a healthy diet, regular exercise, and regular check-ups. \n';
    } else if (respiratory == 'true' && cardiovascular == 'false') {
      summary +=
          'a respiratory disease but no cardiovascular disease. \nPrecautions: Avoid exposure to pollutants and allergens, maintain regular exercise. ';
    } else if (respiratory == 'false' && cardiovascular == 'true') {
      summary +=
          'a cardiovascular disease but no respiratory disease. \nPrecautions: Maintain a low-sodium and low-fat diet, regular exercise. ';
    } else {
      summary +=
          'neither respiratory nor cardiovascular diseases. Maintain a healthy lifestyle. ';
    }

    summary += '\n\n';

    if (mentalHealth == 'Low Risk of Mental Health Issues') {
      summary +=
          'You are at low risk of mental health issues. \nPrecautions: Regular mental health check-ups.';
    } else if (mentalHealth == 'Medium Risk of Mental Health Issues') {
      summary +=
          'You are at medium risk of mental health issues. \nPrecautions: Regular counseling sessions, stress management techniques.';
    } else if (mentalHealth == 'High Risk of Mental Health Issues') {
      summary +=
          'You are at high risk of mental health issues. \nPrecautions: Seek professional help immediately, regular therapy sessions.';
    }

    return summary;
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
      child: Scaffold(
        body: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: widget.user?.email)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('User document not found.'));
            } else {
              final userData =
                  snapshot.data?.docs.first.data() as Map<String, dynamic>?;
              summary = generateSummary(userData!);
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        summary,
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
