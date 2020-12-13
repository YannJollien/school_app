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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Contact details'),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 0),
              child: IconButton(
                icon: Icon(Icons.delete),
                color: Colors.red,
                onPressed: () {
                  showAlertDialog(context);
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
              detailsSection,
            ],
          ),
        ));
  }

  showAlertDialog(BuildContext context) {
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
      title: Text("Delete " +
          ContactDetails.contactDoc.data()['firstname'] +
          " " +
          ContactDetails.contactDoc.data()['lastname']),
      content: Text("Are you sure you want to delete this contact ?"),
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

//  //Get the image from storage
//  Future<Widget> getImage(BuildContext context, String imageName) async {
//    Image image;
//    await FireStorageService.loadImage(context, imageName).then((value) {
//      image = Image.network(
//          value.toString(),
//          fit: BoxFit.scaleDown
//      );
//    });
//    return image;
//  }

  Widget detailsSection = Container(
    padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
    child: Row(
      children: [
        Expanded(
          /*1*/
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Icon(
                  Icons.account_box,
                  size: 150,
                ),
              ),
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
              _buildNotes('notes')
            ],
          ),
        ),
      ],
    ),
  );

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
  static Widget _buildNotes(String content) {
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
              _contactService.addContactNotes(ContactDetails.contactDoc, '');
              notesController.clear();
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

  //CONTENT WIDGET
  static Widget _content(String content){
    return FutureBuilder(
        future: getContactData(content),
        initialData: "Loading text..",
        builder: (BuildContext context, AsyncSnapshot<String> text) {
          return new SingleChildScrollView(
              child: new Text(
                text.data,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[500],
                ),
              ));
        });
  }

  //GET CONTACT DATA
  static Future<String> getContactData(String content) async {
    Future<DocumentSnapshot> contactDetails =
        _contactService.getContactDetails(ContactDetails.contactDoc);
    String data = "";
    await contactDetails.then((carSnapshot) => {
      data = carSnapshot.data()[content],
        });
    return await new Future(() => data);
  }
}

//Helper class to get the image
class FireStorageService extends ChangeNotifier {
  FireStorageService();

  static Future<dynamic> loadImage(BuildContext context, String email) async {
    return await FirebaseStorage.instance.ref("images/$email").getDownloadURL();
  }
}
