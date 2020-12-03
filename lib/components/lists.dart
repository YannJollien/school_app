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
                     _listService.deleteLists(doc.id);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.mode_edit),
                    color: Colors.blue,
                    onPressed: () {
                      //_listService.updateLists(doc);
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
    return Scaffold(
      floatingActionButton: FloatingActionButton (
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        onPressed: (){

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
}