import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:schoolapp/components/game/game_card.dart';
import 'package:schoolapp/services/database.dart';

import 'database.dart';

class ListService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Get the lists
  Stream<QuerySnapshot> getLists() {
    User user =  _auth.currentUser;
    return DatabaseService(uid: user.uid).getListsData();
  }

  //Get document to check the name of a list
  Future<int> getDocument(String newListName) async{
    User user = await _auth.currentUser;
    return await DatabaseService(uid: user.uid).getDocumentData(newListName);
  }

  //Add a list
  Future addList(String docId, String listName) async{
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).addListsData(docId, listName);
  }

  //Update score
  Future updateScore(String doc, String newScore) async{
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).updateScoreData(doc, newScore);
  }

  //Update a list
  Future updateLists(String doc, String listName) async{
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).updateListsData(doc, listName);
  }

  //Delete a list
  Future deleteLists(String doc) async{
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).deleteListsData(doc);
  }

  //Delete a list
  Future deleteSubLists(String doc) async{
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).deleteSubListsData(doc);
  }

  Future addIdToWrongAnswers(String docList, String wrongContactId) async{
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).addIdToWrongAnswersData(docList, wrongContactId);
  }

  Future removeIdToWrongAnswers(String docList, String wrongContactId) async{
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).removeIdToWrongAnswersData(docList, wrongContactId);
  }

  Future<DocumentSnapshot> getContactIdWrongOfTheList(String listDoc) {
    User user = _auth.currentUser;
    return DatabaseService(uid: user.uid).getContactIdWrongOfTheListData(listDoc);
  }

  Stream<DocumentSnapshot> getContactIdWrongOfTheListStream(String listDoc) {
    User user = _auth.currentUser;
    return DatabaseService(uid: user.uid).getContactIdWrongOfTheListStreamData(listDoc);
  }

  Future<List<GameCard>>getWrongContactFromTheList(List<dynamic> contactsId) {
    User user = _auth.currentUser;
    return DatabaseService(uid: user.uid).getWrongContactFromTheListData(contactsId);
  }
}