import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/lists.dart';
import 'components/register.dart';
import 'components/settings.dart';
import 'components/login.dart';

/// MAIN CLASS
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var email = prefs.getString("email");
  runApp(MaterialApp(
      themeMode: ThemeMode.light,
      theme: ThemeData(
        //Pur avoir une couleur uniforme dans les appbar
        primaryColor: Colors.cyan,
        textTheme: TextTheme(
          headline1: TextStyle(fontFamily: 'Hind',
              fontSize: 22,
              color: Colors.black,
              fontWeight: FontWeight.w500),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.black,
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      darkTheme: ThemeData(
        //Pur avoir une couleur uniforme dans les appbar
        primaryColor: Colors.blueGrey,
        textTheme: TextTheme(
          headline1: TextStyle(fontFamily: 'Hind',
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.w500),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.white,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      home: (email == null ? Login() : Lists()),
      routes: {
        '/login': (context) => Login(),
        '/register': (context) => Register(),
        '/lists': (context) => Lists(),
        '/settings': (context) => Settings(),
      }
  ));
}

