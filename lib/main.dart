import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/home.dart';
import 'components/lists.dart';
import 'components/opening.dart';
import 'components/register.dart';
import 'components/settings.dart';
import 'components/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //SharedPreferences prefs = await SharedPreferences.getInstance();
  //var email = prefs.getString("email");
  //print("Email"+email);
  runApp(MaterialApp(
      home:Opening(),
      routes: {
        //'/': (context) => Loading(),
        '/opening': (context) => Opening(),
        '/login': (context) => Login(),
        '/register': (context) => Register(),
        '/home': (context) => Home(),
        '/list': (context) => Lists(),
        '/settings': (context) => Settings()
      }
  ));
}

