import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

class DatabaseService {
  final String uid;

  DatabaseService({this.uid});

  //Collection reference user
  final CollectionReference collectionUser =
      FirebaseFirestore.instance.collection("users");

  Future updateUserData(String name) async {
    return await collectionUser.doc(uid).set({
      'name': name,
    });
  }

  //Delete user from cloud firestore
  Future deleteUserData() async {
    return await collectionUser.doc(uid).delete();
  }

  //Get contact details
  Stream<DocumentSnapshot> getContactDetailsData(DocumentSnapshot doc) {
    return collectionUser
        .doc(uid)
        .collection('contacts')
        .doc(doc.id)
        .snapshots();
  }

  Future<String> getContactNotesData(DocumentSnapshot doc) async {
    DocumentSnapshot ds = await collectionUser
        .doc(uid)
        .collection('contacts')
        .doc(doc.id)
        .get();

    return ds.data()['notes'];
  }

  //Update lists for a user
  Future updateContactListsData(
      DocumentSnapshot docList, DocumentSnapshot docContact) async {
    return await collectionUser
        .doc(uid)
        .collection('contacts')
        .doc(docContact.id)
        .update({
      'lists': [docList.id]
    });
  }

  //Delete contact in a list
  Future deleteContactFromListData(
      DocumentSnapshot docList, DocumentSnapshot docContact) async {
    return await collectionUser
        .doc(uid)
        .collection('contacts')
        .doc(docContact.id)
        .update({
      'lists': FieldValue.arrayRemove([docList.id])
    });
  }

  //Delete contact definitively
  Future deleteContactData(DocumentSnapshot docContact) async {
    return await collectionUser
        .doc(uid)
        .collection('contacts')
        .doc(docContact.id)
        .delete();
  }

  //Update notes of a contact
  Future updateContactNotesData(
      DocumentSnapshot docContact, String notes) async {
    return await collectionUser
        .doc(uid)
        .collection('contacts')
        .doc(docContact.id)
        .update({
      'notes': notes,
    });
  }

  //Update details of a contact
  Future updateContactDetailsData(DocumentSnapshot docContact, String firstname,
      String lastname, String institution, String notes) async {
    return await collectionUser
        .doc(uid)
        .collection('contacts')
        .doc(docContact.id)
        .update({
      'firstname': firstname,
      'lastname': lastname,
      'institution': institution,
      'notes': notes,
    });
  }

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  //Get the image from storage
  Future<String> getImageFromFirestore(String docId) async {
    String t ;
    await FireStorageService.loadImage(firebaseAuth.currentUser.email, docId).then((value) {
      t = value.toString();
    });
    return t;
  }

  //Update details of a contact
  Future addImageLinkData(String id) async {
    return await collectionUser
        .doc(uid)
        .collection('contacts')
        .doc(id)
        .update({
      'image': await getImageFromFirestore(id),
    });
  }

  //Add contact in a list
  Future addContactData(DocumentSnapshot docList, String firstname,
      String lastname, String institution) async {
    DocumentReference docRef =
        await collectionUser.doc(uid).collection('contacts').add({
      'firstname': firstname,
      'lastname': lastname,
      'institution': institution,
      'notes': '',
      'lists': [docList.id],
      'image': '',
    });
    return docRef;
  }

  //Get all contacts
  Stream<QuerySnapshot> getAllContactsData() {
    return collectionUser.doc(uid).collection('contacts').snapshots();
  }

  //Get contact from a list
  Stream<QuerySnapshot> getContactsFromListData(DocumentSnapshot listDoc) {
    return collectionUser
        .doc(uid)
        .collection('contacts')
        .where('lists', arrayContains: listDoc.id)
        .snapshots();
  }

  //Update contact
  Future updateListsData(String doc, String listName) async {
    return await collectionUser
        .doc(uid)
        .collection('lists')
        .doc(doc)
        .update({'listName': listName});
  }

  //Update the score of the game for each list
  Future updateScoreData(String doc, String newScore) async {
    return await collectionUser
        .doc(uid)
        .collection('lists')
        .doc(doc)
        .update({'score': newScore});
  }

  //Get document from the collection lists
  Future<int> getDocumentData(String newListName) async {
    final QuerySnapshot result = await collectionUser
        .doc(uid)
        .collection('lists')
        .where('listName', isEqualTo: newListName)
        .limit(1)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    return documents.length;
  }

  //Get lists for a user
  Stream<QuerySnapshot> getListsData() {
    return collectionUser.doc(uid).collection('lists').snapshots();
  }

  //Add a list for a user
  Future addListsData(String docID, String listName) async {
    return await collectionUser
        .doc(uid)
        .collection('lists')
        .doc(docID)
        .set({'listName': listName, 'score': '0'});
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

class FireStorageService extends ChangeNotifier {
  FireStorageService();

  static Future<dynamic> loadImage(
      String email, String docId) async {

    print('LOAD IMAGE ' + await FirebaseStorage.instance
        .ref("contacts/$email/$docId")
        .getDownloadURL().toString());

    return await FirebaseStorage.instance
        .ref("contacts/$email/$docId")
        .getDownloadURL();
  }
}