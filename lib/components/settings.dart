import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Settings extends StatelessWidget {

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

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
          User user = await firebaseAuth.currentUser;
          user.delete();
          Navigator.of(context).pushNamed("/opening");
        },
        child: Text(
          "Delete account"
        ),
      ),
    );
  }
}

