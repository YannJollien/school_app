
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

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

  //Insert image
  Future uploadImage(String email) async{
    final _storage = FirebaseStorage.instance;
    final _picker = ImagePicker();
    PickedFile image;

    image = await _picker.getImage(source: ImageSource.gallery);
    var file = File(image.path);

    if(image != null){
      _storage.ref()
          .child("images/$email")
          .putFile(file);
      print("Uploaded");
    }else {
      print("No path recieved");
    }
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
  Future addListsData(String listName) async{
    return await collection.doc(uid).collection('lists');
  }


  //Update lists for a user
  Future updateListsData(String doc, String listName) async{
    return await collection.doc(uid).collection('lists').doc(doc).set({'listName': listName});
  }

  //Delete lists for a user
  Future deleteListsData(String doc) async{
    return await collection.doc(uid).collection('lists').doc(doc).delete();
  }

}