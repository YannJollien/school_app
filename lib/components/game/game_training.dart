import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:schoolapp/components/game/game_card.dart';
import 'package:tcard/tcard.dart';

List<GameCard> cards = new List();
int _indexList;

List <Widget> _getGameCard(){
  cards.add(GameCard('assets/boy1.jpg', "Jean"));
  cards.add(GameCard('assets/boy2.jpg', "Johan"));
  cards.add(GameCard('assets/girl1.jpg', "Tania"));
  cards.add(GameCard('assets/girl2.jpg', "Johanna"));

  _indexList = cards.length;

  List<Widget> cardList = new List();
  for(int i = 0 ; i < _indexList ; i++ ){
    cardList.add(
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  cards[i].imageNew),
              fit: BoxFit.fitWidth,
            ),
            shape: BoxShape.rectangle,
          ),
        )
    );
  }
  return cardList;
}

bool test(String inputName, String toTest){
  if(inputName == toTest){
   return true;
  } else {
    return false;
  }
}

class GameTraining extends StatefulWidget {
  @override
  _GameTrainingState createState() => _GameTrainingState();
}

class _GameTrainingState extends State<GameTraining> {

  TCardController _controller = TCardController();
  TextEditingController answerController = new TextEditingController();
  int _index = 0;
  String answer = " ";

  int progress = 0;
  double percent = 0;

  String progressText= "0%";

  //Liste pour les fausses réponses
  List<GameCard> wrongAnswers = new List<GameCard>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Training mode"),
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
                    cards: _getGameCard(),
                  size: Size(350, 450),
                  controller: _controller,
                  onEnd: () {
                      print("End! at $_index");
                      for(int i = 0 ; i < wrongAnswers.length ; i++){
                        print(wrongAnswers[i].nameNew);
                      }
                      setState(() {
                        _indexList = cards.length;
                      });
                  },
                  onForward: (index, info){
                    _index = index;
                    print(info.direction);
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
                              progress = progress+1;
                              //Codé en dur !!! Il faut remplacer le 4 par la taille de la liste
                              _indexList = 4;
                              percent = (100/_indexList*progress).toDouble()/100;
                              progressText = (100/_indexList*progress).toString();
                            });
                            print("From field" + answerController.text);
                            print("from cards" +cards[_index].nameNew);
                            test(answer, cards[_index].nameNew);
                            //Ajouter dans la liste des "faux"
                            if(test(answer, cards[_index].nameNew)==false){
                              wrongAnswers.add(GameCard(cards[_index].imageNew, cards[_index].nameNew));
                            }
                            _controller.forward();
                            answerController.text = "";
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
