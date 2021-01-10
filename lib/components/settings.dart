import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:schoolapp/services/auth.dart';

class Settings extends StatelessWidget {

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text(
          "Setting", style: Theme.of(context).textTheme.headline1
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                "Account",
                style: TextStyle(
                  color: Colors.cyan[400],
                  fontSize: 20.0
                ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: FlatButton(
              onPressed: () async {
                _auth.deleteUser();
                //Remove from fp to stop auto logged in
                //SharedPreferences prefs = await SharedPreferences.getInstance();
                //prefs.remove('email');
                Navigator.of(context).pushNamed("/login");
              },
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                    "Delete account"
                ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: FlatButton(
              onPressed: () async {
                Navigator.of(context).pushNamed("/password");
              },
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                    "Change password",
                ),
              ),
            ),
          ),
          ToggleButtons(
            children: <Widget>[
              Icon(Icons.wb_sunny),
              Icon(Icons.nights_stay),
            ],
            // onPressed: (int index) {
            //   setState(() {
            //     isSelected[index] = !isSelected[index];
            //   });
            // },
            isSelected: toggled,
          ),
        ],
      )
    );
  }

  List<bool> toggled = [false, true];
}

