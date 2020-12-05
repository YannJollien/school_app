import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {

  String numberChose;
  String gameMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Game"
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              "Let's play !",
              style: TextStyle(
                color: Colors.lightBlue[800],
                fontSize: 30.0,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          Padding(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center, //Center Row contents horizontally,
                crossAxisAlignment: CrossAxisAlignment.center, //Center Row contents vertically,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                        "Chose the number of contact"
                    ),
                  ),
                ),
                DropdownButton<String>(
                  items: <String>['1', '5', '9', '10'].map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
                  onChanged: (String newValue) {
                    setState(() {
                        numberChose = newValue;
                    });
                  },
                  value: numberChose,
                )
              ],
            ),
            padding: EdgeInsets.all(10.0),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Text(
              "Game mode: ",
              style: TextStyle(
                  color: Colors.lightBlue[800],
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
          ListTile(
            title: const Text('All contacts'),
            leading: Radio(
              value: "All",
              groupValue: gameMode,
              onChanged: (String value) {
                setState(() {
                  gameMode = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Wrong answers'),
            leading: Radio(
              value: "Wrong",
              groupValue: gameMode,
              onChanged: (String value) {
                setState(() {
                  gameMode = value;
                });
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 200.0),
            child: SizedBox(
              width: 200,
              child: FlatButton(
                color: Colors.lightBlue,
                onPressed: () {},
                child: Text(
                  "Training"
                ),
              ),
            ),
          ),
          SizedBox(
            width: 200,
            child: FlatButton(
              onPressed: () {},
              color: Colors.lightBlue,
              child: Text(
                  "Test my knowledge"
              ),
            ),
          )
        ],
      ),
    );
  }
}
