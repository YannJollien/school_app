import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:schoolapp/components/game/game_card.dart';
import 'package:schoolapp/components/learning/learning_mode.dart';
import 'package:schoolapp/services/listService.dart';
import 'game/game_test_knowledge.dart';
import 'game/game_test_knowledge_resume.dart';

class GameScreen extends StatefulWidget {
  static String listDoc;
  static List<GameCard> gameCard;

  GameScreen(String listId, List<GameCard> gc) {
    gameCard = gc;
    listDoc = listId;
  }

  @override
  _GameScreenState createState() => _GameScreenState(listDoc);
}

class _GameScreenState extends State<GameScreen> {
  _GameScreenState(data);

  String numberChoose;
  String gameMode;

  ListService _listService = ListService();

  bool textDropDownVisible = false;

  bool textGameModeVisible = false;

  //Toggled game mode choosen
  List<bool> toggledButtonGameMode = [false, true];

  List<GameCard> gameCardMode;

  bool enableGame ;
  var _onPressedTestMode ;
  var _onPressedLearningMode ;

  @override
  Widget build(BuildContext context) {
    //Dropdown list management
    //Display number in the dropdown list according to number of card (25%, 50%, 75% and 100%)
    List<String> dropdownNumberOfContact = List<String>();
    for (double i = 0.25; i <= 1.0; i += 0.25) {
      //Test if the number is already in the dropdown list and block if rounded to 0
      if (!dropdownNumberOfContact
              .contains((GameScreen.gameCard.length * i).round().toString()) &&
          (GameScreen.gameCard.length * i).round() != 0) {
        dropdownNumberOfContact
            .add((GameScreen.gameCard.length * i).round().toString());
      }
    }

    //If no contact in list disable the button to lauch the game
    if(GameScreen.gameCard.length==0){
      setState(() {
        enableGame = false;
        _onPressedTestMode = null;
        _onPressedLearningMode = null;
      });
    }else{
      setState(() {
        enableGame = true;
        _onPressedTestMode = (){
          // print("NUMBER CHOOSEN " + numberChoose)
          if(numberChoose==null){
            setState(() {
              numberChoose=gameCardMode.length.toString();
            });
          }
          // _listService.resetWrongContactFromTheList(GameScreen.listDoc, numberChoose);
          gameCardMode.shuffle();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => GameTestKnowledge(
                    gameCardMode,
                    numberChoose,
                    GameScreen.listDoc)),
          );
        };
        _onPressedLearningMode = (){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => LearningMode(
                    gameCardMode, numberChoose)),
          );
        };
      });
    }


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Game"),
      ),
      body: Column(
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              "Let's play !",
              style: TextStyle(
                  color: Colors.lightBlue[800],
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(
              child: Text(
                "Choose the game mode",
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ToggleButtons(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 15.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.done_all),
                        ),
                        Text('ALL     '),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 15.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.not_interested),
                        ),
                        Text('WRONG'),
                      ],
                    ),
                  ),
                ],
                onPressed: (int index) {
                  setState(() {
                    switch (index) {
                      case 0:
                        gameMode = "all";
                        toggledButtonGameMode[0] = true;
                        toggledButtonGameMode[1] = false;
                        gameCardMode = GameScreen.gameCard;
                        break;
                      case 1:
                        gameMode = "wrong";
                        toggledButtonGameMode[0] = false;
                        toggledButtonGameMode[1] = true;
                        break;
                    }
                  });
                },
                isSelected: toggledButtonGameMode,
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Total : '),
              (toggledButtonGameMode[0])
                  ? Text(GameScreen.gameCard.length.toString())
                  : _buildWrongCard(),
            ],
          ),
          (gameMode == "all")
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Chose the number of contact : '),
                    DropdownButton<String>(
                      items: dropdownNumberOfContact.map((String value) {
                        return new DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value),
                        );
                      }).toList(),
                      onChanged: (String newValue) {
                        setState(() {
                          numberChoose = newValue;
                        });
                      },
                      value: numberChoose,
                    ),
                  ],
                )
              : Text(''),
          FlatButton(
            color: Colors.lightBlue,
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GameTestKnowledgeResume()),
              );
            },
            child: Text("List review"),
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
                          onPressed: _onPressedLearningMode,
                          child: Text("Learning"),
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: FlatButton(
                          onPressed: (){
                            if(numberChoose==null){
                              setState(() {
                                numberChoose=gameCardMode.length.toString();
                              });
                            }
                            _listService.resetWrongContactFromTheList(GameScreen.listDoc, numberChoose);
                            gameCardMode.shuffle();
                            // print("number selected " + numberChoose);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GameTestKnowledge(
                                      gameCardMode,
                                      numberChoose,
                                      GameScreen.listDoc)),
                            );
                          },
                          color: Colors.lightBlue,
                          child: Text("Test my knowledge"),
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

  Widget _buildWrongCard() {
    return FutureBuilder(
        future: _listService.getContactIdWrongOfTheList(GameScreen.listDoc),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot1) {
          List<dynamic> contactsId;
          if (snapshot1.connectionState == ConnectionState.done) {
            contactsId = snapshot1.data['wrongAnswers'];
            return FutureBuilder(
                future: _listService.getWrongContactFromTheList(contactsId),
                builder: (BuildContext context,
                    AsyncSnapshot<List<GameCard>> snapshot2) {
                  // print(snapshot2.data);
                  gameCardMode = snapshot2.data;
                  return (snapshot2.connectionState == ConnectionState.done)
                      ? Text(snapshot2.data.length.toString())
                      : Text('Loading...');
                });
          }
          return Text('Loading...');
        });
  }
}
