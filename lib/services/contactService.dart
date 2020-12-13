import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:schoolapp/services/database.dart';

import 'database.dart';

class ContactService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Get the list of contacts
  Future<List<QueryDocumentSnapshot>> getContactList(DocumentSnapshot doc) {
    User user =  _auth.currentUser;
    return DatabaseService(uid: user.uid).getContactListData(doc);
  }

  //Delete a contact
  Future deleteContact(DocumentSnapshot docList, DocumentSnapshot docContact) async{
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).deleteContactData(docList, docContact);
  }

  //Add a contact notes
  Future addContactNotes(DocumentSnapshot docContact, String notes) async{
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).addContactNotesData(docContact, notes);
  }

  //Add a list
  Future addContact(DocumentSnapshot docList, String firstname, String lastname, String phone, String email, String institution) async{
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).addContactData(docList, firstname, lastname, phone, email, institution);
  }

  Future<DocumentSnapshot> getContactDetails(DocumentSnapshot doc) async {
    User user = await _auth.currentUser;
    return DatabaseService(uid: user.uid).getContactDetailsData(doc);
  }

  Future<DocumentSnapshot> getContactArrayFromList(DocumentSnapshot doc) async {
    User user = await _auth.currentUser;
    return DatabaseService(uid: user.uid).getContactArrayFromListData(doc);
  }

  //Get the lists
  Stream<QuerySnapshot> getListContacts() {
    User user =  _auth.currentUser;
    return DatabaseService(uid: user.uid).getListContactsData();
  }
}