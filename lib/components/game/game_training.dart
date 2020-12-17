import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:schoolapp/components/game/game_card.dart';
import 'package:tcard/tcard.dart';

import 'game_trianing_resume.dart';

List<GameCard> cards = new List();
int _indexList;
final FirebaseAuth auth = FirebaseAuth.instance;
final User user = auth.currentUser;

String downloadUrl;
Reference ref;

//Get image Url
Future <String> downloadImage (String email, String docId) async{
  ref = FirebaseStorage.instance.ref().child("contacts/$email/$docId");
  return await ref.getDownloadURL();
}

List <Widget> _getGameCard(){

  final contactsRef = Firestore.instance.collection('users').document(user.uid).collection("contacts");

  contactsRef.getDocuments().then((snapshot) {
    snapshot.documents.forEach((doc) {
      cards.add(GameCard(doc.documentID,doc.data()['firstname']));
    });
  });

  for(int i = 0 ; i < cards.length; i++){
    print("NAMES"+cards[i].nameNew);
  }

  _indexList = cards.length;

  List<Widget> cardList = new List();
  for(int i = 0 ; i < _indexList ; i++ ){
    downloadImage(user.email,cards[i].imageNew).then((value) => {
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




//Liste pour les fausses réponses
List<GameCard> wrongAnswers = new List<GameCard>();

class GameTraining extends StatefulWidget {
  final String numberChose;
  GameTraining(this.numberChose, {Key key}) : super(key: key);

  @override
  _GameTrainingState createState() => _GameTrainingState();

  List<GameCard> getList(){
    return wrongAnswers;
  }

}

class _GameTrainingState extends State<GameTraining> {

  TCardController _controller = TCardController();
  TextEditingController answerController = new TextEditingController();
  int _index = 0;
  String answer = " ";

  int progress = 0;
  double percent = 0;

  String progressText= "0%";


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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => GameTrainingResume()),
                    );
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
                            _indexList = int.parse(widget.numberChose)-1;
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