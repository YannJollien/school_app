import 'dart:io';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:schoolapp/services/contactService.dart';
import '../contact_list/contactsFromList.dart';
import 'package:permission_handler/permission_handler.dart';
import 'contacts_dialog.dart';

class ContactNew extends StatefulWidget {
  DocumentSnapshot listDoc;

  ContactNew(DocumentSnapshot doc) {
    this.listDoc = doc;
  }

  @override
  State<StatefulWidget> createState() => new ContactNewState(listDoc);
}

/// CLASS TO ADD A NEW CONTACT TO YOUR LIST
/// 1. IMPORT INFORMATION FROM CONTACT APPLICATION OF THE SMARTPHONE ITSELF
/// 2. FULLFILLED IT MANUALLY
class ContactNewState extends State<ContactNew> {

  //Constructor
  ContactNewState(data);

  //Connection with firestore
  ContactService _contactService = ContactService();
  final _formKey = GlobalKey<FormState>();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  //Image management
  File imageFile;
  Reference ref;
  bool imageAdded = true;
  UploadTask up;

  //Contacts
  Iterable<Contact> _contacts;
  Contact _actualContact;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Add a contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 1.8,
                  height: MediaQuery.of(context).size.width / 1.8,
                  child: GestureDetector(
                    onTap: () => getImage(),
                    child: Container(
                        height: 250,
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(110)),
                        alignment: Alignment.center,
                        child: imageFile == null
                            ? Text(
                                "Tap to add profile picture",
                                style: TextStyle(color: Colors.grey[400]),
                              )
                            : CircleAvatar(
                                backgroundImage: new FileImage(imageFile),
                                radius: 200.0)),
                  ),
                ),
                imageAdded == false
                    ? Text("Profile picture cannot be empty",
                        style: TextStyle(color: Colors.cyan, fontSize: 12))
                    : Text(""),
                _buildFirstName(),
                _buildLastName(),
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

  //Get image from gallery
  Future getImage() async {
    File image;
    image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageFile = image;
    });
  }

  //Upload image to firebase storage in a folder according to user connected
  Future uploadImage(String email, String docId) async {
    ref = FirebaseStorage.instance.ref().child("contacts/$email/$docId");
    up = ref.putFile(imageFile);
  }

  //Build firstname field
  var firstNameController = TextEditingController();
  Widget _buildFirstName() {
    return TextFormField(
      controller: firstNameController,
      validator: (value) => value.isEmpty ? "First name cannot be empty" : null,
      style: TextStyle(color: Colors.grey, fontFamily: 'RadikalLight'),
      decoration: _buildInputDecoration(
          "First name *", Icons.person, firstNameController),
    );
  }

  //Build lastname field
  var lastNameController = TextEditingController();
  Widget _buildLastName() {
    return TextFormField(
      controller: lastNameController,
      validator: (value) => value.isEmpty ? "Last name cannot be empty" : null,
      style: TextStyle(color: Colors.grey, fontFamily: 'RadikalLight'),
      decoration: _buildInputDecoration(
          "Last name *", Icons.person, lastNameController),
    );
  }

  //Build institution field
  var institutionController = TextEditingController();
  Widget _buildInstitution() {
    return TextFormField(
      controller: institutionController,
      style: TextStyle(color: Colors.grey, fontFamily: 'RadikalLight'),
      decoration: _buildInputDecoration(
          "Institution", Icons.apartment, institutionController),
    );
  }

  //Build import button to access contact of smartphone
  //And save button
  Widget _buildImportButton(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.save_alt),
            iconSize: 50,
            color: Colors.cyan,
            onPressed: () {
              _showSmartphoneContactList(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.save),
            iconSize: 50,
            color: Colors.cyan,
            onPressed: () {
              if (imageFile == null) {
                setState(() {
                  imageAdded = false;
                });
              }
              //If all required field are fullfilled
              if (_formKey.currentState.validate() && imageFile != null) {
                //Add contact to db
                var temp = _contactService.addContact(
                    widget.listDoc,
                    firstNameController.text,
                    lastNameController.text,
                    institutionController.text);
                //Wait the contact to be added and push image with contact id just created
                temp.then((value) {
                  uploadImage(firebaseAuth.currentUser.email, value.id);
                  up.whenComplete(() => _contactService.addImageLink(value.id));
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      // builder: (context) => ContactDetails(widget.listDoc, t)),
                      builder: (context) => ContactFromList(widget.listDoc)),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  //Icon according to the textfield decoration
  InputDecoration _buildInputDecoration(
      String hint, IconData icons, TextEditingController controller) {
    return InputDecoration(
        hintText: hint,
        labelText: hint,
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        hintStyle: TextStyle(color: Colors.grey),
        icon: Icon(icons),
        errorStyle: TextStyle(color: Colors.cyan),
        errorBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyan)),
        suffixIcon: IconButton(
          onPressed: () {
            controller.clear();
          },
          icon: Icon(Icons.clear),
        ),
        focusedErrorBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyan)));
  }

  // Refresh list of smartphone contact
  refreshContacts() async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      var contacts = await ContactsService.getContacts();
      setState(() {
        _contacts = contacts;
      });
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  // Asking Contact permissions
  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.contacts);
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.disabled) {
      Map<PermissionGroup, PermissionStatus> permissionStatus =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.contacts]);
      return permissionStatus[PermissionGroup.contacts] ??
          PermissionStatus.unknown;
    } else {
      return permission;
    }
  }

  // Managing error when you don't have permissions
  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      throw new PlatformException(
          code: "PERMISSION_DENIED",
          message: "Access to location data denied",
          details: null);
    } else if (permissionStatus == PermissionStatus.disabled) {
      throw new PlatformException(
          code: "PERMISSION_DISABLED",
          message: "Location data is not available on device",
          details: null);
    }
  }

  //Showing contact list.
  Future _showSmartphoneContactList(BuildContext context) async {
    List<Contact> favoriteElements = [];
    final InputDecoration searchDecoration = const InputDecoration();

    await refreshContacts();
    if (_contacts != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          //Show the smartphone contact list
          return SelectionDialogContacts(
            _contacts.toList(),
            favoriteElements,
            showCountryOnly: false,
            emptySearchBuilder: null,
            searchDecoration: searchDecoration,
          );
        },
      ).then((e) async {
        if (e != null) {
          setState(() {
            _actualContact = e;
          });

          //Reset the field
          lastNameController.text = '';
          firstNameController.text = '';
          institutionController.text = '';

          //Fullfield automatically the field (if the contact selected have the field in question)
          if (_actualContact.familyName != null) {
            lastNameController.text = _actualContact.familyName;
          }
          if (_actualContact.givenName != null) {
            firstNameController.text = _actualContact.givenName;
          }
          if (_actualContact.company != null) {
            institutionController.text = _actualContact.company;
          }
        }
      });
    }
  }
}
