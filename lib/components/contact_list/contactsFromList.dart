import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:schoolapp/components/contact_add/contactListImportation.dart';
import 'package:schoolapp/components/contact_details/contactDetails.dart';
import 'package:schoolapp/components/game/game_card.dart';
import 'package:schoolapp/components/lists.dart';
import 'package:schoolapp/services/contactService.dart';
import '../contact_add/contactNew.dart';
import '../contact_add/addContactFromAll.dart';
import '../game/game_main.dart';
import 'package:schoolapp/services/fireStorageService.dart';

class ContactFromList extends StatefulWidget {
  static DocumentSnapshot listDoc;

  ContactFromList(DocumentSnapshot doc) {
    ContactFromList.listDoc = doc;
  }

  @override
  State<StatefulWidget> createState() => new ContactFromListState(listDoc);
}

/// CLASS TO SHOW/ADD/DELETE CONTACT FROM A SPECIFIED LIST
class ContactFromListState extends State<ContactFromList> {
  ContactService _contactService = ContactService();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  //Game card creator to sent to the game
  List<GameCard> gameCard = new List<GameCard>();

  //Constructor
  ContactFromListState(data);

  //Search management
  bool searchActive = false;
  String search = "";
  FocusNode focusNodeSearchBar = FocusNode();
  String id;

  //Page title
  Widget _appBarTitle = new Text(
      ContactFromList.listDoc.data()["listName"] + " list",
      style: TextStyle(color: Colors.black, fontSize: 22));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _appBarTitle,
        leading: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Lists()),
              );
            },
            child: new IconTheme(
              data: Theme.of(context).iconTheme,
              child: Icon(
                Icons.arrow_back, // add custom icons also
              ),
            )),
        actions: <Widget>[
          IconTheme(
            data: Theme.of(context).iconTheme,
            child: IconButton(
              icon: Icon(Icons.sports_esports),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          GameScreen(ContactFromList.listDoc.id, gameCard)),
                );
              },
            ),
          ),
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
                            hintStyle: TextStyle(color: Colors.black),
                            hintText: 'Search...'),
                      );
                    } else {
                      search = "";
                      this._appBarTitle = new Text(
                          ContactFromList.listDoc.data()["listName"] + " list",
                          style: Theme.of(context).textTheme.headline1);
                    }
                  });
                  focusNodeSearchBar.requestFocus();
                },
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
            stream:
                _contactService.getContactsFromList(ContactFromList.listDoc),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              gameCard.clear();
              if (snapshot.hasData) {
                return Column(
                  children: snapshot.data.docs.map(
                    (doc) {
                      if (doc
                          .data()['lists']
                          .contains(ContactFromList.listDoc.id)) {
                        gameCard.add(GameCard(doc.id, doc.data()['image'],
                            doc.data()['firstname'], doc.data()['lastname']));
                      }
                      String unionFirstLastName =
                          doc.data()['firstname'].toString().toLowerCase() +
                              " " +
                              doc.data()['lastname'].toString().toLowerCase();
                      String unionLastFirstName =
                          doc.data()['lastname'].toString().toLowerCase() +
                              " " +
                              doc.data()['firstname'].toString().toLowerCase();
                      return (doc
                                  .data()['lists']
                                  .contains(ContactFromList.listDoc.id) &&
                              (unionLastFirstName
                                      .contains(search.toLowerCase()) ||
                                  unionFirstLastName
                                      .contains(search.toLowerCase())))
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
                                              _contactService
                                                  .deleteContactFromList(
                                                      ContactFromList.listDoc,
                                                      doc);
                                              Navigator.of(context).pop(true);
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
                              background: Container(
                                  padding: EdgeInsets.only(right: 20.0),
                                  alignment: Alignment.centerRight,
                                  color: Colors.red,
                                  child:
                                      Icon(Icons.delete, color: Colors.white)),
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
          )
        ],
      ),
      floatingActionButton: SpeedDial(
        backgroundColor: Colors.cyan,
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          SpeedDialChild(
            child: Icon(Icons.add),
            backgroundColor: Colors.blue,
            label: 'Add from existing',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ContactsList(ContactFromList.listDoc)),
              );
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.upload_file),
            backgroundColor: Colors.blueGrey,
            label: 'Import a list',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ContactListImportation(ContactFromList.listDoc)),
              );
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.fiber_new_outlined),
            backgroundColor: Colors.green,
            label: 'New contact',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ContactNew(ContactFromList.listDoc)),
              );
            },
          ),
        ],
      ),
    );
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
        _contactService.deleteContactFromList(
            ContactFromList.listDoc, contactDoc);
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Confirm"),
      content: Text("Are you sure you want to delete " +
          contactDoc.data()['firstname'] +
          " " +
          contactDoc.data()['lastname'] +
          " from the " +
          ContactFromList.listDoc.data()['listName'] +
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

  //Card builder
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
                  CircleAvatar(
                    backgroundImage: NetworkImage(contactDoc.data()['image']),
                  ),
                  SizedBox(width: 10),
                  //TEST FOR THE NAME/SURNAME LENGTH
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
}
