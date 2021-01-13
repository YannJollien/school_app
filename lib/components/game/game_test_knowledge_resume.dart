import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schoolapp/components/contact_list/contactsFromList.dart';
import 'package:schoolapp/components/game/game_card.dart';
import 'package:schoolapp/components/game_main.dart';
import 'package:schoolapp/services/listService.dart';
import '../lists.dart';
import 'package:pie_chart/pie_chart.dart';

class GameTestKnowledgeResume extends StatefulWidget {

  GameTestKnowledgeResume();

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
        title: Text(ContactFromList.listDoc.data()['listName'] + " list review"),
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
                              child: Column(
                                children: [
                                  // Text(wrongContactCard.length.toString() +
                                  //     "/" +
                                  //     GameScreen.gameCard.length.toString()
                                  //         .toString()),
                                  _pieChart(wrongContactCard.length.toDouble()),
                                  ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: wrongContactCard.length,
                                      itemBuilder: (context, index) {
                                        return Card(
                                          child: ListTile(
                                            //Possibilité de cliquer sur le faux pour direct avoir des infos / écrire une note
                                            onTap: () {},
                                            title: Text(
                                              wrongContactCard[index]
                                                      .firstname +
                                                  " " +
                                                  wrongContactCard[index]
                                                      .lastname,
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
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.8,
                                  height:
                                      MediaQuery.of(context).size.width / 1.8,
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

  Widget _pieChart(double wrongContactLength){
    Map<String, double> dataMap = {
      "Wrong": wrongContactLength,
      "Right": GameScreen.gameCard.length.toDouble()-wrongContactLength,
    };
    return PieChart(dataMap: dataMap);
  }
}
