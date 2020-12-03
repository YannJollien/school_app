
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';


class DatabaseService {

  final String uid;

  DatabaseService({this.uid});

  //Collection reference user
  final CollectionReference collectionUser = FirebaseFirestore.instance.collection("users");



  Future updateUserData(String name) async{
    return await collectionUser.doc(uid).set({
      'name' : name,
    });
  }

  //Delet user from cloud firestore
  Future deleteUserData() async{
    return await collectionUser.doc(uid).delete();
  }

  //Get lists for a user
  Stream<QuerySnapshot> getListsData() {
    return collectionUser.doc(uid).collection('lists').snapshots();
  }

  //Add a list for a user
  Future addListsData(String docID, String listName) async{
    return await collectionUser.doc(uid).collection('lists').doc(docID).set({'listName': listName});
  }


  //Update lists for a user
  Future updateListsData(String doc, String listName) async{
    return await collectionUser.doc(uid).collection('lists').doc(doc).update({'listName': listName});
  }

  //Delete lists for a user
  Future deleteListsData(String doc) async{
    return await collectionUser.doc(uid).collection('lists').doc(doc).delete();
  }

  //Delete all contacts from a list
  Future deleteSubListsData(String doc) async{
    return await collectionUser.doc(uid).collection('lists').doc(doc).collection('Contact').get().then((value) {
      for (DocumentSnapshot ds in value.docs){
        ds.reference.delete();
      }
    });
  }

}