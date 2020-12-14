import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schoolapp/components/contactList.dart';
import 'package:schoolapp/services/contactService.dart';

class ContactDetails extends StatefulWidget {
  static DocumentSnapshot contactDoc;
  static DocumentSnapshot listDoc;

  ContactDetails(DocumentSnapshot lDoc, DocumentSnapshot cDoc) {
    contactDoc = cDoc;
    listDoc = lDoc;
  }

  @override
  State<StatefulWidget> createState() => new ContactDetailsState(contactDoc);
}

class ContactDetailsState extends State<ContactDetails> {
  ContactDetailsState(data);

  static ContactService _contactService = ContactService();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: Text('Contact details'),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 0),
              child: IconButton(
                icon: Icon(Icons.delete),
                color: Colors.red,
                onPressed: () {
                  showAlertDialogOnDelete(context);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: IconButton(
                icon: Icon(Icons.edit),
                color: Colors.white,
                onPressed: () {},
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              detailsSection(context),
            ],
          ),
        ));
  }

  showAlertDialogOnDelete(BuildContext context) {
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
        _contactService.deleteContact(
            ContactDetails.listDoc, ContactDetails.contactDoc);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ContactList(ContactDetails.listDoc)),
        );
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
//      title: Text('Delete contact from the list'),
      content: Text("Are you sure you want to delete " +
          ContactDetails.contactDoc.data()['firstname'] +
          " " +
          ContactDetails.contactDoc.data()['lastname'] +
          " from the " +
          ContactDetails.listDoc.data()['listName'] +
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

  //Get the image from storage
  Future<Widget> getImage(
      BuildContext context, String imageName, String docId) async {
    Image image;
    await FireStorageService.loadImage(context, imageName, docId).then((value) {
      image = Image.network(value.toString(), fit: BoxFit.scaleDown);
    });
    return image;
  }

  Widget detailsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  ClipOval(
                    child: FutureBuilder(
                      future: getImage(context, firebaseAuth.currentUser.email,
                          ContactDetails.contactDoc.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Container(
                            width: MediaQuery.of(context).size.width / 1.5,
                            height: MediaQuery.of(context).size.width / 1.5,
                            child: snapshot.data,
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            width: MediaQuery.of(context).size.width / 1.2,
                            height: MediaQuery.of(context).size.width / 1.2,
                            child: CircularProgressIndicator(),
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                ]),
                //FIRSTNAME
                _label('Firstname'),
                _content('firstname'),
                SizedBox(height: 20),
                //LASTNAME
                _label('Lastname'),
                _content('lastname'),
                SizedBox(height: 20),
                //INSTITUTION
                _label('Institution'),
                _content('institution'),
                SizedBox(height: 20),
                //NOTES
                _label('Notes'),
                _buildNotes('notes', context)
              ],
            ),
          ),
        ],
      ),
    );
  }

  //LABEL WIDGET
  static Widget _label(String labelName) {
    return Container(
      child: Text(
        labelName,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static final notesController = TextEditingController();

  static Widget _buildNotes(String content, BuildContext context) {
    final int notesLength = 100;
    ContactService _contactService = ContactService();
    return Container(
      height: 5 * 24.0,
      child: TextFormField(
        controller: notesController
          ..text = ContactDetails.contactDoc.data()[content],
//        minLines: 1,
        maxLines: 5,
        maxLength: notesLength,
        maxLengthEnforced: true,
        onChanged: (text) {
          if (text.length < notesLength) {
            _contactService.addContactNotes(ContactDetails.contactDoc, text);
          }
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(10),
          fillColor: Colors.yellow,
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.yellow, width: 5.0),
          ),
          suffixIcon: IconButton(
            onPressed: () {
              showAlertDialogNotes(context);
            },
            icon: Icon(Icons.clear),
            color: Colors.black,
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.yellow),
          ),
        ),
      ),
    );
  }

  static showAlertDialogNotes(BuildContext context) {
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
        _contactService.addContactNotes(ContactDetails.contactDoc, '');
        notesController.clear();
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
//      title: Text('Delete contact from the list'),
      content: Text("Are you sure you want to delete all the notes taken for " +
          ContactDetails.contactDoc.data()['firstname'] +
          " " +
          ContactDetails.contactDoc.data()['lastname'] +
          " ?"),
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

  //CONTENT WIDGET
  static Widget _content(String content) {
    return StreamBuilder(
        stream: _contactService.getContactDetails(ContactDetails.contactDoc),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          return new SingleChildScrollView(
              child: new Text(
            snapshot.data[content],
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[500],
            ),
          ));
        });
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
