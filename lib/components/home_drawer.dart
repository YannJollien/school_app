import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:schoolapp/components/opening.dart';
import 'package:schoolapp/services/auth.dart';
import 'package:schoolapp/services/database.dart';



class HomeDrawer extends StatefulWidget {

  //To log out
  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {

  final AuthService _auth = AuthService();

  final DatabaseService service = DatabaseService();

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  String imageUrl;
  String name;
  var refImage;

  @override
  void initState() {
    super.initState();
    //Get the profile image
    //refImage = FirebaseStorage.instance.ref().child("images/${firebaseAuth.currentUser.email}");
    //refImage.getDownloadURL().then((loc) => setState(() => imageUrl = loc));
  }

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
                      ),
                    SizedBox(height: 20.0),
                    StreamBuilder<DocumentSnapshot>(
                      stream: Firestore.instance.collection('users').doc(firebaseAuth.currentUser.uid).snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.hasError)
                          return new Text('Error: ${snapshot.error}');
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return new Center(
                              child: CircularProgressIndicator(),
                            );
                          default:
                            return Text(
                                snapshot.data.get("name").toString(),
                              style: TextStyle(
                                fontSize: 25.0
                              ),
                            );
                        }
                      },
                    )
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
                Navigator.of(context).pushNamed("/lists");
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
