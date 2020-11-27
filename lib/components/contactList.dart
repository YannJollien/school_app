import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactList extends StatefulWidget {
  String listName ;

  ContactList(String name){
    this.listName = name;
  }

  @override
  State<StatefulWidget> createState() => new ContactListState(listName);
}

class ContactListState extends State<ContactList> {
  String id;
  final db = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String name;
  String collectionName = 'users/{134fJsKGo4fD2NEXhmVlPxUBTIh2}/family';

  ContactListState(data);

  Card buildItem(DocumentSnapshot doc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${doc.data()['surname']}' + ' ' + '${doc.data()['name']}',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              '${doc.data()['work']}',
              style: TextStyle(fontSize: 20),
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
//                    Navigator.push(
//                      context,
//                      MaterialPageRoute(builder: (context) => Login()),
//                    );
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
        title: Text('Contacts'),
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
            stream: db.collectionGroup(widget.listName.toLowerCase()).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                    children: snapshot.data.docs.map((doc) => buildItem(doc)).toList()
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