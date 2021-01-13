import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:schoolapp/components/game/game_card.dart';
import 'package:schoolapp/components/learning/learning_mode.dart';
import 'package:schoolapp/services/listService.dart';
import 'package:tcard/tcard.dart';
import '../game_main.dart';
import 'game_test_knowledge_resume.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test mode"),
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
                size: Size(350, 450),
                controller: _controller,
                onForward: (index, info) {
                  // _index = index;
                  // print("INFOR DIRECTION : " + info.direction.toString());
                },
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
            SizedBox(height: 10.0),
            Row(
              children: [
                Expanded(
                  child: Container(
                    width: 300,
                    margin: const EdgeInsets.only(right: 0, left: 30),
                    child: TextFormField(
                      controller: inputController,
                      obscureText: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Answer',
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 30.0),
                  child: Container(
                    child: IconButton(
                        icon: Icon(Icons.done, size: 40.0, color: Colors.green),
                        onPressed: () {
                          print("bar progression += " + int.parse(GameTestKnowledge.numberChoose).floor().toString());
                          setState(() {
                            cardDonePercent +=
                                1 / int.parse(GameTestKnowledge.numberChoose).floor();
                            cardDoneProgressionText =
                                (cardDonePercent * 100).floor().toString() +
                                    "%";
                          });

                          //Test input and answer
                          //False => push it to firestore array of wrong answers
                          //True  => remove the id in array of wrong ansers if exist
                          if(testInputAccordingToCard(inputController.text, GameTestKnowledge.gameCard[_controller.index].firstname)){
                            _listService.removeIdToWrongAnswers(GameTestKnowledge.listDoc, GameTestKnowledge.gameCard[_controller.index].id);
                          }else{
                            _listService.addIdToWrongAnswers(GameTestKnowledge.listDoc, GameTestKnowledge.gameCard[_controller.index].id);
                          }

                          //If the game is finished
                          if(_controller.index == int.parse(GameTestKnowledge.numberChoose)-1){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GameTestKnowledgeResume()),
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
      cardList.add(
        Positioned(
          top: 70.0,
          child: Draggable(
              onDragEnd: (drag) {
                removeCards(x);
              },
              childWhenDragging: Container(),
              feedback: GestureDetector(
                onTap: () {},
                child: Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  // color: Color.fromARGB(250, 112, 19, 179),
                  child: Column(
                    children: <Widget>[
                      Hero(
                        tag: "imageTag",
                        child: Image.network(
                          GameTestKnowledge.gameCard[x].image,
                          height: 440.0,
                          width: 320.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              child: GestureDetector(
                onTap: () {},
                child: Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    // color: Color.fromARGB(250, 112, 19, 179),
                    child: Column(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            image: DecorationImage(
                                image: NetworkImage(
                                    GameTestKnowledge.gameCard[x].image),
                                fit: BoxFit.cover),
                          ),
                          height: 397.0,
                          width: 320.0,
                        ),
                      ],
                    )),
              )),
        ),
      );
    }
    return cardList;
  }

  void removeCards(index) {
    setState(() {
      cardList.removeAt(index);
    });
  }

  Widget _triggerWrongAnswers() {
    return StreamBuilder(
      stream: _listService.getContactIdWrongOfTheListStream(GameScreen.listDoc),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot1) {
        return FutureBuilder(
            future: _listService.getContactIdWrongOfTheList(GameScreen.listDoc),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot1) {
              List<dynamic> contactsId;
              if (snapshot1.connectionState == ConnectionState.done) {
                contactsId = snapshot1.data['wrongAnswers'];
                return FutureBuilder(
                    future: _listService.getWrongContactFromTheList(contactsId),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<GameCard>> snapshot2) {
                      // print("instance ? " + snapshot2.data.toString());
                      wrongContactCard = snapshot2.data;
                      return (snapshot2.connectionState == ConnectionState.done)
                          ? Container()
                          : Container();
                    });
              }
              return Container();
            });
      },
    );
  }

  bool testInputAccordingToCard(String inputFirstname, String answerFirstname) {
    if(inputFirstname == answerFirstname){
      return true ;
    }else{
      return false ;
    }
  }
}
