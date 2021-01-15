import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:schoolapp/components/contact_list/contactsFromList.dart';
import 'package:schoolapp/components/game/game_card.dart';
import 'package:schoolapp/services/listService.dart';
import 'package:pie_chart/pie_chart.dart';
import '../game_main.dart';
import 'lastGameWrongAnswers.dart';

class GameTestKnowledgeResume extends StatefulWidget {
  GameTestKnowledgeResume();

  @override
  _GameTestKnowledgeResumeState createState() =>
      _GameTestKnowledgeResumeState();
}

/// CLASS TO DISPLAY LAST GAME RESUME (SCORE + PIECHART)
class _GameTestKnowledgeResumeState extends State<GameTestKnowledgeResume> {

  //Database management
  ListService _listService = ListService();

  //Card of wrong contact
  List<GameCard> wrongContactCard = new List<GameCard>();

  //Number choose to play
  double numberChooseLastGame;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Game with " +
            ContactFromList.listDoc.data()['listName'] +
            " list"),
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ContactFromList(ContactFromList.listDoc)),
            );
          },
          child: Icon(
            Icons.arrow_back, // add custom icons also
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _getWrongAnswers(),
          ],
        ),
      ),
    );
  }

  //Get all wrong answers
  Widget _getWrongAnswers() {
    return StreamBuilder(
      stream: _listService.getContactIdWrongOfTheListStream(GameScreen.listDoc),
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot> streamBuilderSnapshot) {
        numberChooseLastGame =
            double.parse(streamBuilderSnapshot.data['numberChoose']);
        return FutureBuilder(
            future: _listService.getContactIdWrongOfTheList(GameScreen.listDoc),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> wrongContactIds) {
              List<dynamic> contactsId;
              if (wrongContactIds.connectionState == ConnectionState.done) {
                contactsId = wrongContactIds.data['wrongAnswers'];
                return FutureBuilder(
                    future: _listService.getWrongContactFromTheList(contactsId),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<GameCard>> wrongContactCards) {
                      wrongContactCard = wrongContactCards.data;
                      return (wrongContactCards.connectionState ==
                              ConnectionState.done)
                          ? Column(
                              children: [
                                SizedBox(height: 10),
                                _getTheScoreGame(
                                    wrongContactCard.length.toDouble()),
                                SizedBox(height: 10),
                                _pieChart(wrongContactCard.length.toDouble()),
                                SizedBox(height: 20),
                                (numberChooseLastGame == 0)
                                    ? Container()
                                    : FlatButton(
                                        color: Colors.redAccent,
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LastGameWrongAnswers(
                                                        wrongContactCard)),
                                          );
                                        },
                                        child: Text("Show all wrong"),
                                      ),
                              ],
                            )
                          : Container();
                    });
              }
              return Container();
            });
      },
    );
  }

  //Get score game
  Widget _getTheScoreGame(double wrongContactLength) {
    double rightAnswers;
    int percentageRight;

    if (numberChooseLastGame != 0) {
      rightAnswers = numberChooseLastGame - wrongContactLength;
      percentageRight = rightAnswers * 100 ~/ numberChooseLastGame;
    } else {
      rightAnswers = 0;
      percentageRight = 0;
    }

    //Linear progressor for the score
    Padding linearPercentIndicator = new Padding(
      padding: EdgeInsets.all(20.0),
      child: new LinearPercentIndicator(
        width: MediaQuery.of(context).size.width - 50,
        animation: true,
        lineHeight: 20.0,
        animationDuration: 1000,
        percent: percentageRight / 100,
        center: Text(percentageRight.toString() + "%"),
        linearStrokeCap: LinearStrokeCap.roundAll,
        progressColor: Colors.greenAccent,
      ),
    );

    //If list was never played
    if (numberChooseLastGame == 0) {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          "List never played",
          style: TextStyle(fontSize: 20),
        ),
        linearPercentIndicator,
      ]);
    } else {
      if (percentageRight == 100) {
        return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            "Well done ! ",
            style: TextStyle(fontSize: 20),
          ),
          linearPercentIndicator,
        ]);
      } else {
        return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            'Score game',
            style: TextStyle(fontSize: 20),
          ),
          linearPercentIndicator
        ]);
      }
    }
  }

  //Pie chart
  Widget _pieChart(double wrongContactLength) {
    Map<String, double> dataMap = {
      "Wrong": wrongContactLength,
      "Right": numberChooseLastGame - wrongContactLength,
    };
    return PieChart(dataMap: dataMap);
  }
}
