
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

  //Delete a list
  Future deleteLists(DocumentSnapshot doc) async{
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).deleteListsData(doc);
  }


  //Update a list
  Future updateLists() async{
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).updateListsData();
  }

}