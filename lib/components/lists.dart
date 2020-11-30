import 'package:firebase_auth/firebase_auth.dart';
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
  final _formKey = GlobalKey<FormState>();
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
                      db
                          .collection('users')
                          .doc('134fJsKGo4fD2NEXhmVlPxUBTIh2')
                          .collection('lists')
                          .doc(doc.data()['listName'])
                          .delete();
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

  Future<String> createAlertDialog(BuildContext context) {
    TextEditingController customController = new TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Category"),
            content: TextField(
              controller: customController,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My lists'),
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
//            stream: db.collectionGroup('lists').snapshots(),
            stream: db
                .collection('users')
                .doc('134fJsKGo4fD2NEXhmVlPxUBTIh2')
                .collection('lists')
                .snapshots(),
            builder: (context, snapshot) {
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
//
//          FutureBuilder(
//              future: _listService.getLists(),
//              builder: (context, snapshot) {
//                if (snapshot.hasData) {
//                  return Column(
//                    children: snapshot.data.docs
//                        .map((doc) => buildItem(doc))
//                        .toList(),
//                  );
//                } else {
//                  return SizedBox();
//                }
//              })
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          createAlertDialog(context).then((value) => setState(() {
                db
                    .collection('users')
                    .doc('134fJsKGo4fD2NEXhmVlPxUBTIh2')
                    .collection('lists')
                    .doc('1')
                    .set({'listName': value});
                db
                    .collection('users')
                    .doc('134fJsKGo4fD2NEXhmVlPxUBTIh2')
                    .collection('lists')
                    .doc('1')
                    .collection(value)
                    .add({
                  'name': '',
                  'surname': 'Auto creation',
                  'phone': '',
                  'email': '',
                  'institution': '',
                  'notes': ''
                });
//                    .set({'test': value});
//                    .add({'listName': value});
              }));
        },
      ),
    );
  }

  void deleteData(DocumentSnapshot doc) async {}
}
