import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:schoolapp/services/database.dart';

import 'database.dart';

class ContactService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Get the list of contacts
  Stream<QuerySnapshot> getContactList(DocumentSnapshot doc) {
    User user =  _auth.currentUser;
    return DatabaseService(uid: user.uid).getContactListData(doc);
  }

  //Delete a contact
  Future deleteContact(DocumentSnapshot docList, DocumentSnapshot docContact) async{
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).deleteContactData(docList, docContact);
  }

  //Add a contact notes
  Future addContactNotes(DocumentSnapshot docList, DocumentSnapshot docContact, String notes) async{
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).addContactNotesData(docList, docContact, notes);
  }

  //Add a list
  Future addContact(DocumentSnapshot docList, String firstname, String lastname, String phone, String email, String institution) async{
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).addContactData(docList, firstname, lastname, phone, email, institution);
  }
}