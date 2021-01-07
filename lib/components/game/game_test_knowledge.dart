import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:schoolapp/components/game/game_card.dart';
import 'package:schoolapp/services/listService.dart';
import 'package:tcard/tcard.dart';
import 'game_test_knowledge_resume.dart';

List<GameCard> cards = new List();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final User user = auth.currentUser;
  ListService _listService = ListService();

  String downloadUrl;
  Reference ref;

//Get image Url
Future <String> downloadImage (String email, String docId) async{
  ref = FirebaseStorage.instance.ref().child("contacts/$email/$docId");
  return await ref.getDownloadURL();
}

List<GameCard> wrongAnswers = new List<GameCard>();

//Get all the contact from a list and put them into a list
List <Widget> _getGameCard(int numberOfContacts){

  final contactsRef = FirebaseFirestore.instance.collection('users').doc(user.uid).collection("contacts");
  List<Widget> cardList = new List();

  //Fetch name of contacts
  contactsRef
      .get()
      .then((snapshot) {
        snapshot.docs.forEach((doc) {
        cards.add(GameCard(doc.id, doc.data()['firstname']));
    });
  });


  //Fetch images of contacts
  for(int i = 0 ; i < numberOfContacts; i++ ){
    downloadImage(user.email, cards[i].imageNew).then((value) => {
      downloadUrl = value
    });

    cardList.add(
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  downloadUrl
              ),
              fit: BoxFit.fitWidth,
            ),
            shape: BoxShape.rectangle,
          ),
        )
    );

    //Put all the cards in a list
    /*
    cardList.add(
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  downloadUrl
              ),
              fit: BoxFit.fitWidth,
            ),
            shape: BoxShape.rectangle,
          ),
        )
    );
     */
  }
  return cardList;
}





//Test if the name that was entered by the user is correct
bool test(String inputName, String toTest){
  if(inputName == toTest){
    return true;
  } else {
    return false;
  }
}


class GameTestKnowledge extends StatefulWidget {
  final String numberChose;
  GameTestKnowledge(this.numberChose, {Key key}) : super(key: key);

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

  double _score = 0;


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
                  cards: _getGameCard(int.parse(widget.numberChose)),
                  size: Size(350, 450),
                  controller: _controller,
                  onEnd: () {
                    print("End! at $_index");
                    for (int i = 0; i < wrongAnswers.length; i++) {
                      print("MY WRONG ANSWERS!!! : " + wrongAnswers[i].nameNew);
                    }
                    //Update the score according to the wrong answers
                    _score = ((int.parse(widget.numberChose) - wrongAnswers.length) / 100) ;
                    _listService.updateScore("8OezymiqI4nuZbmuhiMX", _score.toString() + "%");
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GameTestKnowledgeResume()),
                    );
                    setState(() {
                      int.parse(widget.numberChose);
                    });
                  },
                  onForward: (index, info) {
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
                            progress = progress + 1;
                            percent = (100 / int.parse(widget.numberChose) * progress).toDouble() / 100;


                            print("percent: " + percent.toString());
                            print("progress : " + progress.toString());

                            progressText = (100 / int.parse(widget.numberChose) * progress)
                                .toString();
                          });
                          test(answer, cards[_index].nameNew);
                          //Ajouter dans la liste des "faux"
                          if (test(answer, cards[_index].nameNew) == false) {
                            wrongAnswers.add(GameCard(
                                cards[_index].imageNew, cards[_index].nameNew));
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