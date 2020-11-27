import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:schoolapp/components/opening.dart';
import 'package:schoolapp/services/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomeDrawer extends StatelessWidget {

  //To log out
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.0),
              color: Colors.lightBlue,
              child: Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.only(
                        top: 30.0
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(
                            ""
                          ),
                          fit: BoxFit.fill
                        ),
                      ),
                    ),
                    /*StreamBuilder(
                      stream: firestoreInstance.collection("users").where("id", isEqualTo: _auth.currentUser.uid).snapshots(),
                      builder: (context, snapshot) {
                        return (
                        Text(
                          snapshot.data.documents[0]["name"]
                        )
                        );
                      },
                    )*/
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text(
                  "List",
                  style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              onTap: () {
                //Navigator.pushNamed(context, '/list');
                Navigator.of(context).pushNamed("/list");
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text(
                "About us",
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              onTap: null,
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text(
                "Settings",
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              onTap: () {
                //Navigator.pushNamed(context, '/list');
                Navigator.of(context).pushNamed("/settings");
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text(
                "Log out",
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              onTap: () async{
                //Remove from fp to stop auto logged in
                //SharedPreferences prefs = await SharedPreferences.getInstance();
                //prefs.remove('email');
                //Log out
                _auth.signOut();
                //Go to opening page when logged out
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Opening()),
                );
              },
            ),
          ],
        )
    );
  }



}
