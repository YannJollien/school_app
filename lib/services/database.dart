import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  final String uid;

  DatabaseService({this.uid});

  //Collection reference
  final CollectionReference collection = Firestore.instance.collection("users");

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

  //Get user lists
  Future getListsData() async{
    return await collection.doc(uid).collection('lists').snapshots();
  }

}