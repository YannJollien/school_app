import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:schoolapp/components/contact_list/contactsFromList.dart';
import 'package:schoolapp/services/contactService.dart';

class ContactListImportation extends StatefulWidget {
  static DocumentSnapshot listDoc;

  ContactListImportation(DocumentSnapshot doc) {
    listDoc = doc;
  }

  @override
  State<StatefulWidget> createState() => new ContactListImportationState(listDoc);
}

class ContactListImportationState extends State<ContactListImportation> {
  ContactListImportationState(data);

  ContactService _contactService = ContactService();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('File Picker Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              child: Text('Get documents'),
              onPressed: () {
                getCSVAndPushDataToFirestore();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ContactFromList(ContactListImportation.listDoc)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  //Method to get csv document of the user smartphone and push it to firestore according to field (firstname, lastname, institution)
  Future getCSVAndPushDataToFirestore() async {
    File fileToImport;

    //Set the document picker
    FlutterDocumentPickerParams params = FlutterDocumentPickerParams(
      allowedFileExtensions: ['csv'],
      allowedUtiTypes: ['csv'],
    );

    //Open the document picker (to pick in the smartphone files of the user)
    final path = await FlutterDocumentPicker.openDocument(params: params);

    //Save the file to import
    setState(() {
      fileToImport = File(path);
    });

    //Separate csv data
    //Split "\n"
    final csvContent = fileToImport.readAsStringSync();
    final splitEachRows = csvContent.split('\n');
    //Map the data in string
    final Map<int, String> rowsValue = {
      for (int i = 0; i < splitEachRows.length; i++) i: splitEachRows[i]
    };

    //Loop to get each rows
    for (int i = 0; i < rowsValue.length; i++) {
      //Split ","
      final splitEachColumns = rowsValue[i].split(',');
      //Map the data of each rows
      final Map<int, String> columnsValue = {
        for (int i = 0; i < splitEachColumns.length; i++) i: splitEachColumns[i]
      };
      //If data is not null push it to firestore (firstname, lastname, institution)
      if(columnsValue[1] != null){
        // imageFile = new File('https://eu.ui-avatars.com/api/?name='+columnsValue[0]+"+"+columnsValue[1]);
        _contactService.addContact(ContactListImportation.listDoc, columnsValue[0], columnsValue[1], columnsValue[2]);
        // var temp = _contactService.addContact(ContactListImportation.listDoc, columnsValue[0], columnsValue[1], columnsValue[2]);
        // temp.then((value) {
        //   uploadImage(firebaseAuth.currentUser.email, value.id);
        //   up.whenComplete(() => _contactService.addImageLink(value.id));
        // });
        // _contactService.addContact(ContactListImportation.listDoc, columnsValue[0], columnsValue[1], columnsValue[2]);
      }
    }
  }

  //Upload image
  Future uploadImage(String email, String docId) async {
    ref = FirebaseStorage.instance.ref().child("contacts/$email/$docId");
    print("image path " + imageFile.path);
    up = ref.putFile(imageFile);
  }

  File imageFile;
  Reference ref;
  UploadTask up ;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
}
