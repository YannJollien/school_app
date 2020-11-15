import 'package:flutter/material.dart';
import 'package:schoolapp/components/home_drawer.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[600],
      ),
      drawer: HomeDrawer(),
      body: Container(
        color: Colors.grey[400],
      ),
    );
  }
}
