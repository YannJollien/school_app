import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:schoolapp/services/database.dart';
import 'database.dart';

class ContactService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Update a contact
  Future updateContact(DocumentSnapshot docList, DocumentSnapshot docContact) async{
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).updateContactData(docList, docContact);
  }

  //Delete a contact
  Future deleteContact(DocumentSnapshot docList, DocumentSnapshot docContact) async{
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).deleteContactData(docList, docContact);
  }

  //Add a contact notes
  Future updateContactNotes(DocumentSnapshot docContact, String notes) async{
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).updateContactNotesData(docContact, notes);
  }

  //Add a list
  Future addContact(DocumentSnapshot docList, String firstname, String lastname, String institution) async{
    User user = await _auth.currentUser;
    return await DatabaseService(uid: user.uid).addContactData(docList, firstname, lastname, institution);
  }

  Stream<DocumentSnapshot> getContactDetails(DocumentSnapshot doc) {
    User user = _auth.currentUser;
    return DatabaseService(uid: user.uid).getContactDetailsData(doc);
  }

  //Get the all contacts
  Stream<QuerySnapshot> getAllContacts() {
    User user =  _auth.currentUser;
    return DatabaseService(uid: user.uid).getAllContactsData();
  }

  //Get the lists
  Stream<QuerySnapshot> getContactsFromList(DocumentSnapshot listDoc) {
    User user =  _auth.currentUser;
    return DatabaseService(uid: user.uid).getContactsFromListData(listDoc);
  }

}