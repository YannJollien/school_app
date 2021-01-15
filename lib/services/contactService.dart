import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:schoolapp/services/database.dart';
import 'database.dart';

/// CLASS FOR CONTACT IN FIRESTORE DATABASE
class ContactService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Update a contact
  Future updateContactLists(
      DocumentSnapshot docList, DocumentSnapshot docContact) async {
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid)
        .updateContactListsData(docList, docContact);
  }

  //Delete a contact from a list
  Future deleteContactFromList(
      DocumentSnapshot docList, DocumentSnapshot docContact) async {
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid)
        .deleteContactFromListData(docList, docContact);
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

  //Update contact details
  Future updateContactDetails(DocumentSnapshot docContact, String firstname,
      String lastname, String institution, String notes) async {
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).updateContactDetailsData(
        docContact, firstname, lastname, institution, notes);
  }

  //Add a contact
  Future addContact(DocumentSnapshot docList, String firstname, String lastname,
      String institution) async {
    User user = await _auth.currentUser;
    return await DatabaseService(uid: user.uid)
        .addContactData(docList, firstname, lastname, institution);
  }

  //Add image url to the contact
  Future addImageLink(String id) async {
    User user = await _auth.currentUser;
    return await DatabaseService(uid: user.uid).addImageLinkData(id);
  }

  //Get contact details
  Stream<DocumentSnapshot> getContactDetails(DocumentSnapshot doc) {
    User user = _auth.currentUser;
    return DatabaseService(uid: user.uid).getContactDetailsData(doc);
  }

  //Get all the contact lists
  Future<DocumentSnapshot> getContactLists(DocumentSnapshot doc) {
    User user = _auth.currentUser;
    return DatabaseService(uid: user.uid).getContactListsData(doc);
  }

  //Get all the contact lists names
  Future<String> getContactListNames(List<dynamic> listId) {
    User user = _auth.currentUser;
    return DatabaseService(uid: user.uid).getContactListNamesData(listId);
  }

  //Get the all contacts
  Stream<QuerySnapshot> getAllContacts() {
    User user = _auth.currentUser;
    return DatabaseService(uid: user.uid).getAllContactsData();
  }

  //Get the contacts list
  Stream<QuerySnapshot> getContactsFromList(DocumentSnapshot listDoc) {
    User user = _auth.currentUser;
    return DatabaseService(uid: user.uid).getContactsFromListData(listDoc);
  }

  //Get notes of a contact
  Future<String> getContactNotes(DocumentSnapshot doc) {
    User user = _auth.currentUser;
    return DatabaseService(uid: user.uid).getContactNotesData(doc);
  }
}
