import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactList extends StatefulWidget {
  String listName;

  ContactList(String name) {
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
      child: InkWell(
        onTap: () {
          //NAVIGATION PUSH
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
                    '${doc.data()['surname']}' + ' ' + '${doc.data()['name']}',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.blue,
                    onPressed: () {},
                  ),
//                FlatButton(
//                  onPressed: () {
//                    Navigator.push(
//                      context,
//                      MaterialPageRoute(
//                          builder: (context) =>
//                              ContactList(doc.data()['listName'])),
//                    );
//                  },
//                  child: Text('Show'),
//                ),
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
      appBar: AppBar(
        title: Text('Contacts'),
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
//            stream: db.collectionGroup(widget.listName.toLowerCase()).snapshots(),
            stream: db
                .collection('users')
                .doc('134fJsKGo4fD2NEXhmVlPxUBTIh2')
                .collection('lists')
                .doc('MaSJtHSIGWl1UtVKCemx')
                .collection(widget.listName.toLowerCase())
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                    children: snapshot.data.docs
                        .map((doc) => buildItem(doc))
                        .toList());
              } else {
                return SizedBox();
              }
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          createAlertDialog(context).then((value) => setState(() {
            if (value.isNotEmpty) {
              db
                  .collection('users')
                  .doc('134fJsKGo4fD2NEXhmVlPxUBTIh2')
                  .collection('lists')
                  .doc('MaSJtHSIGWl1UtVKCemx')
                  .collection(widget.listName.toLowerCase())
                  .add({
                'name': value.substring(value.indexOf(' ')+1, value.length),
                'surname': value.substring(0, value.indexOf(' ')),
                'phone': '',
                'email': '',
                'institution': '',
                'notes': ''
              });
            }
          }));
        },
      ),
    );
  }

  Future<String> createAlertDialog(BuildContext context) {
    TextEditingController customController = new TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: TextField(
              controller: customController,
              decoration:
              new InputDecoration(labelText: 'Full name', hintText: 'John Smith'),
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

  void deleteData(DocumentSnapshot doc) async {}
}
