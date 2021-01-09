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

final FirebaseAuth auth = FirebaseAuth.instance;
final User user = auth.currentUser;
ListService _listService = ListService();

List<GameCard> cards = new List();
List<String> names = List<String>();
List<String> imagesUrl = List<String>();
List<Widget> cardList = new List();



//Get image Url
Future <String> downloadImage (String email, String docId) async{
  Reference ref = FirebaseStorage.instance.ref().child("contacts/$email/$docId");
  return await ref.getDownloadURL();
}



List<GameCard> wrongAnswers = new List<GameCard>();

//Get all the contact from a list and put them into a list
List <Widget> _getGameCard(int numberOfContacts){

  final contactsRef = FirebaseFirestore.instance.collection('users').doc(user.uid).collection("contacts");

  //Fetch name of contacts
  contactsRef.get().then((snapshot) {
    snapshot.docs.forEach((doc) {
      names.add(doc.data()['firstname']);
      imagesUrl.add(doc.data()['image']);
//      downloadImage(user.email, doc.id).then((value) => {
//        imagesUrl.add(value)
//      });
    });
  });


  //Fetch images of contacts
  for(int i = 0 ; i < numberOfContacts ; i++ ){
    cardList.add(
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  imagesUrl[i]
              ),
              fit: BoxFit.fitWidth,
            ),
            shape: BoxShape.rectangle,
          ),
        )
    );

    //cards[i].nameNew = names[i];
    //cards[i].imageNew = imagesUrl[i];

    print("VALUE OF MY URL IMAGES !!!! : " + imagesUrl[i].toString());
    print("NAME OF THE CONTACT : " + names[i]);

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

//                            imagesUrl.remove(imagesUrl[progress]);
//                            names.remove(names[progress]);


                            answer = answerController.text;
                            progress = progress + 1;
                            percent = (100 / int.parse(widget.numberChose) * progress).toDouble() / 100;


                            print("percent: " + percent.toString());
                            print("progress : " + progress.toString());
                            print("nombre de contacts utilisés : " + int.parse(widget.numberChose).toString());
                            print("my answer: " + answer +  " :  the correct answer :" + names[_index]);



                            progressText = (100 / int.parse(widget.numberChose) * progress)
                                .toString();


                          });


                          //Test if the answer is correct
                          test(answer, names[_index]);




                          //Add every wrong answer to the list of the wrong answers
                          if (test(answer, names[_index]) == false) {
                            wrongAnswers.add(GameCard(
                                imagesUrl[_index], names[_index]
                            ));
                          }

                          //
                          if(progress == int.parse(widget.numberChose)){
                            percent = 0.0;
                            progress = 0;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GameTestKnowledgeResume()),
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