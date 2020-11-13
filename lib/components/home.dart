import 'package:flutter/material.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          color: Colors.cyan[300],
          child: Padding(
            padding: EdgeInsets.fromLTRB(10.0, 40.0, 10.0, 0),
            child: Column(
              children: <Widget>[
                Text(
                    "Hello",
                  style: TextStyle(
                    fontSize: 40.0,
                    color: Colors.white,
                    letterSpacing: 2.0
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                ButtonTheme(
                  minWidth: 200.0,
                  height: 50.0,
                  child: RaisedButton(
                    onPressed: () {
                      //Navigator.pusheNamed(context, '/list'); //Navigate to lists
                      Navigator.pushNamed(context, '/list');
                    },
                    color: Colors.blue[100],
                    child: Text(
                      "My lists",
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                ButtonTheme(
                  minWidth: 200.0,
                  height: 50.0,
                  child: RaisedButton(

                    onPressed: () {},
                    color: Colors.blue[100],
                    child: Text(
                      "Add to lists",
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                ButtonTheme(
                  minWidth: 200.0,
                  height: 50.0,
                  child: RaisedButton(

                    onPressed: () {},
                    color: Colors.blue[100],
                    child: Text(
                      "Game",
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
