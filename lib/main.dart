import 'package:flutter/material.dart';
import 'components/home.dart';
import 'components/lists.dart';
import 'components/settings.dart';

void main() => runApp(MaterialApp(
  //Defines which page will start first
  initialRoute: '/home',
  routes: {
    //'/': (context) => Loading(),
    '/home': (context) => Home(),
    '/list': (context) => Lists(),
    '/settings': (context) => Settings()
    //'/location': (context) => ChoseLocation()
  },
));


