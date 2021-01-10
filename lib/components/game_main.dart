import 'package:flutter/material.dart';
import 'package:schoolapp/components/game/game_card.dart';
import 'package:schoolapp/components/learning/learning_mode.dart';
import 'game/game_test_knowledge.dart';

class GameScreen extends StatefulWidget {
  static String listDoc;
  static List<GameCard> gameCard ;

  GameScreen(String listId, List<GameCard> gc) {
    gameCard = gc;
    listDoc = listId;
  }

  @override
  _GameScreenState createState() => _GameScreenState(listDoc);
}

class _GameScreenState extends State<GameScreen> {
  _GameScreenState(data);

  String numberChose;
  String gameMode;

  bool textDropDownVisible = false;

  bool textGameModeVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
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
                        "Chose the number of contact",
                    ),
                  ),
                ),
                DropdownButton<String>(
                  items: <String>['1', '3', '5', '7', '9', '10'].map((String value) {
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
            padding: EdgeInsets.only(top: 10.0)
          ),
          Visibility(
            visible: textDropDownVisible,
            child: Text(
                "Please select number of contact",
                style: TextStyle(
                    color: Colors.red,
                ),
              ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 30.0),
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
          Visibility(
            visible: textGameModeVisible,
            child: Text(
              "Please select game mode",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 30.0),
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        SizedBox(
                          width: 200,
                          child: FlatButton(
                            color: Colors.lightBlue,
                            onPressed: () {
                              if(numberChose == null){
                                setState(() {
                                  textDropDownVisible = true;
                                });
                              } if (gameMode == null){
                                setState(() {
                                  textGameModeVisible = true;
                                });
                              }
                              else {
                                //Reset visibility texts
                                setState(() {
                                  textDropDownVisible = false;
                                  textGameModeVisible = false;
                                });
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => LearningMode(GameScreen.gameCard, numberChose)),
                                );
                              }
                            },
                            child: Text(
                                "Learning"
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: FlatButton(
                            onPressed: () {
                              if(numberChose == null){
                                setState(() {
                                  textDropDownVisible = true;
                                });
                              } if (gameMode == null){
                                setState(() {
                                  textGameModeVisible = true;
                                });
                              }
                              else {
                                //Reset visibility texts
                                setState(() {
                                  textDropDownVisible = false;
                                  textGameModeVisible = false;
                                });
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => GameTestKnowledge(numberChose)),
                                );
                              }
                            },
                            color: Colors.lightBlue,
                            child: Text(
                                "Test my knowledge"
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
