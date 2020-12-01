
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DatabaseService {

  final String uid;


  DatabaseService({this.uid});

  //Collection reference
  final CollectionReference collection = FirebaseFirestore.instance.collection("users");

  //Insert user into cloud firestore
  Future updateUserData(String name) async{
    return await collection.doc(uid).set({
      'name' : name,
    });
  }

  //Delet user from cloud firestore
  Future deleteUserData() async{
    return await collection.doc(uid).delete();
  }

  //Get lists for a user
  Stream<QuerySnapshot> getListsData() {
    return collection.doc(uid).collection('lists').snapshots();
  }

  //Update lists for a user
  Future addListsData(String docID, String listName) async{
    return await collection.doc(uid).collection('lists').doc(docID).set({'listName': listName});
  }

  //Update lists for a user
  Future addCollectionData(String docID, String listName) async{
    return await collection.doc(uid).collection('lists').doc(docID).collection(listName).add({});
  }


  //Update lists for a user
  Future updateListsData(String doc, String listName) async{
    return await collection.doc(uid).collection('lists').doc(doc).update({'listName': listName});
  }

  //Delete lists for a user
  Future deleteListsData(String doc) async{
    return await collection.doc(uid).collection('lists').doc(doc).delete();
  }

  //Delete lists for a user
  Future deleteSubListData(String doc) async{
    return await collection.doc(uid).collection('lists').doc(doc).collection('Contact').get().then((value) {
      for (DocumentSnapshot doc in value.docs) {
        doc.reference.delete();
      }
    });
  }

}