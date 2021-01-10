import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:schoolapp/components/game/game_card.dart';
import 'package:schoolapp/components/game/game_trianing_resume.dart';
import 'package:schoolapp/components/game_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/change_password.dart';
import 'components/game/game_test_knowledge.dart';
import 'components/game/game_test_knowledge_resume.dart';
import 'components/game/game_training.dart';
import 'components/home.dart';
import 'components/lists.dart';
import 'components/register.dart';
import 'components/settings.dart';
import 'components/login.dart';

List<GameCard> emptyList = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var email = prefs.getString("email");
  runApp(MaterialApp(
    theme: ThemeData(
      //Pur avoir une couleur uniforme dans les appbar
      primaryColor: Colors.cyan,
    ),
      home: (email == null ? Login() : Home()),
      routes: {
        //'/': (context) => Loading(),
        '/login': (context) => Login(),
        '/register': (context) => Register(),
        '/home': (context) => Home(),
        '/lists': (context) => Lists(),
        '/settings': (context) => Settings(),
        '/password' : (context) => Password(),
        '/gamescreen' : (context) => GameScreen('0', emptyList),
        '/gametraining' : (context) => GameTraining('0'),
        '/gametrainingres' : (context) => GameTrainingResume(),
        '/gametestknowledge' : (context) => GameTestKnowledge('0', '0'),
        '/gametestknowledgegres' : (context) => GameTestKnowledgeResume(),
      }
  ));
}

