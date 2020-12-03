import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schoolapp/services/contactService.dart';

import 'contactList.dart';
import 'contactNew.dart';

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
  final db = FirebaseFirestore.instance;
  ContactService _contactService = ContactService();
  final _formKey = GlobalKey<FormState>();

  ContactNewState(data);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New contact'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: IconButton(
              icon: Icon(Icons.save),
              color: Colors.white,
              iconSize: 30,
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _contactService.addContact(
                      widget.doc,
                      firstNameController.text,
                      lastNameController.text,
                      phoneController.text,
                      emailController.text,
                      institutionController.text);
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
                IconButton(
                  icon: Icon(Icons.add_photo_alternate),
                  iconSize: 125,
                  color: Colors.black,
                  onPressed: () {},
                ),
                _buildFirstName(),
                _buildLastName(),
                _buildPhone(),
                _buildEmail(),
                _buildInstitution(),
                SizedBox(height: 30),
                _buildImportButton(context),
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

  var phoneController = TextEditingController();
  Widget _buildPhone() {
    return TextFormField(
      controller: phoneController,
      style: TextStyle(color: Colors.grey, fontFamily: 'RadikalLight'),
      decoration: _buildInputDecoration("Phone", Icons.call, phoneController),
    );
  }

  var emailController = TextEditingController();
  Widget _buildEmail() {
    return TextFormField(
      controller: emailController,
      style: TextStyle(color: Colors.grey, fontFamily: 'RadikalLight'),
      decoration: _buildInputDecoration("Email", Icons.email, emailController),
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
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      IconButton(
        icon: Icon(Icons.save_alt),
        iconSize: 50,
        color: Colors.black,
        onPressed: () {},
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
