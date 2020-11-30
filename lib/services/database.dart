
import 'package:cloud_firestore/cloud_firestore.dart';

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
  Future updateListsData() async{
    return await collection.doc(uid).collection('lists').snapshots();
  }

  //Delete lists for a user
  Future deleteListsData(DocumentSnapshot doc) async{
    return await collection.doc(uid).collection('lists').doc().snapshots();
  }

}