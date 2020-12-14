import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:schoolapp/services/contactService.dart';
import 'contactList.dart';

class ContactNew extends StatefulWidget {
  DocumentSnapshot doc;

  ContactNew(DocumentSnapshot doc) {
    this.doc = doc;
  }

  @override
  State<StatefulWidget> createState() => new ContactNewState(doc);
}

class ContactNewState extends State<ContactNew> {
  String id;
  ContactService _contactService = ContactService();
  final _formKey = GlobalKey<FormState>();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  ContactNewState(data);

  File imageFile;
  Reference ref;
  String downloadUrl;

  //Get image
  Future getImage () async {
    File image;
    image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageFile = image;
    });
  }

  //Upload image
  Future uploadImage (String email, String docId) async {
    ref = FirebaseStorage.instance.ref().child("contacts/$email/$docId");
    ref.putFile(imageFile);
  }

  //Get image Url
  Future downloadImage () async {
    String downloadAddress = await ref.getDownloadURL();
    setState(() {
      downloadUrl = downloadAddress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('Add a contact'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: IconButton(
              icon: Icon(Icons.save),
              color: Colors.white,
              iconSize: 30,
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  var temp = _contactService.addContact(
                      widget.doc,
                      firstNameController.text,
                      lastNameController.text,
                      institutionController.text);
                  temp.then((value) => uploadImage(firebaseAuth.currentUser.email, value.toString()));
                  downloadImage();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ContactList(widget.doc)),
                  );
                }
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => getImage(),
                  child: Container(
                      height: 250,
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10)
                      ),
                      alignment: Alignment.center,
                      child: imageFile == null ? Text(
                        "Tap to add image",
                        style: TextStyle(color: Colors.grey[400]),
                      ) : Image.file(imageFile)
                  ),
                ),
                _buildFirstName(),
                _buildLastName(),
                _buildInstitution(),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImportButton(context),
                    _buildFromExistingContacts(context)
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  var firstNameController = TextEditingController();
  Widget _buildFirstName() {
    return TextFormField(
      controller: firstNameController,
      validator: (value) => value.isEmpty ? "First name cannot be empty" : null,
      style: TextStyle(color: Colors.grey, fontFamily: 'RadikalLight'),
      decoration: _buildInputDecoration("First name *", Icons.person, firstNameController),
    );
  }

  var lastNameController = TextEditingController();
  Widget _buildLastName() {
    return TextFormField(
      controller: lastNameController,
      validator: (value) => value.isEmpty ? "Last name cannot be empty" : null,
      style: TextStyle(color: Colors.grey, fontFamily: 'RadikalLight'),
      decoration: _buildInputDecoration("Last name *", Icons.person, lastNameController),
    );
  }

  var institutionController = TextEditingController();
  Widget _buildInstitution() {
    return TextFormField(
      controller: institutionController,
      style: TextStyle(color: Colors.grey, fontFamily: 'RadikalLight'),
      decoration: _buildInputDecoration("Institution", Icons.apartment, institutionController),
    );
  }

  Widget _buildImportButton(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      IconButton(
        icon: Icon(Icons.save_alt),
        iconSize: 50,
        color: Colors.blue,
        onPressed: () {},
      ),
    ]);
  }

  Widget _buildFromExistingContacts(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      IconButton(
        icon: Icon(Icons.list),
        iconSize: 50,
        color: Colors.blue,
        onPressed: () {

        },
      ),
    ]);
  }

  //Icon according to the textfield
  InputDecoration _buildInputDecoration(String hint, IconData icons, TextEditingController controller) {
    return InputDecoration(
        hintText: hint,
        labelText: hint,
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        hintStyle: TextStyle(color: Colors.grey),
        icon: Icon(icons),
        errorStyle: TextStyle(color: Colors.blue),
        errorBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
        suffixIcon: IconButton(
          onPressed: () {
            controller.clear();
          },
          icon: Icon(Icons.clear),
        ),
        focusedErrorBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)));
  }
}
