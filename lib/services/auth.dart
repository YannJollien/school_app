import 'package:firebase_auth/firebase_auth.dart';
import 'package:schoolapp/models/user.dart';
import 'package:schoolapp/services/database.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Create user obj based on FirebaseUser
  UserModel _userFromFirebaseUser(User user){
    return user != null ? UserModel(uid: user.uid) : null;
  }

  // Sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try{
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e){
      print(e.toString());
      return null;
    }
  }

  //Sign out
  Future signOut() async{
    try{
      await _auth.signOut();
    }
    catch(e) {
      print(e.toString());
      return null;
    }
  }

  // Register with email and password
  Future registerWithEmailAndPassword(String email, String password, String name) async {
    try{
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User user = result.user;
      //create a new document for the user with the uid
      await DatabaseService(uid: user.uid).updateUserData(name);
      return _userFromFirebaseUser(user);
    } catch (e){
        print(e.toString());
        return null;
    }
  }

  //Delete user
  Future deleteUser() async{
    User user = await _auth.currentUser;
    user.delete();
    await DatabaseService(uid: user.uid).deleteUserData();
  }

}