import 'dart:io';
import 'dart:typed_data';
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

class ContactNewState extends State<ContactNew> {
  String id;
  ContactService _contactService = ContactService();
  final _formKey = GlobalKey<FormState>();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  ContactNewState(data);

  File imageFile;
  Reference ref;
  String downloadUrl;
  bool imageAdded = true;
  UploadTask up ;

  //Contacts
  Iterable<Contact> _contacts;
  Contact _actualContact;

  //Get image
  Future getImage() async {
    File image;
    image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageFile = image;
    });
  }

  //Upload image
  Future uploadImage(String email, String docId) async {
    ref = FirebaseStorage.instance.ref().child("contacts/$email/$docId");
    up = ref.putFile(imageFile);
  }

  //Get image Url
  Future downloadImage() async {
    String downloadAddress = await ref.getDownloadURL();
    setState(() {
      downloadUrl = downloadAddress;
    });
  }

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
                GestureDetector(
                  onTap: () => getImage(),
                  child: Container(
                      height: 250,
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      child: imageFile == null
                          ? Text(
                              "Tap to add profile picture",
                              style: TextStyle(color: Colors.grey[400]),
                            )
                          : Image.file(imageFile)),
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

  var lastNameController = TextEditingController();

  Widget _buildLastName() {
    return TextFormField(
//      enabled: false,
      controller: lastNameController,
      validator: (value) => value.isEmpty ? "Last name cannot be empty" : null,
      style: TextStyle(color: Colors.grey, fontFamily: 'RadikalLight'),
      decoration: _buildInputDecoration(
          "Last name *", Icons.person, lastNameController),
    );
  }

  var institutionController = TextEditingController();

  Widget _buildInstitution() {
    return TextFormField(
      controller: institutionController,
      style: TextStyle(color: Colors.grey, fontFamily: 'RadikalLight'),
      decoration: _buildInputDecoration(
          "Institution", Icons.apartment, institutionController),
    );
  }

  Widget _buildImportButton(BuildContext context) {
    return Center(
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.save_alt),
            iconSize: 50,
            color: Colors.cyan,
            onPressed: () {
              _showContactList(context);
            },
          ),
          SizedBox(width: 5),
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
              if (_formKey.currentState.validate() && imageFile != null) {
                var temp = _contactService.addContact(
                    widget.listDoc,
                    firstNameController.text,
                    lastNameController.text,
                    institutionController.text);
                temp.then((value) {
                  uploadImage(firebaseAuth.currentUser.email, value.id);
                  up.whenComplete(() => _contactService.addImageLink(value.id));
                });
                // downloadImage();
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

  //Icon according to the textfield
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


  // Getting list of contacts from AGENDA
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

  // Showing contact list.
  Future _showContactList(BuildContext context) async {
    List<Contact> favoriteElements = [];
    final InputDecoration searchDecoration = const InputDecoration();

    await refreshContacts();
    if (_contacts != null)
    {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          print("im in");
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
          lastNameController.text = _actualContact.familyName;
          firstNameController.text = _actualContact.givenName;
          institutionController.text = _actualContact.company;
          // Uint8List avatar = _actualContact.avatar;
          // File image;
          // image = await ImagePicker.pickImage(source: ImageSource.gallery);
          // image = File.fromRawPath(avatar);
          // setState(() {
          //   imageFile = image;
          // });
          // setState(() {
          //   imageFile = ImagePicker.pickImage(source: ImageSource.camera) as File;
            // imageFile = File.fromRawPath(avatar);
          // });
        }
      });
    }
  }
}
