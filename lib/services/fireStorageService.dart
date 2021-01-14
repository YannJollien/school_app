import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//Helper class to get the image
class FireStorageService extends ChangeNotifier {
  FireStorageService();

  static Future<dynamic> loadContactImage(
      BuildContext context, String email, String docId) async {
    return await FirebaseStorage.instance
        .ref("contacts/$email/$docId")
        .getDownloadURL();
  }

  static Future<dynamic> loadConnectedUserImage(BuildContext context, String email) async {
    return await FirebaseStorage.instance.ref("images/$email").getDownloadURL();
  }

  static Future<dynamic> loadImageForDatabase(String email, String docId) async {
    return await FirebaseStorage.instance
        .ref("contacts/$email/$docId")
        .getDownloadURL();
  }
}