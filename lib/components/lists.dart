import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schoolapp/components/contactList.dart';
import 'package:schoolapp/services/listService.dart';

class Lists extends StatefulWidget {
  @override
  ListsState createState() {
    return ListsState();
  }
}

class ListsState extends State<Lists> {
  String id;
  final db = FirebaseFirestore.instance;
  
  ListService _listService = ListService();

  Card buildItem(DocumentSnapshot doc) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ContactList(doc)),
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
                  IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.blue,
                    onPressed: () {
                      AlertDialogDeleteList(context, doc);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.mode_edit),
                    color: Colors.blue,
                    onPressed: () {
                      AlertDialogUpdateList(context).then((value) => setState(() {
                        if(value!=null) {
                          _listService.updateLists(doc.id, value);
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

  @override
  Widget build(BuildContext context) {
    final autoID = db.collection('lists').doc().id;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      floatingActionButton: FloatingActionButton (
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        onPressed: (){
          AlertDialogAddList(context).then((value) => setState(() {
            if(value != null) {
              _listService.addList(autoID, value);
            }
          }));
        },
      ),
      appBar: AppBar(
        title: Text('My lists'),
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
            stream: _listService.getLists(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
    );
  }

  // To add a list an alert dialog is displayed on the screen,
  // it will ask the user to enter the name of the list he wants to create
  Future<String> AlertDialogAddList(BuildContext context) {
    TextEditingController customController = new TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: TextField(
              controller: customController,
              decoration:
              new InputDecoration(labelText: 'list name'),
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
                child: Text("Add"),
                onPressed: () {
                  Navigator.of(context).pop(customController.text.toString());
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
    TextEditingController customController = new TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: TextField(
              controller: customController,
              decoration:
              new InputDecoration(labelText: 'list name'),
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
                child: Text("Update"),
                onPressed: () {
                  Navigator.of(context).pop(customController.text.toString());
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
        _listService.deleteSubLists(doc.id);
        _listService.deleteLists(doc.id);
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete " + doc.data()['listName']),
      content: Text(
          "Are you sure you want to delete this list ? The contacts in this list will be deleted from the applicaiton."),
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