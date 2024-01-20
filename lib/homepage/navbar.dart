import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medirisk/homepage/user_profile.dart';
import '../login%20page/loginpage.dart';

class NavBar extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Drawer(
      child: Column(
        children: <Widget>[
          if (user != null)
            UserAccountsDrawerHeader(
              accountName: Text(user.displayName ?? ""),
              accountEmail: Text(user.email ?? ""),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/images/image_6.png'),
              ),
            ),
          ListTile(
            leading: Icon(Icons.person),
            title: const Text('Your Profile'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePage(
                            user: user,
                          )));
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('History'),
            onTap: () {
              // TODO Navigate to your disease history page
            },
          ),
          Spacer(),
          ListTile(
            leading: Icon(Icons.logout),
            title: const Text('Log Out'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Confirm Log Out'),
                    content: Text('Are you sure you want to log out?'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Yes'),
                        onPressed: () {
                          _signOut(context);
                        },
                      ),
                      TextButton(
                        child: Text('No'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
