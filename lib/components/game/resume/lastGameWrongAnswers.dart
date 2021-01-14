import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schoolapp/components/game/game_card.dart';

class LastGameWrongAnswers extends StatefulWidget {
  static List<GameCard> wrongContactCard;

  LastGameWrongAnswers(List<GameCard> wcc) {
    wrongContactCard = wcc;
  }

  @override
  State<StatefulWidget> createState() =>
      new LastGameWrongAnswersState(wrongContactCard);
}

class LastGameWrongAnswersState extends State<LastGameWrongAnswers> {
  LastGameWrongAnswersState(data);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Your wrong answers',
            style: Theme.of(context).textTheme.headline1),
      ),
      body: ListView.builder(
          itemCount: LastGameWrongAnswers.wrongContactCard.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return Card(
              child: InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                                LastGameWrongAnswers.wrongContactCard[index].image),
                          ),
                          SizedBox(width: 10),
                          //TEST FOR THE NAME/SURNAME LENGTH
                          ({LastGameWrongAnswers.wrongContactCard[index].firstname}
                              .toString()
                              .length +
                              {
                                LastGameWrongAnswers
                                    .wrongContactCard[index].lastname
                              }.toString().length >
                              22)
                              ? Text(
                            '${LastGameWrongAnswers.wrongContactCard[index].firstname}' +
                                ' ' +
                                '${LastGameWrongAnswers.wrongContactCard[index].lastname.toString().substring(0, 17 - {
                                  LastGameWrongAnswers.wrongContactCard[index].firstname
                                }.toString().length + 1)}' +
                                '...',
                            style: TextStyle(fontSize: 24),
                          )
                              : Text(
                            '${LastGameWrongAnswers.wrongContactCard[index].firstname}' +
                                ' ' +
                                '${LastGameWrongAnswers.wrongContactCard[index].lastname}',
                            style: TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );

            return new Text(LastGameWrongAnswers.wrongContactCard[index].firstname);
          }),
    );
  }
}
