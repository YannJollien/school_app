import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

class ContactsListState extends State<ContactsList> {
  ContactService _contactService = ContactService();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  ContactsListState(data);

  Map<String, bool> values = {
    'foo': true,
    'bar': false,
    't': false,
    'basr': false,
  };

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('All contacts')),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
            stream: _contactService.getAllContacts(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                  FutureBuilder(
                    future: getImage(context, firebaseAuth.currentUser.email,
                        contactDoc.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Container(
                          width: MediaQuery.of(context).size.width / 8,
                          height: MediaQuery.of(context).size.width / 8,
                          child: snapshot.data,
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          width: MediaQuery.of(context).size.width / 8,
                          height: MediaQuery.of(context).size.width / 8,
                          child: CircularProgressIndicator(),
                        );
                      }
                      return Container();
                    },
                  ),
                  SizedBox(width: 10),
                  Text(
                    '${contactDoc.data()['firstname']}' +
                        ' ' +
                        '${contactDoc.data()['lastname']}',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(width: 8),
                  Spacer(),
                  _buildChild(contactDoc),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChild(DocumentSnapshot contactDoc) {
    List values = contactDoc.data()['lists'];
    if (values.contains(widget.listDoc.id)) {
      return IconButton(
        icon: Icon(Icons.playlist_add_check_sharp),
        onPressed: null,
      );
    }else{
      return IconButton(
        icon: Icon(Icons.playlist_add_sharp),
        color: Colors.cyan,
        onPressed: () {
          _contactService.updateContactLists(widget.listDoc, contactDoc);
        },
      );
    }
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
