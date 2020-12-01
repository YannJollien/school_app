import 'package:flutter/foundation.dart';
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

  String name;
  String collectionName = 'users/{134fJsKGo4fD2NEXhmVlPxUBTIh2}';

  ListService _listService = ListService();

  Card buildItem(DocumentSnapshot doc) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ContactList(doc.data()['listName'])),
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
                     _listService.deleteLists(doc.id);
                     _listService.deleteSubLists(doc.id);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.mode_edit),
                    color: Colors.blue,
                    onPressed: () {
                      AlertDialogUpdateList(context).then((value) => setState(() {
                        _listService.updateLists(doc.id, value);
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
      floatingActionButton: FloatingActionButton (
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        onPressed: (){
          AlertDialogAddList(context).then((value) => setState(() {
            if(value != null) {
              _listService.addList(autoID, value);
              _listService.addCollection(autoID, 'Contact');
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
}