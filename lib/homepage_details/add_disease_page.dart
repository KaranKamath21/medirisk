import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddDiseasePage extends StatefulWidget {
  final User? user;

  AddDiseasePage({required this.user});

  @override
  _AddDiseasePageState createState() => _AddDiseasePageState();
}

class _AddDiseasePageState extends State<AddDiseasePage> {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  TextEditingController _nameController = TextEditingController();
  bool _isRespiratory = false;
  bool _isCardiac = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Disease'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Disease Name'),
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Text('Respiratory Disease?'),
                Checkbox(
                  value: _isRespiratory,
                  onChanged: (value) {
                    setState(() {
                      _isRespiratory = value ?? false;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Text('Cardiovascular Disease?'),
                Checkbox(
                  value: _isCardiac,
                  onChanged: (value) {
                    setState(() {
                      _isCardiac = value ?? false;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFDDDAE7),
              ),
              onPressed: () async {
                // Get the disease name from the user
                String diseaseName = _nameController.text;

                try {
                  // Fetch the current user's document from Firestore based on email
                  QuerySnapshot userSnapshot = await usersCollection
                      .where('email', isEqualTo: widget.user?.email)
                      .get();

                  if (userSnapshot.docs.isNotEmpty) {
                    // Get the first document (assuming there's only one matching user)
                    DocumentSnapshot userDocument = userSnapshot.docs.first;

                    // Check if the 'diseases' field exists
                    if (userDocument.exists) {
                      Map<String, dynamic>? userData =
                          userDocument.data() as Map<String, dynamic>?;

                      // Create a new disease object
                      Map<String, dynamic> newDisease = {
                        'name': diseaseName,
                        'isRespiratory': _isRespiratory,
                        'isCardiovascular': _isCardiac,
                      };

                      // Check if 'diseases' field exists and has data
                      if (userData != null &&
                          userData.containsKey('diseases')) {
                        // Extract the current diseases list
                        List<Map<String, dynamic>> currentDiseases =
                            List.from(userData['diseases']);

                        // Add the new disease to the list
                        currentDiseases.add(newDisease);

                        // Update the user's document in Firestore with the new diseases list
                        await usersCollection.doc(userDocument.id).update({
                          'diseases': currentDiseases,
                          // 'isRespiratory': _isRespiratory,
                        });

                        if (_isRespiratory == true &&
                            userData['isRespiratory'] == false) {
                          // Update the user's document in Firestore with the new respiratory status
                          await usersCollection.doc(userDocument.id).update({
                            'isRespiratory': _isRespiratory,
                          });
                        }
                        if (_isCardiac == true &&
                            userData['isCardiovascular'] == false) {
                          // Update the user's document in Firestore with the new respiratory status
                          await usersCollection.doc(userDocument.id).update({
                            'isCardiovascular': _isCardiac,
                          });
                        }
                      } else {
                        // If 'diseases' field doesn't exist, create it with the new disease
                        await usersCollection.doc(userDocument.id).set(
                          {
                            'diseases': [newDisease],
                            'isRespiratory': _isRespiratory,
                            'isCardiovascular': _isCardiac,
                          },
                          SetOptions(merge: true),
                        );
                      }

                      // Pop the page to go back
                      Navigator.pop(context, true);
                    }
                  } else {
                    print('User document not found.');
                    // Handle the case where the user document is not found
                  }
                } catch (e) {
                  print('Error adding disease: $e');
                  // Handle errors as needed
                }
              },
              child: Text('Add Disease'),
            ),
          ],
        ),
      ),
    );
  }
}
