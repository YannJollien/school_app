import 'package:cloud_firestore/cloud_firestore.dart';

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

  //Delet user from cloud firestore
  Future deleteUserData() async {
    return await collectionUser.doc(uid).delete();
  }

  //Get contact list
  Stream<DocumentSnapshot> getContactDetailsData(DocumentSnapshot doc) {
    return collectionUser
        .doc(uid)
        .collection('contacts')
        .doc(doc.id)
        .snapshots();
  }

  //Delete contact in a list
  Future deleteContactData(
      DocumentSnapshot docList, DocumentSnapshot docContact) async {
    return await collectionUser
        .doc(uid)
        .collection('contacts')
        .doc(docContact.id)
        .update({
      'lists': FieldValue.arrayRemove([docList.id])
    });
  }

  //Update notes of a contact
  Future addContactNotesData(DocumentSnapshot docContact, String notes) async {
    return await collectionUser
        .doc(uid)
        .collection('contacts')
        .doc(docContact.id)
        .update({
      'notes': notes,
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
      'lists': [docList.id]
    });

    return docRef.id;
  }

  //Get contact list
  Stream<QuerySnapshot> getContactsListData(DocumentSnapshot listDoc) {
    return collectionUser
        .doc(uid)
        .collection('contacts')
        .where('lists', arrayContains: listDoc.id)
        .snapshots();
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
