import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:schoolapp/components/game/game_card.dart';
import 'package:schoolapp/services/listService.dart';
import 'package:tcard/tcard.dart';
import '../game_main.dart';
import 'game_test_knowledge_resume.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final User user = auth.currentUser;
ListService _listService = ListService();

List<Widget> cardList = new List();

List<GameCard> wrongAnswers = new List<GameCard>();



//Test if the name that was entered by the user is correct
bool test(String inputName, String toTest){
  if(inputName == toTest){
    return true;
  } else {
    return false;
  }
}






class GameTestKnowledge extends StatefulWidget {
  static String numberChoose;
  static List<GameCard> gameCard;

  GameTestKnowledge(List<GameCard> gc, String nb) {
    gameCard = gc;
    numberChoose = nb;
  }


  @override
  _GameTestKnowledge createState() => _GameTestKnowledge();

  List<GameCard> getList(){
    return wrongAnswers;
  }
}

class _GameTestKnowledge  extends State<GameTestKnowledge> {
  TCardController _controller = TCardController();

  TextEditingController answerController = new TextEditingController();

  int _index = 0;

  String answer = " ";

  int progress = 0;
  double percent = 0;

  String progressText= "0%";


  void removeCards(index) {
    setState(() {
      cardList.removeAt(index);
    });
  }

  //Generate the cards
  List<Widget> _generateCards() {
    //List<Widget> cardList = new List();

    int loopIteration = int.parse(GameTestKnowledge.numberChoose);
    if (int.parse(GameTestKnowledge.numberChoose) > GameScreen.gameCard.length) {
      loopIteration = GameScreen.gameCard.length;
    }

    //Make learning random
    GameTestKnowledge.gameCard.shuffle();

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
                          width: 320.0,
                          height: 440.0,
                          fit: BoxFit.fill,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: Text(
                          GameTestKnowledge.gameCard[x].firstname,
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
                                    GameTestKnowledge.gameCard[x].image),
                                fit: BoxFit.cover),
                          ),
                          height: 350.0,
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Test my knowledge mode"),
        ),
        backgroundColor: Colors.grey[300],
        body:
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AbsorbPointer(
                absorbing: true,
                child: TCard(
                  cards: _generateCards(),
                  size: Size(350, 450),
                  controller: _controller,
                  onEnd: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GameTestKnowledgeResume(wrongAnswers)),
                      );

                    setState(() {
                      int.parse(GameTestKnowledge.numberChoose);
                    });
                  },
                  onForward: (index, info) {
                    _index = index;
                    print( "INFOR DIRECTION : " + info.direction.toString());
                    setState(() {

                    });
                  },
                ),
              ),
              SizedBox(height: 20.0),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 0, left: 30),
                      child: TextFormField(
                        controller: answerController,
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
                    child: IconButton(
                        icon: Icon(Icons.done, size: 40.0, color: Colors.green),
                        onPressed: () {
                          setState(() {

                            answer = answerController.text;
                            progress = progress + 1;
                            percent = (100 / int.parse(GameTestKnowledge.numberChoose) * progress).toDouble() / 100;


                            print("percent: " + percent.toString());
                            print("progress : " + progress.toString());
                            print("nombre de contacts utilisés : " + int.parse(GameTestKnowledge.numberChoose).toString());
                            print("my answer: " + answer +  " :  the correct answer :" + GameTestKnowledge.gameCard[_index].firstname);

                            progressText = (100 / int.parse(GameTestKnowledge.numberChoose) * progress).toString();


                          });


                          //Test if the answer is correct
                          test(answer, GameTestKnowledge.gameCard[_index].firstname);




                          //Add every wrong answer to the list of the wrong answers
                          if (test(answer, GameTestKnowledge.gameCard[_index].firstname) == false) {
                            wrongAnswers.add(GameCard(
                                GameTestKnowledge.gameCard[_index].image, GameTestKnowledge.gameCard[_index].firstname, " "
                            ));
                          }

                          //
                          if(progress == int.parse(GameTestKnowledge.numberChoose)){

                            //Refresh variables
                            percent = 0.0;
                            progress = 0;

                            //Prepare the score
                            int nbChosen = (int.parse(GameTestKnowledge.numberChoose));
                            int listLenght = wrongAnswers.length;
                            int total = (nbChosen - listLenght) * 100;
                            int pourcant = total;
                            int score = pourcant ~/ 10;


                            //Update the score
                            _listService.updateScore(GameTestKnowledge.numberChoose, score.toString());


                            //At the end of the game update the wrong answer in the database
                            for(int i=0; i<wrongAnswers.length; i++){
                              _listService.updateWrongAnswer('R8F7UN2tYTp1BicHrMn1');
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GameTestKnowledgeResume(wrongAnswers)),
                            );
                          }

                          answerController.text = "";
                          _controller.forward();



                        }
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Padding(
                padding: EdgeInsets.only(left: 20.0, right: 10.0),
                child: LinearPercentIndicator(
                  width: 360.0,
                  lineHeight: 20.0,
                  percent: percent,
                  center: Text(
                      progressText
                  ),
                  linearStrokeCap: LinearStrokeCap.butt,
                  backgroundColor: Colors.grey,
                  progressColor: Colors.cyan,
                ),
              ),
            ],
          ),
        )
    );
  }
}