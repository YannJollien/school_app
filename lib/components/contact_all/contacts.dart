import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:schoolapp/services/contactService.dart';
import '../contact_details/contactDetails.dart';
import '../home_drawer.dart';

class Contacts extends StatefulWidget {
  @override
  ContactsState createState() {
    return ContactsState();
  }
}

/// CLASS TO DISPLAY ALL THE CONTACT OF THE APPLICATION
class ContactsState extends State<Contacts> {
  //Connection with firestore
  ContactService _contactService = ContactService();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  //Page title
  Widget _appBarTitle =
      new Text('All contacts', style: TextStyle(color: Colors.black, fontSize: 22));

  //Search bar management
  bool searchActive = false;
  String search = "";
  FocusNode focusNodeSearchBar = FocusNode();

  //Image management
  Reference ref;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: _appBarTitle,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: IconTheme(
              data: Theme.of(context).iconTheme,
              child: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    searchActive = !searchActive;
                    if (searchActive) {
                      this._appBarTitle = new TextField(
                        focusNode: focusNodeSearchBar,
                        onChanged: (text) {
                          setState(() {
                            search = text;
                          });
                        },
                        decoration: new InputDecoration(
                            border: InputBorder.none,
                            hintStyle: Theme.of(context).textTheme.headline1,
                            hintText: 'Search...'),
                      );
                    } else {
                      search = "";
                      this._appBarTitle = new Text('All contacts', style: Theme.of(context).textTheme.headline1);
                    }
                  });
                  focusNodeSearchBar.requestFocus();
                },
              ),
            ),
          ),
        ],
      ),
      drawer: HomeDrawer(),
      //Build list of contact
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
                      String unionFirstLastName = doc.data()['firstname'].toString().toLowerCase() + " " + doc.data()['lastname'].toString().toLowerCase() ;
                      String unionLastFirstName = doc.data()['lastname'].toString().toLowerCase() + " " + doc.data()['firstname'].toString().toLowerCase() ;
                      return (unionLastFirstName.contains(search.toLowerCase()) || unionFirstLastName.contains(search.toLowerCase()))
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
                                      content: RichText(
                                        text: new TextSpan(
                                          style: new TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.black,
                                          ),
                                          children: <TextSpan>[
                                            new TextSpan(text: "Are you sure you want to delete '" +
                                                doc.data()['firstname'] +
                                                " " +
                                                doc.data()['lastname'] + "'"),
                                            new TextSpan(text: ' definitively ?', style: new TextStyle(fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
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
                                              _contactService
                                                  .deleteContact(doc);
                                              deleteImage(
                                                  firebaseAuth
                                                      .currentUser.email,
                                                  doc.id);
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

  //Card builder
  Card buildItem(DocumentSnapshot contactDoc) {
    DocumentSnapshot emptyDocumentSnapshot ;
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ContactDetails(emptyDocumentSnapshot, contactDoc)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                        contactDoc.data()['image']
                    ),
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
  Future deleteImage(String email, String docId) async {
    ref = FirebaseStorage.instance.ref().child("contacts/$email/$docId");
    ref.delete();
  }

  //Alert dialog on delete
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
      content: RichText(
        text: new TextSpan(
          // Note: Styles for TextSpans must be explicitly defined.
          // Child text spans will inherit styles from parent
          style: new TextStyle(
            fontSize: 16.0,
            color: Colors.black,
          ),
          children: <TextSpan>[
            new TextSpan(text: "Are you sure you want to delete '" +
                contactDoc.data()['firstname'] +
                " " +
                contactDoc.data()['lastname'] + "'"),
            new TextSpan(text: ' definitively ?', style: new TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
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
}
