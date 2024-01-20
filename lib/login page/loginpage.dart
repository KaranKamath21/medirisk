import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:medirisk/login%20page/register_page.dart';
import '../authentication/auth.dart';
import '../homepage/homepage.dart';
import '../location finctionality/ui.dart';
import '../utils/loading.dart';
import '../utils/mybutton.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  static String routeName = 'LoginPage';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool signedIn = false;
  String email = '';
  String password = '';
  String error = '';
  User? user;

  popMsg(String msg) {
    Fluttertoast.showToast(msg: msg);
  }

  //imported from mytexfield.dart
  // late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    checkUserLoggedIn();
    // _focusNode = FocusNode();
  }

  void checkUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      // If the user is already logged in, navigate to the home page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UI(user: FirebaseAuth.instance.currentUser),
        ),
      );
    }
  }

  void saveLoggedInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
  }

  @override
  void dispose() {
    // _focusNode.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String value) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.nextFocus();
    }
  }
  //end

  void signUserIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() => loading = true);

      dynamic result = await _auth.signInWithEmailAndPassword(email, password);
      if (result == null) {
        Fluttertoast.showToast(msg: "Please check your email and password");

        setState(() {
          loading = false;
        });
      } else {
        user = FirebaseAuth.instance.currentUser;

        Fluttertoast.showToast(msg: "Login Successful");
        setState(() {
          loading = false;
        });

        setState(() => password = '');

        // Save the logged-in status
        saveLoggedInStatus();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UI(user: user),
          ),
        );
      }
    }
  }

  void sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Password reset email sent to $email'),
      ));
    } catch (error) {
      Fluttertoast.showToast(
          msg: 'Error sending password reset email: ${error.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to send password reset email'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : SafeArea(
            child: Scaffold(
            backgroundColor: Colors.white,
            body: _LoginUi(context),
          ));
  }

  Widget _LoginUi(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),

            // logo
            const Icon(
              Icons.medical_services_outlined,
              color: Colors.black,
              size: 100,
            ),

            const SizedBox(height: 25),

            // welcome back, you've been missed!
            Text(
              'Welcome back!!',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            // Email TextField
            Container(
              width: MediaQuery.of(context).size.width * 0.875,
              child: TextFormField(
                onChanged: (value) {
                  setState(() => email = value);
                },
                validator: (value) =>
                    value!.isEmpty ? popMsg('Enter your email ID') : null,
                controller: usernameController,
                // focusNode: _focusNode,
                obscureText: false,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(12.00)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  fillColor: Colors.grey[200],
                  filled: true,
                  prefixIcon: const Icon(Icons.account_circle_outlined),
                  hintText: 'Email',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                textInputAction: TextInputAction.next,
                // onSubmitted: _handleSubmitted,
              ),
            ),

            const SizedBox(height: 10),

            // Password TextField
            Container(
              width: MediaQuery.of(context).size.width * 0.875,
              child: TextFormField(
                onChanged: (value) {
                  setState(() => password = value);
                },
                validator: (value) =>
                    value!.isEmpty ? popMsg('Enter you password') : null,
                controller: passwordController,
                // focusNode: _focusNode,
                obscureText: true,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(12.00)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  fillColor: Colors.grey[200],
                  filled: true,
                  prefixIcon: const Icon(Icons.lock),
                  hintText: 'Password',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                textInputAction: TextInputAction.next,
                // onSubmitted: _handleSubmitted,
              ),
            ),

            const SizedBox(height: 10),

            // Forgot Password?
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: Text('Forgot Password?'),
                    onPressed: () => sendPasswordResetEmail(email),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            MyButton(
              text: 'Sign In',
              onTapFunction: signUserIn,
            ),

            const SizedBox(height: 20),

            // Not a member? register now
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Not a member?',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(width: 4),
                TextButton(
                    child: const Text('Register Now'),
                    // onPressed: () {},
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterPage()))),
              ],
            )
          ],
        ),
      ),
    );
  }
}
