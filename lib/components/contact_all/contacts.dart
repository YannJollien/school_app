import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:schoolapp/services/contactService.dart';

import '../contact_details/contactDetails.dart';
import '../contact_list/contactsFromList.dart';

class Contacts extends StatefulWidget {
  @override
  ContactsState createState() {
    return ContactsState();
  }
}

class ContactsState extends State<Contacts> {
  ContactService _contactService = ContactService();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Widget _appBarTitle = new Text('All contacts', style: TextStyle(color: Colors.white));
  bool searchActive = false;
  String search = "";
  FocusNode myFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: _appBarTitle,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: IconButton(
              icon: Icon(Icons.search),
              color: Colors.white,
              onPressed: () {
                setState(() {
                  searchActive = !searchActive;
                  if (searchActive) {
                    this._appBarTitle = new TextField(
                      focusNode: myFocusNode,
                      onChanged: (text) {
                        setState(() {
                          search = text;
                        });
                      },
                      decoration: new InputDecoration(
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.white),
                          // prefixIcon: new Icon(Icons.search, color: Colors.white,),
                          hintText: 'Search...'),
                    );
                  } else {
                    search = "";
                    this._appBarTitle = new Text('All contacts', style: TextStyle(color: Colors.white));
                  }
                });
                myFocusNode.requestFocus();
              },
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
            stream: _contactService.getAllContacts(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: snapshot.data.docs.map(
                        (doc) {
                      String unionLastFirstName = doc.data()['firstname'].toString().toLowerCase() + " " + doc.data()['lastname'].toString().toLowerCase() ;
                      return (unionLastFirstName.contains(search.toLowerCase()))
                          ? Dismissible(
                        key: Key(doc.id),
                        onDismissed: (direction) {},
                        confirmDismiss:
                            (DismissDirection direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirm"),
                                content: Text(
                                    "Are you sure you want to delete " +
                                        doc.data()['firstname'] +
                                        " " +
                                        doc.data()['lastname'] +
                                        " from the " +
                                        ContactFromList.listDoc
                                            .data()['listName'] +
                                        " list ?"),
                                actions: <Widget>[
                                  FlatButton(
                                    color: Colors.cyan,
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text("Cancel",
                                        style: TextStyle(
                                            color: Colors.white)),
                                  ),
                                  FlatButton(
                                      color: Colors.red,
                                      onPressed: () {
                                        _contactService.deleteContact(doc);
                                        deleteImage(firebaseAuth.currentUser.email, doc.id);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Delete",
                                          style: TextStyle(
                                              color: Colors.white))),
                                ],
                              );
                            },
                          );
                        },
                        // Show a red background as the item is swiped away.
                        background: Container(color: Colors.red),
                        child: buildItem(doc),
                      )
                          : Row();
                    },
                  ).toList(),
                );
              } else {
                return SizedBox();
              }
            },
          ),
        ],
      ),
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
                    ContactDetails(ContactFromList.listDoc, contactDoc)),
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
                    future: getImage(
                        context, firebaseAuth.currentUser.email, contactDoc.id),
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
                  ({contactDoc.data()['firstname']}.toString().length +
                              {contactDoc.data()['lastname']}
                                  .toString()
                                  .length >
                          22)
                      ? Text(
                          '${contactDoc.data()['firstname']}' +
                              ' ' +
                              '${contactDoc.data()['lastname'].toString().substring(0, 17 - {
                                    contactDoc.data()['firstname']
                                  }.toString().length + 1)}' +
                              '...',
                          style: TextStyle(fontSize: 24),
                        )
                      : Text(
                          '${contactDoc.data()['firstname']}' +
                              ' ' +
                              '${contactDoc.data()['lastname']}',
                          style: TextStyle(fontSize: 24),
                        ),
                  SizedBox(width: 8),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.cyan,
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

  //Delete image in storage
  Reference ref;

  Future deleteImage(String email, String docId) async {
    ref = FirebaseStorage.instance.ref().child("contacts/$email/$docId");
    ref.delete();
  }

  showAlertDialog(BuildContext context, DocumentSnapshot contactDoc) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel", style: TextStyle(color: Colors.white)),
      color: Colors.cyan,
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Delete"),
      color: Colors.red,
      onPressed: () {
        _contactService.deleteContact(contactDoc);
        deleteImage(firebaseAuth.currentUser.email, contactDoc.id);
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Confirm'),
      content: Text("Are you sure you want to delete " +
          contactDoc.data()['firstname'] +
          " " +
          contactDoc.data()['lastname'] +
          " definitively ?"),
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
