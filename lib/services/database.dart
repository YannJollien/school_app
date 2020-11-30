import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class DatabaseService {

  final String uid;

  DatabaseService({this.uid});

  //Collection reference
  final CollectionReference collection = Firestore.instance.collection("users");

  final firestoreInstance = FirebaseFirestore.instance;

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
      //TODO show text that image is loaded
      print("Uploaded");
    }else {
      print("No path recieved");
    }

  }

  //Get name


  //Get user lists
  Future getListsData() async{
    return await collection.doc(uid).collection('lists').snapshots();
  }


}