import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
          height: 120.0,
          width: 120.0,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  cards[i].imageNew),
              fit: BoxFit.fill,
            ),
            shape: BoxShape.circle,
          ),
        )
    );
  }
  return cardList;
}

void test(String inputName, String toTest){
  if(inputName == toTest){
    print("ok");
  } else {
    print("Not ok");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Training mode"),
      ),
      backgroundColor: Colors.grey[300],
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 10.0,),
              AbsorbPointer(
                absorbing: true,
                child: TCard(
                    cards: _getGameCard(),
                  size: Size(350, 450),
                  controller: _controller,
                  onEnd: () {
                      print("End! at $_index");
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
                mainAxisAlignment: MainAxisAlignment.center,
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
                          });
                          print("From field" + answerController.text);
                          print("from cards" +cards[_index].nameNew);
                          test(answer, cards[_index].nameNew);
                          _controller.forward();
                          answerController.text = "";
                        }
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      )
    );
  }



}
