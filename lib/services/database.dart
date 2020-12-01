
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
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


  Future getImage(String email) async {
    var refImage = FirebaseStorage.instance.ref().child("images/$email");
    return refImage.getDownloadURL();
  }


  //Delet user from cloud firestore
  Future deleteUserData() async{
    return await collectionUser.doc(uid).delete();
  }

  //Get lists for a user
  Stream<QuerySnapshot> getListsData() {
    return collectionUser.doc(uid).collection('lists').snapshots();
  }

  //Update lists for a user
  Future addListsData(String listName) async{
    return await collectionUser.doc(uid).collection('lists');
  }


  //Update lists for a user
  Future updateListsData(String doc, String listName) async{
    return await collectionUser.doc(uid).collection('lists').doc(doc).set({'listName': listName});
  }

  //Delete lists for a user
  Future deleteListsData(String doc) async{
    return await collectionUser.doc(uid).collection('lists').doc(doc).delete();
  }

}