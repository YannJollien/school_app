import 'package:firebase_auth/firebase_auth.dart';
import 'package:schoolapp/models/user.dart';
import 'package:schoolapp/services/database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Create user obj based on FirebaseUser
  UserModel _userFromFirebaseUser(User user) {
    return user != null ? UserModel(uid: user.uid) : null;
  }

  // Sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //Sign out
  Future signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Register with email and password
  Future registerWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      //create a new document for the user with the uid
      await DatabaseService(uid: user.uid).updateUserData(name);
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  void changePassword(String password1, String password2) async {
    //Create an instance of the current user.
    User user = _auth.currentUser;

    if (password1 == password2) {
      //Pass in the password to updatePassword.
      user.updatePassword(password1).then((_) {
        print("Succesfull changed password");
      }).catchError((error) {
        print("Password can't be changed" + error.toString());
        //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
      });
    }
  }

  //Delete user
  Future deleteUser() async {
    User user = await _auth.currentUser;
    user.delete();
    await DatabaseService(uid: user.uid).deleteUserData();
  }
}
