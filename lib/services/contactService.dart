import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:schoolapp/services/database.dart';
import 'database.dart';

class ContactService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Update a contact
  Future updateContactLists(
      DocumentSnapshot docList, DocumentSnapshot docContact) async {
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).updateContactListsData(docList, docContact);
  }

  //Delete a contact from a list
  Future deleteContactFromList(
      DocumentSnapshot docList, DocumentSnapshot docContact) async {
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).deleteContactFromListData(docList, docContact);
  }

  //Delete contact definitively
  Future deleteContact(DocumentSnapshot docContact) async {
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).deleteContactData(docContact);
  }

  //Update a contact notes
  Future updateContactNotes(DocumentSnapshot docContact, String notes) async {
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid)
        .updateContactNotesData(docContact, notes);
  }

  Future updateContactDetails(DocumentSnapshot docContact, String firstname,
      String lastname, String institution, String notes) async {
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid)
        .updateContactDetailsData(docContact, firstname, lastname, institution, notes);
  }

  //Add a contact
  Future addContact(DocumentSnapshot docList, String firstname, String lastname,
      String institution) async {
    User user = await _auth.currentUser;
    return await DatabaseService(uid: user.uid)
        .addContactData(docList, firstname, lastname, institution);
  }

  Future addImageLink(String id) async {
    User user = await _auth.currentUser;
    return await DatabaseService(uid: user.uid)
        .addImageLinkData(id);
  }

  Stream<DocumentSnapshot> getContactDetails(DocumentSnapshot doc) {
    User user = _auth.currentUser;
    return DatabaseService(uid: user.uid).getContactDetailsData(doc);
  }

  //Get the all contacts
  Stream<QuerySnapshot> getAllContacts() {
    User user = _auth.currentUser;
    return DatabaseService(uid: user.uid).getAllContactsData();
  }

  //Get the lists
  Stream<QuerySnapshot> getContactsFromList(DocumentSnapshot listDoc) {
    User user = _auth.currentUser;
    return DatabaseService(uid: user.uid).getContactsFromListData(listDoc);
  }

  Future<String> getContactNotes(DocumentSnapshot doc) {
    User user = _auth.currentUser;
    return DatabaseService(uid: user.uid).getContactNotesData(doc);
  }
}
