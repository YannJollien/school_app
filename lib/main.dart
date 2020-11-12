import 'package:flutter/material.dart';
import 'components/home.dart';
import 'components/lists.dart';

void main() => runApp(MaterialApp(
  //Defines which page will start first
  initialRoute: '/home',
  routes: {
    //'/': (context) => Loading(),
    '/home': (context) => Home(),
    '/list': (context) => Lists()
    //'/location': (context) => ChoseLocation()
  },
));


