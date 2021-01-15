import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:schoolapp/components/game/game_card.dart';
import 'package:schoolapp/components/learning/learning_mode.dart';
import 'package:schoolapp/services/listService.dart';
import '../contact_list/contactsFromList.dart';
import 'game_test_knowledge.dart';
import 'resume/game_test_knowledge_resume.dart';

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

/// CLASS TO CHOOSE GAME MODE
class _GameScreenState extends State<GameScreen> {

  //Constructor
  _GameScreenState(data);

  //Game management
  String numberChoose = GameScreen.gameCard.length.toString();
  String gameMode = "";
  bool textDropDownVisible = false;
  bool textGameModeVisible = false;
  List<GameCard> gameCardMode;

  //Database management
  ListService _listService = ListService();

  //Toggled game mode choosen
  List<bool> toggledButtonGameMode = [false, false];

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Game"),
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ContactFromList(ContactFromList.listDoc)),
            );
          },
          child: IconTheme(
            data: Theme.of(context).iconTheme,
            child: Icon(
              Icons.arrow_back,
            ),
          ),
        ),
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
              Text('Total contact : '),
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
              : Container(),
          SizedBox(height: 20.0),
          FlatButton.icon(
            icon: Icon(Icons.preview),
            label: Text('Last game with ' +
                ContactFromList.listDoc.data()['listName'] +
                " list"),
            color: Colors.lightBlue,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GameTestKnowledgeResume()),
              );
            },
          ),
          (GameScreen.gameCard.length == 0 || gameMode == "")
              ? Container()
              : Expanded(
                  child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 30.0),
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 200,
                              child: FlatButton(
                                color: Colors.lightBlue,
                                onPressed: () {
                                  if (gameCardMode.length != 0) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LearningMode(
                                              gameCardMode, numberChoose)),
                                    );
                                  } else {
                                    showAlertDialog(context);
                                  }
                                },
                                child: Text("Learning"),
                              ),
                            ),
                            SizedBox(
                              width: 200,
                              child: FlatButton(
                                onPressed: () {
                                  if (gameCardMode.length != 0) {
                                    if (numberChoose == null) {
                                      setState(() {
                                        numberChoose =
                                            gameCardMode.length.toString();
                                      });
                                    }
                                    //all contact
                                    if (toggledButtonGameMode[0]) {
                                      _listService.resetWrongContactFromTheList(
                                          GameScreen.listDoc, numberChoose);
                                    }
                                    //wrong only
                                    else {
                                      _listService.resetWrongContactFromTheList(
                                          GameScreen.listDoc,
                                          gameCardMode.length.toString());
                                    }

                                    gameCardMode.shuffle();
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              GameTestKnowledge(
                                                  gameCardMode,
                                                  numberChoose,
                                                  GameScreen.listDoc)),
                                    );
                                  } else {
                                    showAlertDialog(context);
                                  }
                                },
                                color: Colors.lightBlue,
                                child: Text("Test my knowledge"),
                              ),
                            ),
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

  //Alert dialog if contact list is empty
  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop(false);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Oops..."),
      content: Text("You have no wrong contacts for this list, play again !"),
      actions: [
        okButton,
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

  //Wrong card builder
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
