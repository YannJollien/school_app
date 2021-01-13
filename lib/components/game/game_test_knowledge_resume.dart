import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schoolapp/components/game/game_card.dart';
import 'package:schoolapp/components/game_main.dart';
import 'package:schoolapp/services/listService.dart';
import '../lists.dart';
import 'game_test_knowledge.dart';

class GameTestKnowledgeResume extends StatefulWidget {
  static List<GameCard> gameCard;

  GameTestKnowledgeResume(List<GameCard> gc) {
    gameCard = gc;
  }

  @override
  _GameTestKnowledgeResumeState createState() =>
      _GameTestKnowledgeResumeState();
}

class _GameTestKnowledgeResumeState extends State<GameTestKnowledgeResume> {
  ListService _listService = ListService();

  List<GameCard> emptyList = new List<GameCard>();
  List<GameCard> wrongContactCard = new List<GameCard>();
  GameTestKnowledge gameTestKnowledge =
  new GameTestKnowledge(GameTestKnowledgeResume.gameCard, '0', '0');

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
      backgroundColor: Colors.grey[300],
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
          _buildWrongContactList(),
          ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: wrongContactCard.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    //Possibilité de cliquer sur le faux pour direct avoir des infos / écrire une note
                    onTap: () {},
                    title: Text(wrongContactCard[index].firstname,
                    ),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        wrongContactCard[index].image,
                      ),
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }

  Widget _buildWrongContactList() {
    return FutureBuilder(
        future: _listService.getContactIdWrongOfTheList(
            GameScreen.listDoc),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot> snapshot1) {
          List<dynamic> contactsId;
          if (snapshot1.connectionState == ConnectionState.done) {
            contactsId = snapshot1.data['wrongAnswers'];
            return FutureBuilder(
                future: _listService
                    .getWrongContactFromTheList(contactsId),
                builder: (BuildContext context,
                    AsyncSnapshot<List<GameCard>> snapshot2) {
                  // print("instance ? " + snapshot2.data.toString());
                  wrongContactCard = snapshot2.data;
                  return(snapshot2.connectionState == ConnectionState.done)
                    ? Text(snapshot2.data.length.toString() + " Wrong answers")
                      : Text('Loading...');
                });
          }
          return Text('Loadinasdfasdfg...');
        });
  }
}
