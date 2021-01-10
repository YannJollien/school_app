import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'game_test_knowledge.dart';


class GameTestKnowledgeResume extends StatefulWidget {

  @override
  _GameTestKnowledgeResumeState createState() => _GameTestKnowledgeResumeState();
}

class _GameTestKnowledgeResumeState extends State<GameTestKnowledgeResume> {


  GameTestKnowledge gameTestKnowledge = new GameTestKnowledge('0');


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test knowledge mode resume"),
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
                      backgroundImage: AssetImage(
                          gameTestKnowledge.getList()[index].image
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