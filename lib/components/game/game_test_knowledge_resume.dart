import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schoolapp/components/game/game_training.dart';


class GameTestKnowledgeResume extends StatefulWidget {
  @override
  _GameTestKnowledgeResumeState createState() => _GameTestKnowledgeResumeState();
}

class _GameTestKnowledgeResumeState extends State<GameTestKnowledgeResume> {

  GameTraining gameTraining = new GameTraining();


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
              itemCount: gameTraining.getList().length,
              itemBuilder: (context, index){
                return Card(
                  child: ListTile(
                    //Possibilité de cliquer sur le faux pour direct avoir des infos / écrire une note
                    onTap: () {},
                    title: Text(
                      gameTraining.getList()[index].nameNew,
                    ),
                    leading: CircleAvatar(
                      backgroundImage: AssetImage( gameTraining.getList()[index].imageNew),
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
