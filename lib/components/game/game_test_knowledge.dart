import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:schoolapp/components/contact_list/contactsFromList.dart';
import 'package:schoolapp/services/listService.dart';
import 'package:tcard/tcard.dart';
import 'game_card.dart';
import 'game_main.dart';
import 'resume/game_test_knowledge_resume.dart';

class GameTestKnowledge extends StatefulWidget {
  static String numberChoose;
  static List<GameCard> gameCard;
  static String listDoc;

  GameTestKnowledge(List<GameCard> gc, String nb, String id) {
    gameCard = gc;
    numberChoose = nb;
    listDoc = id;
  }

  @override
  _GameTestKnowledge createState() => _GameTestKnowledge();
}

final User user = auth.currentUser;
final FirebaseAuth auth = FirebaseAuth.instance;

class _GameTestKnowledge extends State<GameTestKnowledge> {
  ListService _listService = new ListService();

  //Card list
  List<Widget> cardList = new List();

  //Controller for input text
  TextEditingController inputController = new TextEditingController();

  //Card controller (go forward...)
  TCardController _controller = TCardController();

  //Card done management
  double cardDonePercent = 0;
  String cardDoneProgressionText = "0%";

  //Gamecard wrong to send to the game resume
  List<GameCard> wrongContactCard = new List<GameCard>();

  FocusNode myFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    myFocusNode.requestFocus();
    return Scaffold(
      appBar: AppBar(
        title: Text("Test mode"),
        leading: GestureDetector(
          onTap: () {
            showAlertDialog(context);
          },
          child: IconTheme(
            data: Theme.of(context).iconTheme,
            child: Icon(
              Icons.arrow_back,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AbsorbPointer(
              absorbing: true,
              child: TCard(
                cards: _generateCards(),
                size: Size(260, 320),
                controller: _controller,
              ),
            ),
            // _triggerWrongAnswers(),
            // Padding(
            //   padding: EdgeInsets.only(left: 20.0, right: 10.0),
            //   child: LinearPercentIndicator(
            //     width: 300.0,
            //     lineHeight: 20.0,
            //     percent: cardDonePercent,
            //     center: Text(cardDoneProgressionText),
            //     linearStrokeCap: LinearStrokeCap.butt,
            //     backgroundColor: Colors.grey,
            //     progressColor: Colors.cyan,
            //   ),
            // ),
            // SizedBox(height: 10.0),
            Row(
              children: [
                Expanded(
                  child: Container(
                    width: 300,
                    margin: const EdgeInsets.only(right: 0, left: 20),
                    child: TextFormField(
                      controller: inputController,
                      // focusNode: myFocusNode,
                      obscureText: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Who is this person ? (fullname)',
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: Container(
                    child: IconButton(
                        icon: Icon(Icons.done, size: 40.0, color: Colors.green),
                        onPressed: () {
                          print("bar progression += " +
                              int.parse(GameTestKnowledge.numberChoose)
                                  .floor()
                                  .toString());
                          setState(() {
                            cardDonePercent += 1 /
                                int.parse(GameTestKnowledge.numberChoose)
                                    .floor();
                            cardDoneProgressionText =
                                (cardDonePercent * 100).floor().toString() +
                                    "%";
                          });

                          //Test input and answer
                          //False => push it to firestore array of wrong answers
                          //True  => remove the id in array of wrong ansers if exist
                          if (testInputAccordingToCard(
                              inputController.text,
                              GameTestKnowledge
                                  .gameCard[_controller.index].firstname,
                              GameTestKnowledge
                                  .gameCard[_controller.index].lastname)) {
                            _listService.removeIdToWrongAnswers(
                                GameTestKnowledge.listDoc,
                                GameTestKnowledge
                                    .gameCard[_controller.index].id);
                          } else {
                            _listService.addIdToWrongAnswers(
                                GameTestKnowledge.listDoc,
                                GameTestKnowledge
                                    .gameCard[_controller.index].id);
                          }

                          //If the game is finished
                          if (_controller.index >=
                                  GameTestKnowledge.gameCard.length - 1 ||
                              _controller.index >=
                                  int.parse(GameTestKnowledge.numberChoose) -
                                      1) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      GameTestKnowledgeResume()),
                            );
                          }

                          //Reset the input
                          inputController.text = "";

                          //Move to next card
                          _controller.forward();
                        }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget quitButton = FlatButton(
      color: Colors.red,
      child: Text("Quit"),
      onPressed: () {
        _listService.resetWrongContactFromTheList(GameScreen.listDoc, '0');
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ContactFromList(ContactFromList.listDoc)),
        );
      },
    );

    // set up the button
    Widget stayButton = FlatButton(
      color: Colors.cyan,
      child: Text("Stay", style: TextStyle(color: Colors.white)),
      onPressed: () {
        Navigator.of(context).pop(false);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning),
          Text(' WARNING'),
        ],
      ),
      content: Text(
          "Know that by leaving, the game and the score will be resetting."),
      actions: [
        stayButton,
        quitButton,
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

  List<Widget> _generateCards() {
    if (GameTestKnowledge.numberChoose == null) {
      GameTestKnowledge.numberChoose =
          GameTestKnowledge.gameCard.length.toString();
    }

    int loopIteration = int.parse(GameTestKnowledge.numberChoose);
    if (int.parse(GameTestKnowledge.numberChoose) >
        GameTestKnowledge.gameCard.length) {
      loopIteration = GameTestKnowledge.gameCard.length;
    }

    for (int x = 0; x < loopIteration; x++) {
      cardList.add(Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              GameTestKnowledge.gameCard[x].image,
            ),
            fit: BoxFit.fitWidth,
          ),
          shape: BoxShape.rectangle,
        ),
      ));
    }
    return cardList;
  }

  void removeCards(index) {
    setState(() {
      cardList.removeAt(index);
    });
  }

  bool testInputAccordingToCard(
      String inputFirstname, String answerFirstname, String answerLastname) {
    String firstnameLastname =
        answerFirstname.toLowerCase() + " " + answerLastname.toLowerCase();
    String lastnameFirstname =
        answerLastname.toLowerCase() + " " + answerFirstname.toLowerCase();

    if (inputFirstname.toLowerCase() == firstnameLastname ||
        inputFirstname.toLowerCase() == lastnameFirstname) {
      return true;
    } else {
      return false;
    }
  }
}
