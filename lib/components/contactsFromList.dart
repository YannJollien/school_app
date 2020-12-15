import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schoolapp/components/contactDetails.dart';
import 'package:schoolapp/components/game_main.dart';
import 'package:schoolapp/components/lists.dart';
import 'package:schoolapp/services/contactService.dart';
import 'package:schoolapp/services/listService.dart';

import 'contactNew.dart';

class ContactList extends StatefulWidget {
  DocumentSnapshot listDoc;

  ContactList(DocumentSnapshot doc) {
    this.listDoc = doc;
  }

  @override
  State<StatefulWidget> createState() => new ContactListState(listDoc);
}

class ContactListState extends State<ContactList> {
  String id;
  ContactService _contactService = ContactService();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  ContactListState(data);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listDoc.data()["listName"] + " list"),
        leading: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Lists()),
            );
          },
          child: Icon(
            Icons.arrow_back, // add custom icons also
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.sports_esports),
            color: Colors.white,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GameScreen()),
              );
            },
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: IconButton(
              icon: Icon(Icons.search),
              color: Colors.white,
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
            stream: _contactService.getContactsFromList(widget.listDoc),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children:
                      snapshot.data.docs.map((doc) => buildItem(doc)).toList(),
                );
              } else {
                return SizedBox();
              }
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ContactNew(widget.listDoc)),
          );
        },
      ),
    );
  }

  showAlertDialog(BuildContext context, DocumentSnapshot contactDoc) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      color: Colors.blue,
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Delete"),
      color: Colors.red,
      onPressed: () {
        _contactService.deleteContact(widget.listDoc, contactDoc);
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
//      title: Text(),
      content: Text("Are you sure you want to delete " +
          contactDoc.data()['firstname'] +
          " " +
          contactDoc.data()['lastname'] +
          " from the " +
          widget.listDoc.data()['listName'] +
          " list ?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Card buildItem(DocumentSnapshot contactDoc) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ContactDetails(widget.listDoc, contactDoc)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  FutureBuilder(
                    future: getImage(context, firebaseAuth.currentUser.email,
                        contactDoc.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Container(
                          width: MediaQuery.of(context).size.width / 8,
                          height: MediaQuery.of(context).size.width / 8,
                          child: snapshot.data,
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          width: MediaQuery.of(context).size.width / 8,
                          height: MediaQuery.of(context).size.width / 8,
                          child: CircularProgressIndicator(),
                        );
                      }
                      return Container();
                    },
                  ),
                  SizedBox(width: 10),
                  Text(
                    '${contactDoc.data()['firstname']}' +
                        ' ' +
                        '${contactDoc.data()['lastname']}',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(width: 8),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.blue,
                    onPressed: () {
                      showAlertDialog(context, contactDoc);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Get the image from storage
  Future<Widget> getImage(
      BuildContext context, String imageName, String docId) async {
    Image image;
    await FireStorageService.loadImage(context, imageName, docId).then((value) {
      image = Image.network(value.toString(), fit: BoxFit.scaleDown);
    });
    return image;
  }
}

//Helper class to get the image
class FireStorageService extends ChangeNotifier {
  FireStorageService();

  static Future<dynamic> loadImage(
      BuildContext context, String email, String docId) async {
    return await FirebaseStorage.instance
        .ref("contacts/$email/$docId")
        .getDownloadURL();
  }
}
