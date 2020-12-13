import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DatabaseService {
  final String uid;

  DatabaseService({this.uid});

  //Collection reference user
  final CollectionReference collectionUser =
      FirebaseFirestore.instance.collection("users");

  //Collection reference contacts
  final CollectionReference collectionContacts =
      FirebaseFirestore.instance.collection("contacts");

  Future updateUserData(String name) async {
    return await collectionUser.doc(uid).set({
      'name': name,
    });
  }

  //Delet user from cloud firestore
  Future deleteUserData() async {
    return await collectionUser.doc(uid).delete();
  }

  //Get contact list
  Stream<DocumentSnapshot> getContactDetailsData(DocumentSnapshot doc) {
    return collectionContacts.doc(doc.id).snapshots();
  }

  //Delete contact in a list
  Future deleteContactData(
      DocumentSnapshot docList, DocumentSnapshot docContact) async {
    return await collectionUser
        .doc(uid)
        .collection('lists')
        .doc(docList.id)
        .collection('contacts')
        .doc(docContact.id)
        .delete();
  }

  //Update notes of a contact
  Future addContactNotesData(DocumentSnapshot docContact, String notes) async {
    return await collectionContacts.doc(docContact.id).update({
      'notes': notes,
    });
  }

  //Add contact in a list
  Future addContactData(DocumentSnapshot docList, String firstname,
      String lastname, String phone, String email, String institution) async {
    return await collectionUser
        .doc(uid)
        .collection('lists')
        .doc(docList.id)
        .collection('contacts')
        .add({
      'firstname': firstname,
      'lastname': lastname,
      'institution': institution,
      'notes': ''
    });
  }

  //Get contact list for a user
//  Future<List<QueryDocumentSnapshot>> getContactListData(
//      DocumentSnapshot doc) async {
//
////    Stream<QuerySnapshot> contactsOfList =
////        await collectionContacts.snapshots();
//
////    List<QueryDocumentSnapshot> docsList = new List<QueryDocumentSnapshot>();
////    List<String> values = List.from(doc['contacts']);
////    contactsOfList.forEach((contact) {
////      if (values.contains(contact.id)) {
////        docsList.add(contact.docs[1]);
////      }
////    });
//
//    List<QueryDocumentSnapshot> docsList = new List<QueryDocumentSnapshot>();
//    Stream<QuerySnapshot> contactsOfList = FirebaseFirestore.instance.collection("contacts").snapshots();
////    List<String> values = List.from(doc['contacts']);
//    contactsOfList.forEach((field) {
//      field.docs.asMap().forEach((index, data) {
//        docsList.add(field.docs[index]);
//      });
//    });
//
////    for (int i = 0; i < contactsOfList.length; i++) {
////      QueryDocumentSnapshot a = contactsOfList.docs[i];
////      if(values.contains(a.id)){
////        docsList.add(a);
////      }
////    }
//
//    return docsList;
//  }
  //Get contact list for a user
  Future<List<QueryDocumentSnapshot>> getContactListData(DocumentSnapshot doc) async {

    QuerySnapshot contactsOfList =
    await FirebaseFirestore.instance.collection("contacts").get();

    List<QueryDocumentSnapshot> docsList = new List<QueryDocumentSnapshot>() ;
    List<String> values = List.from(doc['contacts']);
    for (int i = 0; i < contactsOfList.docs.length; i++) {
      QueryDocumentSnapshot a = contactsOfList.docs[i];
      if(values.contains(a.id)){
        docsList.add(a);
      }
    }

    return docsList;
  }

  //Get contact list
  Stream<QuerySnapshot> getListContactsData() {
    return collectionContacts.snapshots();
  }

  //Get lists for a user
  Stream<QuerySnapshot> getListsData() {
    return collectionUser.doc(uid).collection('lists').snapshots();
  }

  //Get one list for a user
  Stream<DocumentSnapshot> getListData(DocumentSnapshot doc) {
    return collectionUser.doc(uid).collection('lists').doc(doc.id).snapshots();
  }

  //Add a list for a user
  Future addListsData(String docID, String listName) async {
    return await collectionUser
        .doc(uid)
        .collection('lists')
        .doc(docID)
        .set({'listName': listName});
  }

  //Update lists for a user
  Future updateListsData(String doc, String listName) async {
    return await collectionUser
        .doc(uid)
        .collection('lists')
        .doc(doc)
        .update({'listName': listName});
  }

  //Delete lists for a user
  Future deleteListsData(String doc) async {
    return await collectionUser.doc(uid).collection('lists').doc(doc).delete();
  }

  //Delete all contacts from a list
  Future deleteSubListsData(String doc) async {
    return await collectionUser
        .doc(uid)
        .collection('lists')
        .doc(doc)
        .collection('contacts')
        .get()
        .then((value) {
      for (DocumentSnapshot ds in value.docs) {
        ds.reference.delete();
      }
    });
  }
}
