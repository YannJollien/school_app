import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schoolapp/components/contact_list/contactsFromList.dart';
import 'package:schoolapp/components/game/game_card.dart';

class LearningMode extends StatefulWidget {
  static String numberChoose;
  static List<GameCard> gameCard;

  LearningMode(List<GameCard> gc, String nb) {
    gameCard = gc;
    numberChoose = nb;
  }

  @override
  State<StatefulWidget> createState() => new LearningModeState(gameCard);
}

final FirebaseAuth auth = FirebaseAuth.instance;
final User user = auth.currentUser;

/// CLASS TO PLAY THE GAME IN LEARNING MODE
class LearningModeState extends State<LearningMode> {

  //Constructor
  LearningModeState(data);

  //Card management
  List<Widget> cardList = new List();

  @override
  void initState() {
    super.initState();
    cardList = _generateCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Learning mode"),
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
      body: Stack(alignment: Alignment.center, children: cardList),
    );
  }

  //Card generator
  List<Widget> _generateCards() {
    List<Widget> cardList = new List();

    if (LearningMode.gameCard.length == 0) {
      List<Container> c = new List<Container>();
      return c;
    }

    if (LearningMode.numberChoose == null) {
      LearningMode.numberChoose = LearningMode.gameCard.length.toString();
    }
    int loopIteration = int.parse(LearningMode.numberChoose);

    if (int.parse(LearningMode.numberChoose) > LearningMode.gameCard.length) {
      loopIteration = LearningMode.gameCard.length;
    }

    //Make learning random
    LearningMode.gameCard.shuffle();
    double top = 10.0;

    for (int x = 0; x < loopIteration; x++) {
      cardList.add(
        Positioned(
          top: top += 1.0,
          child: Draggable(
              onDragEnd: (drag) {
                removeCards(x);
              },
              childWhenDragging: Container(),
              //Swipe card
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
                          LearningMode.gameCard[x].image,
                          width: 320.0,
                          height: 440.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: Text(
                          LearningMode.gameCard[x].firstname +
                              " " +
                              LearningMode.gameCard[x].lastname,
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.cyan,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              //Displayed card
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
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0)),
                            image: DecorationImage(
                                image: NetworkImage(
                                    LearningMode.gameCard[x].image),
                                fit: BoxFit.cover),
                          ),
                          width: 320.0,
                          height: 440.0,
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: Text(
                            LearningMode.gameCard[x].firstname +
                                " " +
                                LearningMode.gameCard[x].lastname,
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.cyan,
                            ),
                          ),
                        )
                      ],
                    )),
              )),
        ),
      );
    }
    return cardList;
  }

  //On swipe remove card of the stack
  void removeCards(index) {
    setState(() {
      cardList.removeAt(index);
    });
  }
}
