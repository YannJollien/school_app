import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schoolapp/components/home_drawer.dart';
import 'package:schoolapp/services/listService.dart';
import 'contact_list/contactsFromList.dart';

class Lists extends StatefulWidget {
  @override
  ListsState createState() {
    return ListsState();
  }
}

/// CLASS TO SHOW/MODIFY/ADD LISTS
class ListsState extends State<Lists> {

  //Database management
  final db = FirebaseFirestore.instance;
  ListService _listService = ListService();
  String id;

  @override
  Widget build(BuildContext context) {
    final autoID = db.collection('lists').doc().id;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.cyan,
        onPressed: () {
          AlertDialogAddList(context).then((value) => setState(() async {
                final checkName = await _listService.getDocument(value);
                if (value != null) {
                  if (checkName == 0) {
                    _listService.addList(autoID, value);
                  } else {
                    AlertListName(context);
                  }
                }
              }));
        },
      ),
      appBar: AppBar(
        title: Text('My lists', style: Theme.of(context).textTheme.headline1),
      ),
      drawer: HomeDrawer(),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
            stream: _listService.getLists(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: snapshot.data.docs.map((doc) {
                    return Dismissible(
                      key: Key(doc.id),
                      onDismissed: (direction) {},
                      confirmDismiss: (DismissDirection direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Delete " + doc.data()['listName']),
                              content: Text(
                                  "Are you sure you want to delete this list ? The contacts in this list will be deleted from the applicaiton."),
                              actions: <Widget>[
                                FlatButton(
                                  color: Colors.cyan,
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text("Cancel",
                                      style: TextStyle(color: Colors.white)),
                                ),
                                FlatButton(
                                    color: Colors.red,
                                    onPressed: () {
                                      _listService.deleteSubLists(doc.id);
                                      _listService.deleteLists(doc.id);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Delete",
                                        style: TextStyle(color: Colors.white))),
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
                          child: Icon(Icons.delete, color: Colors.white)),
                      child: buildItem(doc),
                    );
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

  //Card builder
  Card buildItem(DocumentSnapshot doc) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ContactFromList(doc)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '${doc.data()['listName']}',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(width: 8),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.cyan,
                    onPressed: () {
                      AlertDialogDeleteList(context, doc);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.mode_edit),
                    color: Colors.cyan,
                    onPressed: () {
                      AlertDialogUpdateList(context)
                          .then((value) => setState(() async {
                        final checkName =
                        await _listService.getDocument(value);
                        if (value != null) {
                          if (checkName == 0) {
                            _listService.updateLists(doc.id, value);
                          } else {
                            AlertListName(context);
                          }
                        }
                      }));
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // To add a list an alert dialog is displayed on the screen,
  // it will ask the user to enter the name of the list he wants to create
  Future<String> AlertDialogAddList(BuildContext context) async {
    TextEditingController customController = new TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: TextField(
              controller: customController,
              decoration: new InputDecoration(labelText: 'List name'),
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
                child: Text("Add"),
                onPressed: () {
                  Navigator.of(context).pop(customController.text.toString());
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Lists()),
                  );
                },
              ),
            ],
          );
        });
  }

  // To update a list an alert dialog is displayed on the screen,
  // it will ask the user to enter a new name for the list, if the user
  // clicks outside of the alert dialog, the update is cancel.
  Future<String> AlertDialogUpdateList(BuildContext context) {
    //checkName ICI!!!!!!!!!!!!!!!
    TextEditingController customController = new TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: TextField(
              controller: customController,
              decoration: new InputDecoration(labelText: 'List name'),
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
                child: Text("Update"),
                onPressed: () {
                  Navigator.of(context).pop(customController.text.toString());
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Lists()),
                  );
                },
              ),
            ],
          );
        });
  }

  // When a user want to delete a list an alert dialog appears to ask him
  // if he really want to delete his list knowing that all his contact will
  // be deleted wit the list.
  AlertDialogDeleteList(BuildContext context, DocumentSnapshot doc) {
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
        _listService.deleteSubLists(doc.id);
        _listService.deleteLists(doc.id);
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete " + doc.data()['listName']),
      content: Text(
          "Are you sure you want to delete this list ? The contacts from this list will be NOT deleted definitively."),
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

  //When a user try to enter a list name that is already asigned to one of the
  //existing list, an alert message appear telling him that the name already
  //exist and that he should put another name
  AlertListName(BuildContext context) {
    // set up the buttons
    Widget OkButton = FlatButton(
      child: Text(
        "Ok",
        style: TextStyle(color: Colors.white),
      ),
      color: Colors.cyan,
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text(
          "A list with the same name already exist! Please, choose another name."),
      actions: [
        OkButton,
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
