
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'database.dart';

class ListService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Get the lists
  Stream<QuerySnapshot> getLists() {
    User user =  _auth.currentUser;
    return DatabaseService(uid: user.uid).getListsData();
  }


  //Update a list
  Future addList(String docId, String listName) async{
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).addListsData(docId, listName);
  }

  //Update a list
  Future addCollection(String docId, String listName) async{
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).addCollectionData(docId, listName);
  }

  //Update a list
  Future updateLists(String doc, String listName) async{
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).updateListsData(doc, listName);
  }


  //Delete a list
  Future deleteLists(String doc) async{
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).deleteListsData(doc);
  }

  //Delete a list
  Future deleteSubLists(String doc) async{
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).deleteSubListData(doc);
  }

}