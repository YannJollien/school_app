import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schoolapp/components/game/game_card.dart';
import 'package:schoolapp/services/listService.dart';
import '../lists.dart';
import 'game_test_knowledge.dart';


class GameTestKnowledgeResume extends StatefulWidget {

  static List<GameCard> gameCard;
  static String listGame;


  GameTestKnowledgeResume(List<GameCard> gc) {
    gameCard = gc;
  }

  @override
  _GameTestKnowledgeResumeState createState() => _GameTestKnowledgeResumeState();
}

class _GameTestKnowledgeResumeState extends State<GameTestKnowledgeResume> {

  ListService _listService = ListService();



  List<GameCard> emptyList = new List<GameCard>();
  GameTestKnowledge gameTestKnowledge = new GameTestKnowledge(GameTestKnowledgeResume.gameCard, '0', '0');


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
            Icons.arrow_back,  // add custom icons also
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
          ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: gameTestKnowledge.getList().length,
              itemBuilder: (context, index){
                return Card(
                  child: ListTile(
                    //Possibilité de cliquer sur le faux pour direct avoir des infos / écrire une note
                    onTap: () {},
                    title: Text(
                      gameTestKnowledge.getList()[index].firstname,
                    ),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        gameTestKnowledge.getList()[index].image,
                      ),
                    ),
                  ),
                );
              }
          ),
        ],
      ),

    );
  }



}