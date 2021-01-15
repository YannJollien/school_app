import 'package:flutter/material.dart';
import 'package:schoolapp/components/home_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String email = "";

  Future getEmail() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      email = preferences.getString("email");
    });
  }

  @override
  void initState() {
    super.initState();
    getEmail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome', style: Theme.of(context).textTheme.headline1),
      ),
      drawer: HomeDrawer(),
      body: Container(
        color: Colors.grey[300],
      ),
    );
  }
}
