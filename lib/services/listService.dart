import 'package:firebase_auth/firebase_auth.dart';

import 'database.dart';

class ListService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Delete user
  Future getLists() async{
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).getListsData();
  }
}