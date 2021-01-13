import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schoolapp/components/game/game_card.dart';
import 'package:schoolapp/components/game_main.dart';
import 'package:schoolapp/services/listService.dart';
import '../lists.dart';

class GameTestKnowledgeResume extends StatefulWidget {

  static String numberChoose ;

  GameTestKnowledgeResume(String nbChoose){
    numberChoose = nbChoose;
  }

  @override
  _GameTestKnowledgeResumeState createState() =>
      _GameTestKnowledgeResumeState();
}

class _GameTestKnowledgeResumeState extends State<GameTestKnowledgeResume> {
  ListService _listService = ListService();

  List<GameCard> wrongContactCard = new List<GameCard>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test knowledge mode resume"),
        leading: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Lists()),
            );
          },
          child: Icon(
            Icons.arrow_back, // add custom icons also
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "Your wrong answers",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _getWrongAnswers(),
        ],
      ),
    );
  }

  Widget _getWrongAnswers() {
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
                      wrongContactCard = snapshot2.data;
                      return (snapshot2.connectionState == ConnectionState.done)
                          ? Expanded(
                            // child: Column(
                            //   children: [
                            //     Text(wrongContactCard.length.toString() + "/" + GameTestKnowledgeResume.numberChoose.toString()),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: wrongContactCard.length,
                                    itemBuilder: (context, index) {
                                      return Card(
                                        child: ListTile(
                                          //Possibilité de cliquer sur le faux pour direct avoir des infos / écrire une note
                                          onTap: () {},
                                          title: Text(
                                            wrongContactCard[index].firstname +
                                                " " +
                                                wrongContactCard[index].lastname,
                                          ),
                                          leading: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              wrongContactCard[index].image,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              // ],
                            // ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                Container(
                                  width: MediaQuery.of(context).size.width / 1.8,
                                  height: MediaQuery.of(context).size.width / 1.8,
                                  child: CircularProgressIndicator(),
                                ),
                              ],
                          );
                      return (snapshot2.connectionState == ConnectionState.done)
                          ? Text(snapshot2.data.length.toString() +
                              " Wrong answers")
                          : Text('Loading...');
                    });
              }
              return Container();
            });
      },
    );
  }
}
