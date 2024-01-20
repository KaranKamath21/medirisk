import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MentalHealth extends StatefulWidget {
  final User? user;

  const MentalHealth({required this.user});
  @override
  _MentalHealthState createState() => _MentalHealthState();
}

class _MentalHealthState extends State<MentalHealth> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Map<String, int> quizResponses = {
    'Contentment': 0,
    'Stress Levels': 0,
    'Sleep Quality': 0,
    'Energy Levels': 0,
    'Social Interactions': 0,
    'Concentration': 0,
    'Sense of Purpose': 0,
    'Anxiety': 0,
    'Coping Skills': 0,
    'Overall Well-being': 0,
  };

  String result = "";
  bool showResult = false;

  @override
  void initState() {
    super.initState();
  }

  void analyzeMentalHealth() {
    Map<String, List<int>> scoringCriteria = {
      'Contentment': [0, 1, 2, 3, 4],
      'Stress Levels': [0, 1, 2, 3, 4],
      'Sleep Quality': [0, 1, 2, 3, 4],
      'Energy Levels': [0, 1, 2, 3, 4],
      'Social Interactions': [0, 1, 2, 3, 4],
      'Concentration': [0, 1, 2, 3, 4],
      'Sense of Purpose': [0, 1, 2, 3, 4],
      'Anxiety': [0, 1, 2, 3, 4],
      'Coping Skills': [0, 1, 2, 3, 4],
      'Overall Well-being': [0, 1, 2, 3, 4],
    };

    int totalScore = quizResponses.entries.fold(
      0,
      (previousValue, entry) =>
          previousValue +
          (scoringCriteria[entry.key]?.elementAt(entry.value) ?? 0),
    );

    if (totalScore <= 10) {
      result = "Low Risk of Mental Health Issues";
    } else if (10 < totalScore && totalScore <= 20) {
      result = "Moderate Risk of Mental Health Issues";
    } else {
      result = "High Risk of Mental Health Issues";
    }

    // Store the result in Firebase
    storeMentalHealthResult(result);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MentalHealthResult(result: result),
      ),
    );
  }

  void storeMentalHealthResult(String result) {
    String? userEmail = widget.user?.email; // Replace with your user object
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    users
        .where('email', isEqualTo: userEmail)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((DocumentSnapshot document) {
        document.reference.update({'mental_health': result});
      });
    });
  }

  Widget buildQuestion(String question, String key) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(fontSize: 18),
        ),
        RadioListTile<int>(
          title: Text('Not at all'),
          value: 0,
          groupValue: quizResponses[key],
          onChanged: (value) {
            setState(() {
              quizResponses[key] = value!;
            });
          },
        ),
        RadioListTile<int>(
          title: Text('A little'),
          value: 1,
          groupValue: quizResponses[key],
          onChanged: (value) {
            setState(() {
              quizResponses[key] = value!;
            });
          },
        ),
        RadioListTile<int>(
          title: Text('Moderately'),
          value: 2,
          groupValue: quizResponses[key],
          onChanged: (value) {
            setState(() {
              quizResponses[key] = value!;
            });
          },
        ),
        RadioListTile<int>(
          title: Text('Quite a bit'),
          value: 3,
          groupValue: quizResponses[key],
          onChanged: (value) {
            setState(() {
              quizResponses[key] = value!;
            });
          },
        ),
        RadioListTile<int>(
          title: Text('Extremely'),
          value: 4,
          groupValue: quizResponses[key],
          onChanged: (value) {
            setState(() {
              quizResponses[key] = value!;
            });
          },
        ),
        SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mental Health Analysis'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            buildQuestion(
                'I have been feeling generally content and satisfied.',
                'Contentment'),
            buildQuestion(
                'I have experienced stress or tension.', 'Stress Levels'),
            buildQuestion(
                'My sleep has been restful and rejuvenating.', 'Sleep Quality'),
            buildQuestion(
                'I have felt energetic and motivated.', 'Energy Levels'),
            buildQuestion('I have engaged in positive social interactions.',
                'Social Interactions'),
            buildQuestion('I have been able to concentrate and focus on tasks.',
                'Concentration'),
            buildQuestion('I have a sense of purpose and direction in my life.',
                'Sense of Purpose'),
            buildQuestion(
                'I have experienced feelings of anxiety or nervousness.',
                'Anxiety'),
            buildQuestion(
                'I have used healthy coping mechanisms to deal with stress.',
                'Coping Skills'),
            buildQuestion(
                'I feel a sense of overall well-being.', 'Overall Well-being'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                analyzeMentalHealth();
                setState(() {
                  showResult = true;
                });
              },
              child: Text('Submit'),
            ),
            if (showResult)
              Container(
                margin: EdgeInsets.only(top: 20),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple[100], // Light purple background color
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      'Result:',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 10),
                    Text(
                      result,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MentalHealthResult extends StatelessWidget {
  final String result;

  MentalHealthResult({required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mental Health Result'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Result:',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                result,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
