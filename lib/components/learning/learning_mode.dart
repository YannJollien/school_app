import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schoolapp/components/contact_list/contactsFromList.dart';
import 'package:schoolapp/components/game/game_card.dart';
import 'package:schoolapp/components/game_main.dart';

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

class LearningModeState extends State<LearningMode> {
  LearningModeState(data);

  List<Widget> cardList = new List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cardList = _generateCards();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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

  List<Widget> _generateCards() {
    List<Widget> cardList = new List();

    int loopIteration = int.parse(LearningMode.numberChoose);
    if (int.parse(LearningMode.numberChoose) > GameScreen.gameCard.length) {
      loopIteration = GameScreen.gameCard.length;
    }

    //Make learning random
    LearningMode.gameCard.shuffle();

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
                          LearningMode.gameCard[x].image,
                          width: 320.0,
                          height: 440.0,
                          fit: BoxFit.fill,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: Text(
                          LearningMode.gameCard[x].firstname + " " + LearningMode.gameCard[x].lastname,
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
                          height: 480.0,
                          width: 320.0,
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: Text(
                            LearningMode.gameCard[x].firstname + " " + LearningMode.gameCard[x].lastname,
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

  void removeCards(index) {
    setState(() {
      cardList.removeAt(index);
    });
  }
}
