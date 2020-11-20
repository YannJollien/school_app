import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Opening extends StatefulWidget {
  @override
  _OpeningState createState() => _OpeningState();
}

class _OpeningState extends State<Opening> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Welcome"
        )
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              color: Colors.lightBlue,
                onPressed: () {
                  Navigator.of(context).pushNamed("/login");
                },
                child: Text(
                  "Login"
                )
            ),
            FlatButton(
                color: Colors.lightBlue,
                onPressed: () {
                  Navigator.of(context).pushNamed("/register");
                },
                child: Text(
                    "Register"
                )
            ),
          ],
        ),
      ),
    );
  }
}



