import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
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

  ContactService _contactService = ContactService();

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
              //PHONE
              _label('Phone'),
              _content('phone'),
              SizedBox(height: 20),
              //EMAIL
              _label('Email'),
              _content('email'),
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

  static Widget _buildNotes(String content) {
    return TextFormField(
      initialValue: ContactDetails.contactDoc.data()[content],
      minLines: 1,
      maxLines: 5,
//      inputFormatters: [
//        new LengthLimitingTextInputFormatter(30),
//      ],
      decoration: InputDecoration(
        fillColor: Colors.yellow,
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.yellow, width: 5.0),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.yellow),
        ),
        suffixIcon: IconButton(
          color: Colors.black,
          onPressed: () {
              //Save the notes
          },
          icon: Icon(Icons.save),
        ),
      ),
    );
  }

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

  static Widget _content(String content) {
    return Text(
      ContactDetails.contactDoc.data()[content],
      style: TextStyle(
        fontSize: 20,
        color: Colors.grey[500],
      ),
    );
  }
}
