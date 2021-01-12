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

  //Get contact details
  Future<DocumentSnapshot> getContactListsData(DocumentSnapshot doc) {
    return collectionUser
        .doc(uid)
        .collection('contacts')
        .doc(doc.id)
        .get();
  }

  //Get contact details
  Future<String> getContactListNamesData(List<dynamic> listId) async {

    DocumentSnapshot ds ;

    //String of the list names
    String listNames = "" ;

    //For each id list, add the name of the list
    for(int i=0; i<listId.length; i++){

      ds = await collectionUser.doc(uid).collection('lists').doc(listId.elementAt(i)).get();

      //In case of a list is deleted, don't return null data
      if(ds.data()!=null){
        //Add list name in the string
        listNames += ds.data()['listName'] + " ";

        //Display management to not add "/" for the last list name
        if(i+1<listId.length){
          listNames += "/ ";
        }
      }
    }

    //In case of the contact have no list
    if(listNames.isEmpty){
      return listNames  = "This contact is not in any list";
    }

    return listNames;
  }

  Future<String> getContactNotesData(DocumentSnapshot doc) async {
    DocumentSnapshot ds =
        await collectionUser.doc(uid).collection('contacts').doc(doc.id).get();
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
      'lists': FieldValue.arrayUnion([docList.id])
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
    String t;
    await FireStorageService.loadImage(firebaseAuth.currentUser.email, docId)
        .then((value) {
      t = value.toString();
    });
    return t;
  }

  //Update details of a contact
  Future addImageLinkData(String id) async {
    return await collectionUser.doc(uid).collection('contacts').doc(id).update({
      'image': await getImageFromFirestore(id),
    });
  }

  //Add contact in a list
  Future addContactData(DocumentSnapshot docList, String firstname,
      String lastname, String institution) async {
    print("URL " + 'https://avatar.oxro.io/avatar.svg?name=' + firstname + "+" + lastname + '&background=random&caps=3&bold=true');
    DocumentReference docRef =
        await collectionUser.doc(uid).collection('contacts').add({
      'firstname': firstname,
      'lastname': lastname,
      'institution': institution,
      'notes': '',
      'lists': [docList.id],
          //API call in case of no image is added, this api create an image with the initials of the contact
      'image': 'https://eu.ui-avatars.com/api/?name=' + firstname + "+" + lastname + '&size=128&background=random',
    });
    return docRef;
  }

  //Get all contacts
  Stream<QuerySnapshot> getAllContactsData() {
    return collectionUser.doc(uid).collection('contacts').orderBy('firstname').snapshots();
  }

  //Get contact from a list
  Stream<QuerySnapshot> getContactsFromListData(DocumentSnapshot listDoc) {
    return collectionUser
        .doc(uid)
        .collection('contacts')
        .orderBy('firstname')
        // .where('lists', arrayContains: listDoc.id)
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
    return collectionUser.doc(uid).collection('lists').orderBy('listName', descending: false).snapshots();
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

  //Get the wrong answer of a list
  Future<String> getWrongAnswersData(String doc) async {
    DocumentSnapshot ds =
    await collectionUser.doc(uid).collection('lists').doc(doc).get();
    return ds.data()['wrongAnswers'];
  }

  //Add data to the list of wrong answers
  Future updateWrongAnswersData(
      String docList, String docContact) async {
    return await collectionUser
        .doc(uid)
        .collection('lists')
        .doc(docContact)
        .update({
      'wrongAnswers': FieldValue.arrayUnion([docList])
    });
  }

  //Delete the content of the wrong answers
  Future deleteWrongAnswers(String doc) async{
    return await collectionUser.doc(uid).collection('lists')
        .doc(doc)
        .update({'wrongAnswer' : FieldValue.delete()});
  }
}

class FireStorageService extends ChangeNotifier {
  FireStorageService();

  static Future<dynamic> loadImage(String email, String docId) async {
    print('LOAD IMAGE ' +
        await FirebaseStorage.instance
            .ref("contacts/$email/$docId")
            .getDownloadURL()
            .toString());

    return await FirebaseStorage.instance
        .ref("contacts/$email/$docId")
        .getDownloadURL();
  }
}
