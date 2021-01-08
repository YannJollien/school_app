import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:schoolapp/components/contactDetails.dart';
import 'package:schoolapp/components/game_main.dart';
import 'package:schoolapp/components/lists.dart';
import 'package:schoolapp/services/contactService.dart';
import 'contactNew.dart';
import 'contactsAllList.dart';

class ContactFromList extends StatefulWidget {
  static DocumentSnapshot listDoc;

  ContactFromList(DocumentSnapshot doc) {
    ContactFromList.listDoc = doc;
  }

  @override
  State<StatefulWidget> createState() => new ContactFromListState(listDoc);
}

class ContactFromListState extends State<ContactFromList> {
  String id;
  ContactService _contactService = ContactService();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  ContactFromListState(data);

  bool searchActive = false;
  String search = "";

  Widget _appBarTitle = new Text(
      ContactFromList.listDoc.data()["listName"] + " list",
      style: TextStyle(color: Colors.white));

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
              onPressed: () {
                setState(() {
                  searchActive = !searchActive;
                  if (searchActive) {
                    this._appBarTitle = new TextField(
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
                    this._appBarTitle = new Text(
                        ContactFromList.listDoc.data()["listName"] + " list",
                        style: TextStyle(color: Colors.white));
                  }
                });
              },
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
              if (snapshot.hasData) {
                return Column(
                  children: snapshot.data.docs.map(
                    (doc) {
                      String unionLastFirstName = doc.data()['firstname'] + doc.data()['lastname'];
                      return (doc
                                  .data()['lists']
                                  .contains(ContactFromList.listDoc.id) &&
                          unionLastFirstName.contains(search))
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
          )
        ],
      ),
      floatingActionButton: SpeedDial(
        backgroundColor: Colors.cyan,
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          SpeedDialChild(
              child: Icon(Icons.save_alt),
              backgroundColor: Colors.red,
              label: 'Import',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () => print('FIRST CHILD')),
          SpeedDialChild(
            child: Icon(Icons.add),
            backgroundColor: Colors.blue,
            label: 'Add',
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
            child: Icon(Icons.fiber_new_outlined),
            backgroundColor: Colors.green,
            label: 'New',
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

  showAlertDialog(BuildContext context, DocumentSnapshot contactDoc) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel", style: TextStyle(color: Colors.white)),
      color: Colors.cyan,
      onPressed: () {
        Navigator.of(context).pop();
        // Navigator.pushReplacement(context,
        //     MaterialPageRoute(builder: (BuildContext context) => super.widget));
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
                  Image.network(
                    contactDoc.data()['image'],
                    width: MediaQuery.of(context).size.width / 8,
                    height: MediaQuery.of(context).size.width / 8,
                  ),
                  // FutureBuilder(
                  //   future: getImage(
                  //       context, firebaseAuth.currentUser.email, contactDoc.id),
                  //   builder: (context, snapshot) {
                  //     if (snapshot.connectionState == ConnectionState.done) {
                  //       return Container(
                  //         width: MediaQuery.of(context).size.width / 8,
                  //         height: MediaQuery.of(context).size.width / 8,
                  //         child: snapshot.data,
                  //       );
                  //     }
                  //     if (snapshot.connectionState == ConnectionState.waiting) {
                  //       return Container(
                  //         width: MediaQuery.of(context).size.width / 8,
                  //         height: MediaQuery.of(context).size.width / 8,
                  //         child: CircularProgressIndicator(),
                  //       );
                  //     }
                  //     return Container();
                  //   },
                  // ),
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
