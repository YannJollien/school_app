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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${doc.data()['listName']}',
              style: TextStyle(fontSize: 24),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                SizedBox(width: 8),
                FlatButton(
                  onPressed: () => deleteData(doc),
                  child: Text('Delete'),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ContactList(doc.data()['listName'])),
                    );
                  },
                  child: Text('Show'),
                ),
              ],
            )
          ],
        ),
      ),
    );
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
        ],
      ),
    );
  }

  void deleteData(DocumentSnapshot doc) async {

  }
}