import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:schoolapp/components/login.dart';
import 'package:schoolapp/services/auth.dart';
import 'package:schoolapp/services/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:schoolapp/services/fireStorageService.dart';
import 'contact_all/contacts.dart';



class HomeDrawer extends StatefulWidget {

  //To log out
  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {

  final AuthService _auth = AuthService();

  final DatabaseService service = DatabaseService();

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  //Get the image from storage
  Future<Widget> getImage(BuildContext context, String imageName) async {
    Image image;
    await FireStorageService.loadConnectedUserImage(context, imageName).then((value) {
      image = Image.network(
        value.toString(),
        fit: BoxFit.scaleDown
      );
    });
    return image;
  }

  //Remove login from shared prefs
  Future removePref() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove("email");
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.only(
                        top: 30.0
                      ),
                      child: FutureBuilder(
                        future: getImage(context, firebaseAuth.currentUser.email),
                        builder: (context, snapshot){
                          if(snapshot.connectionState == ConnectionState.done){
                            return Container(
                              width: MediaQuery.of(context).size.width / 1.2,
                              height: MediaQuery.of(context).size.width / 1.2,
                              child: snapshot.data,
                            );
                          }
                          if(snapshot.connectionState == ConnectionState.waiting){
                            return Container(
                              width: MediaQuery.of(context).size.width / 1.2,
                              height: MediaQuery.of(context).size.width / 1.2,
                              child: CircularProgressIndicator(),
                            );
                          }
                          return Container();
                        },
                      )
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
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.0),
              color: Theme.of(context).primaryColor,
              child:
                Column(
                  children: [
                    ListTile(
                      leading: IconTheme(data: Theme.of(context).iconTheme,child: Icon(Icons.list)),
                      title: Text(
                          "List",
                          style: Theme.of(context).textTheme.headline1
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed("/lists");
                      },
                    ),
                    ListTile(
                      leading: IconTheme(data: Theme.of(context).iconTheme,child: Icon(Icons.assignment_ind)),
                      title: Text(
                        "Contact",
                          style: Theme.of(context).textTheme.headline1
                      ),
                      onTap: () {
//                Navigator.of(context).pushNamed("/contacts");
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Contacts()),
                        );
                      },
                    ),
                    ListTile(
                      leading: IconTheme(data: Theme.of(context).iconTheme,child: Icon(Icons.settings)),
                      title: Text(
                        "Settings",
                          style: Theme.of(context).textTheme.headline1
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed("/settings");
                      },
                    ),
                    ListTile(
                      leading: IconTheme(data: Theme.of(context).iconTheme,child: Icon(Icons.logout)),
                      title: Text(
                        "Log out",
                          style: Theme.of(context).textTheme.headline1
                      ),
                      onTap: () async{
                        //Log out
                        removePref();
                        _auth.signOut();
                        //Go to opening page when logged out
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      },
                    ),
                    // SizedBox(
                    //   height: 200,
                    // )
                  ],
                ),
            ),
          ],
        )
    );
  }
}