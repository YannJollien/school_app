import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:schoolapp/services/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatelessWidget {

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Setting"
        ),
      ),
      body: FlatButton(
        onPressed: () async {
          _auth.deleteUser();
          //Remove from fp to stop auto logged in
          //SharedPreferences prefs = await SharedPreferences.getInstance();
          //prefs.remove('email');
          Navigator.of(context).pushNamed("/opening");
        },
        child: Text(
          "Delete account"
        ),
      ),
    );
  }
}

