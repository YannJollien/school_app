import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:schoolapp/components/game/game_card.dart';
import 'package:schoolapp/services/database.dart';
import 'database.dart';

/// CLASS FOR LIST IN FIRESTORE DATABASE
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

  //Game => contact wrong => add it to list array of wrong contact
  Future addIdToWrongAnswers(String docList, String wrongContactId) async{
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).addIdToWrongAnswersData(docList, wrongContactId);
  }

  //Remove wrong contact of the list array of wrong contact (if right)
  Future removeIdToWrongAnswers(String docList, String wrongContactId) async{
    User user = await _auth.currentUser;
    await DatabaseService(uid: user.uid).removeIdToWrongAnswersData(docList, wrongContactId);
  }

  //Get contact wrong id
  Future<DocumentSnapshot> getContactIdWrongOfTheList(String listDoc) {
    User user = _auth.currentUser;
    return DatabaseService(uid: user.uid).getContactIdWrongOfTheListData(listDoc);
  }

  //Streamer of contact wrong of the list
  Stream<DocumentSnapshot> getContactIdWrongOfTheListStream(String listDoc) {
    User user = _auth.currentUser;
    return DatabaseService(uid: user.uid).getContactIdWrongOfTheListStreamData(listDoc);
  }

  //Start game => reset wrong contact
  Future resetWrongContactFromTheList(String listDoc, String numberChoose) {
    User user = _auth.currentUser;
    return DatabaseService(uid: user.uid).resetWrongContactFromTheListData(listDoc, numberChoose);
  }

  //Get array list of wrong contact add return gamecard
  Future<List<GameCard>>getWrongContactFromTheList(List<dynamic> contactsId) {
    User user = _auth.currentUser;
    return DatabaseService(uid: user.uid).getWrongContactFromTheListData(contactsId);
  }
}