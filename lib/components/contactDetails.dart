import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schoolapp/components/contactsFromList.dart';
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

  bool editMode = false;

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
                color: Colors.white,
                onPressed: () {
                  showAlertDialogOnDelete(context);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Container(
                  child: (editMode)
                      ? IconButton(
                          icon: Icon(Icons.save),
                          color: Colors.white,
                          onPressed: () {
                            setState(() {
                              editMode = !editMode;
                            });
                          },
                        )
                      : IconButton(
                          icon: Icon(Icons.edit),
                          color: Colors.white,
                          onPressed: () {
                            setState(() {
                              editMode = !editMode;
                            });
                          },
                        )),
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
                  FutureBuilder(
                    future: getImage(context, firebaseAuth.currentUser.email,
                        ContactDetails.contactDoc.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Container(
                          width: MediaQuery.of(context).size.width / 1.8,
                          height: MediaQuery.of(context).size.width / 1.8,
                          child: snapshot.data,
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          width: MediaQuery.of(context).size.width / 1.8,
                          height: MediaQuery.of(context).size.width / 1.8,
                          child: CircularProgressIndicator(),
                        );
                      }
                      return Container();
                    },
                  ),
                ]),
                //FIRSTNAME
                _label('Firstname'),
                Container(
                    child: (editMode)
                        ? _firstnameEditable('firstname')
                        : _contentNotEditable('firstname')),
                SizedBox(height: 20),
                //LASTNAME
                _label('Lastname'),
                Container(
                    child: (editMode)
                        ? _lastnameEditable('lastname')
                        : _contentNotEditable('lastname')),
                SizedBox(height: 20),
                //INSTITUTION
                _label('Institution'),
                Container(
                    child: (editMode)
                        ? _institutionEditable('institution')
                        : _contentNotEditable('institution')),
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

  //FIRSTNAME EDITABLE CONTENT WIDGET
  static var firstnameController = TextEditingController();

  static Widget _firstnameEditable(String content) {
    return StreamBuilder(
        stream: _contactService.getContactDetails(ContactDetails.contactDoc),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          firstnameController.text = snapshot.data[content];
          return new SingleChildScrollView(
            child: new TextFormField(
              controller: firstnameController,
              validator: (value) =>
                  value.isEmpty ? "Last name cannot be empty" : null,
              style: TextStyle(color: Colors.grey, fontFamily: 'RadikalLight'),
              decoration: new InputDecoration(
                hintText: snapshot.data[content],
              ),
            ),
          );
        });
  }

  //LASTNAME EDITABLE CONTENT WIDGET
  static var lastNameController = TextEditingController();

  static Widget _lastnameEditable(String content) {
    return StreamBuilder(
        stream: _contactService.getContactDetails(ContactDetails.contactDoc),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          lastNameController.text = snapshot.data[content];
          return new SingleChildScrollView(
            child: new TextFormField(
              controller: lastNameController,
              validator: (value) =>
                  value.isEmpty ? "Last name cannot be empty" : null,
              style: TextStyle(color: Colors.grey, fontFamily: 'RadikalLight'),
              decoration: new InputDecoration(
                hintText: snapshot.data[content],
              ),
            ),
          );
        });
  }

  //INSTITUTION EDITABLE CONTENT WIDGET
  static var institutionController = TextEditingController();

  static Widget _institutionEditable(String content) {
    return StreamBuilder(
        stream: _contactService.getContactDetails(ContactDetails.contactDoc),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          institutionController.text = snapshot.data[content];
          return new SingleChildScrollView(
            child: new TextFormField(
              controller: institutionController,
              validator: (value) =>
                  value.isEmpty ? "Last name cannot be empty" : null,
              style: TextStyle(color: Colors.grey, fontFamily: 'RadikalLight'),
              decoration: new InputDecoration(
                hintText: snapshot.data[content],
              ),
            ),
          );
        });
  }

  //NONE EDITABLE CONTENT WIDGET
  static Widget _contentNotEditable(String content) {
    return StreamBuilder(
        stream: _contactService.getContactDetails(ContactDetails.contactDoc),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          return new SingleChildScrollView(
            child: new TextFormField(
              enabled: false,
              validator: (value) =>
                  value.isEmpty ? "This field cannot be empty" : null,
              style: TextStyle(color: Colors.grey, fontFamily: 'RadikalLight'),
              decoration: new InputDecoration(
                hintText: snapshot.data[content],
              ),
            ),
          );
        });
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
