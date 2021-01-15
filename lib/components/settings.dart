import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:schoolapp/services/auth.dart';
import 'home_drawer.dart';
import 'login.dart';

class Settings extends StatefulWidget {
  @override
  SettingsState createState() {
    return SettingsState();
  }
}

class SettingsState extends State<Settings> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Settings", style: Theme.of(context).textTheme.headline1),
        ),
        drawer: HomeDrawer(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  "Account",
                  style: TextStyle(color: Colors.cyan[400], fontSize: 20.0),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FlatButton(
                onPressed: () async {
                  showAlertDialog(context);
                },
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text("Delete account"),
                ),
              ),
            ),
          ],
        ));
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel", style: TextStyle(color: Colors.white)),
      color: Colors.cyan,
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Delete"),
      color: Colors.red,
      onPressed: () {
        _auth.deleteUser();
        //Go to opening page when logged out
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Confirm'),
      content: RichText(
        text: new TextSpan(
          // Note: Styles for TextSpans must be explicitly defined.
          // Child text spans will inherit styles from parent
          style: new TextStyle(
            fontSize: 16.0,
            color: Colors.black,
          ),
          children: <TextSpan>[
            new TextSpan(text: "Are you sure you want to delete your account "),
            new TextSpan(
                text: ' definitively ?',
                style: new TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
