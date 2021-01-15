import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schoolapp/services/contactService.dart';

class ContactsList extends StatefulWidget {
  DocumentSnapshot listDoc;

  ContactsList(DocumentSnapshot doc) {
    this.listDoc = doc;
  }

  @override
  State<StatefulWidget> createState() => new ContactsListState(listDoc);
}

/// CLASS TO ADD CONTACT IN YOUR LIST FROM CONTACT ALREADY ADDED IN THE APPLICATION
class ContactsListState extends State<ContactsList> {

  //Connection with firestore
  ContactService _contactService = ContactService();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  //Constructor
  ContactsListState(data);

  //Search bar management
  bool searchActive = false;
  String search = "";
  FocusNode focusNodeSearchBar = FocusNode();

  //Page title
  Widget _appBarTitle =
      new Text("All contacts", style: TextStyle(color: Colors.black));

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: _appBarTitle,
        actions: <Widget>[
          //Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: IconButton(
              icon: Icon(Icons.search),
              color: Colors.black,
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
                          hintStyle: TextStyle(color: Colors.black),
                          hintText: 'Search...'),
                    );
                  } else {
                    search = "";
                    this._appBarTitle = new Text('All contacts',
                        style: Theme.of(context).textTheme.headline1);
                  }
                });
                focusNodeSearchBar.requestFocus();
              },
            ),
          ),
        ],
      ),
      //List all contact
      body: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
            stream: _contactService.getAllContacts(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: snapshot.data.docs.map((doc) {
                    String unionFirstLastName =
                        doc.data()['firstname'].toString().toLowerCase() +
                            " " +
                            doc.data()['lastname'].toString().toLowerCase();
                    String unionLastFirstName =
                        doc.data()['lastname'].toString().toLowerCase() +
                            " " +
                            doc.data()['firstname'].toString().toLowerCase();
                    return (unionLastFirstName.contains(search.toLowerCase()) ||
                            unionFirstLastName.contains(search.toLowerCase()))
                        ? buildItem(doc)
                        : Row();
                  }).toList(),
                );
              } else {
                return SizedBox();
              }
            },
          )
        ],
      ),
    );
  }

  //Card builder for the display
  Card buildItem(DocumentSnapshot contactDoc) {
    return Card(
      child: InkWell(
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
                  _buildAddToListBtn(contactDoc),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Button builder to add a contact to the list
  Widget _buildAddToListBtn(DocumentSnapshot contactDoc) {
    List values = contactDoc.data()['lists'];
    if (values.contains(widget.listDoc.id)) {
      return IconButton(
        icon: Icon(Icons.playlist_add_check_sharp),
        onPressed: null,
      );
    } else {
      return IconButton(
        icon: Icon(Icons.playlist_add_sharp),
        color: Colors.cyan,
        onPressed: () {
          _contactService.updateContactLists(widget.listDoc, contactDoc);
        },
      );
    }
  }
}
