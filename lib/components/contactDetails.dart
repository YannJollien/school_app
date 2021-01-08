import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schoolapp/components/contactsFromList.dart';
import 'package:schoolapp/services/contactService.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ContactDetails extends StatefulWidget {
  static DocumentSnapshot contactDoc;
  static DocumentSnapshot listDoc;

  ContactDetails(DocumentSnapshot lDoc, DocumentSnapshot cDoc) {
    contactDoc = cDoc;
    listDoc = lDoc;
  }

  @override
  State<StatefulWidget> createState() => new ContactDetailsState(contactDoc);
}

class ContactDetailsState extends State<ContactDetails> {
  ContactDetailsState(data);

  bool editMode = false;

  static ContactService _contactService = ContactService();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Contact details'),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 0),
              child: IconButton(
                icon: Icon(Icons.delete),
                color: Colors.white,
                onPressed: () {
                  showAlertDialogOnDelete(context);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Container(
                  child: (editMode)
                      ? IconButton(
                          icon: Icon(Icons.save),
                          color: Colors.white,
                          onPressed: () {
                            uploadImage(firebaseAuth.currentUser.email,
                                ContactDetails.contactDoc.id);
                            _contactService.updateContactDetails(
                                ContactDetails.contactDoc,
                                firstnameController.text,
                                lastNameController.text,
                                institutionController.text,
                                notesController.text);
                            setState(() {
                              editMode = !editMode;
                            });
                            // Navigator.pushReplacement(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (BuildContext context) => super.widget));
                          },
                        )
                      : IconButton(
                          icon: Icon(Icons.edit),
                          color: Colors.white,
                          onPressed: () {
                            setState(() {
                              editMode = !editMode;
                            });
                          },
                        )),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              detailsSection(context),
            ],
          ),
        ));
  }

  showAlertDialogOnDelete(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel", style: TextStyle(color: Colors.white)),
      color: Colors.cyan,
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Delete"),
      color: Colors.red,
      onPressed: () {
        _contactService.deleteContactFromList(
            ContactDetails.listDoc, ContactDetails.contactDoc);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ContactFromList(ContactDetails.listDoc)),
        );
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
//      title: Text('Delete contact from the list'),
      content: Text("Are you sure you want to delete " +
          ContactDetails.contactDoc.data()['firstname'] +
          " " +
          ContactDetails.contactDoc.data()['lastname'] +
          " from the " +
          ContactDetails.listDoc.data()['listName'] +
          " list ?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget detailsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                //   FutureBuilder(
                //     future: getImageFromFirestore(
                //         context,
                //         firebaseAuth.currentUser.email,
                //         ContactDetails.contactDoc.id),
                //     builder: (context, snapshot) {
                //       if (snapshot.connectionState == ConnectionState.done) {
                //         if (editMode) {
                //           docSnapshot = snapshot;
                //           return Container(
                //             width: MediaQuery.of(context).size.width / 1.8,
                //             height: MediaQuery.of(context).size.width / 1.8,
                //             child: new Stack(children: <Widget>[
                //               Container(
                //                   width:
                //                       MediaQuery.of(context).size.width / 1.8,
                //                   height:
                //                       MediaQuery.of(context).size.width / 1.8,
                //                   child: snapshot.data),
                //               Align(
                //                 alignment: Alignment.bottomRight,
                //                 child: FloatingActionButton(
                //                     backgroundColor: Colors.cyan,
                //                     child: new Icon(Icons.add_a_photo),
                //                     onPressed: () {
                //                       getImageFromGallery();
                //                     }),
                //               )
                //             ]),
                //           );
                //         } else {
                //           return Container(
                //             width: MediaQuery.of(context).size.width / 1.8,
                //             height: MediaQuery.of(context).size.width / 1.8,
                //             child: snapshot.data,
                //           );
                //         }
                //       }
                //       if (snapshot.connectionState == ConnectionState.waiting) {
                //         return Container(
                //           width: MediaQuery.of(context).size.width / 1.8,
                //           height: MediaQuery.of(context).size.width / 1.8,
                //           child: CircularProgressIndicator(),
                //         );
                //       }
                //       return Container();
                //     },
                //   ),
                // ]),
                imageLoader('image'),

                //FIRSTNAME
                _label('Firstname'),
                Container(
                    child: (editMode)
                        ? _firstnameEditable('firstname')
                        : _contentNotEditable('firstname')),
                SizedBox(height: 20),
                //LASTNAME
                _label('Lastname'),
                Container(
                    child: (editMode)
                        ? _lastnameEditable('lastname')
                        : _contentNotEditable('lastname')),
                SizedBox(height: 20),
                //INSTITUTION
                _label('Institution'),
                Container(
                    child: (editMode)
                        ? _institutionEditable('institution')
                        : _contentNotEditable('institution')),
                SizedBox(height: 20),
                //NOTES
                _label('Notes'),
                // Container(
                //     child: (editMode)
                //         ? _buildNotesNotEditable('notes', context)
                //         : _buildLiveUpdateNotes('notes', context)),
                _buildLiveUpdateNotes('notes', context),
                // _contentNotEditable('notes'),
//                _buildNotes('notes', context)
              ],
            ),
          ),
        ],
      ),
    );
  }

  //LABEL WIDGET
  static Widget _label(String labelName) {
    return Container(
      child: Text(
        labelName,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static showAlertDialogNotes(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel", style: TextStyle(color: Colors.white)),
      color: Colors.cyan,
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Delete"),
      color: Colors.red,
      onPressed: () {
        _contactService.updateContactNotes(ContactDetails.contactDoc, '');
        notesController.clear();
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
//      title: Text('Delete contact from the list'),
      content: Text("Are you sure you want to delete all the notes taken for " +
          ContactDetails.contactDoc.data()['firstname'] +
          " " +
          ContactDetails.contactDoc.data()['lastname'] +
          " ?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  //Text style for the editable content
  static TextStyle _contentTextStyle() {
    return TextStyle(
        color: Colors.black, fontFamily: 'RadikalLight', fontSize: 20);
  }

  static final notesController = TextEditingController();

  static Widget _buildLiveUpdateNotes(String content, BuildContext context) {
    // ContactService _contactService = ContactService();
    // final int notesLength = 100;

    // print("NOTES CONTROLLER HERE");
    // return StreamBuilder(
    //     stream: _contactService.getContactDetails(ContactDetails.contactDoc),
    //     builder:
    //         (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
    //       notesController.text = snapshot.data[content];
    //       return new SingleChildScrollView(
    //         child: new TextFormField(
    //           controller: notesController,
    //           validator: (value) =>
    //               value.isEmpty ? "Last name cannot be empty" : null,
    //           style: _contentTextStyle(),
    //           onChanged: (text) {
    //             if (text.length < notesLength) {
    //               _contactService.updateContactNotes(
    //                   ContactDetails.contactDoc, text);
    //             }
    //           },
    //           decoration: _buildInputDecoration(notesController),
    //         ),
    //       );
    //     });

    //
    final int notesLength = 100;
    ContactService _contactService = ContactService();

    print("CONTACT DOC ID " + ContactDetails.contactDoc.id);
    StreamBuilder(
        stream: _contactService.getContactDetails(ContactDetails.contactDoc),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          return notesController.text = snapshot.data[content];
        });
    print("NOTES " + notesController.text);
    return Container(
      height: 5 * 24.0,
      child: TextFormField(
        controller: notesController..text = notesController.text,
        maxLines: 5,
        maxLength: notesLength,
        maxLengthEnforced: true,
        onChanged: (text) {
          if (text.length < notesLength) {
            _contactService.updateContactNotes(ContactDetails.contactDoc, text);
          }
        },
        decoration: _buildUpdateNotesDecoration(context),
      ),
    );
  }

  static Widget _buildNotesNotEditable(String content, BuildContext context) {
    final int notesLength = 100;

    return Container(
      height: 5 * 24.0,
      child: TextFormField(
        controller: notesController..text = notesController.text,
        maxLines: 5,
        maxLength: notesLength,
        maxLengthEnforced: true,
        style: TextStyle(
            color: Colors.grey, fontFamily: 'RadikalLight', fontSize: 16),
        decoration: _buildNotesDecoration(),
      ),
    );
  }

  static InputDecoration _buildNotesDecoration() {
    return InputDecoration(
      enabled: false,
      contentPadding: EdgeInsets.all(10),
      fillColor: Colors.yellow,
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.yellow, width: 5.0),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.yellow),
      ),
    );
  }

  static InputDecoration _buildUpdateNotesDecoration(BuildContext context) {
    return InputDecoration(
      contentPadding: EdgeInsets.all(10),
      fillColor: Colors.yellow,
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.yellow, width: 5.0),
      ),
      suffixIcon: IconButton(
        onPressed: () {
          showAlertDialogNotes(context);
        },
        icon: Icon(Icons.clear),
        color: Colors.black,
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.yellow),
      ),
    );
  }

  static Widget imageLoader(String content) {
    return StreamBuilder(
        stream: _contactService.getContactDetails(ContactDetails.contactDoc),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          // print('IMAGE : ' + snapshot.data[content]);
          return new SingleChildScrollView(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                snapshot.data[content],
                width: MediaQuery.of(context).size.width / 1.8,
                height: MediaQuery.of(context).size.width / 1.8,
              ),
            ],
          ));
        });
  }

  //FIRSTNAME EDITABLE CONTENT WIDGET
  static var firstnameController = TextEditingController();

  static Widget _firstnameEditable(String content) {
    return StreamBuilder(
        stream: _contactService.getContactDetails(ContactDetails.contactDoc),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          firstnameController.text = snapshot.data[content];
          return new SingleChildScrollView(
            child: new TextFormField(
              controller: firstnameController,
              validator: (value) =>
                  value.isEmpty ? "Last name cannot be empty" : null,
              style: _contentTextStyle(),
              decoration: _buildInputDecoration(firstnameController),
            ),
          );
        });
  }

  //LASTNAME EDITABLE CONTENT WIDGET
  static var lastNameController = TextEditingController();

  static Widget _lastnameEditable(String content) {
    return StreamBuilder(
        stream: _contactService.getContactDetails(ContactDetails.contactDoc),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          lastNameController.text = snapshot.data[content];
          return new SingleChildScrollView(
            child: new TextFormField(
              controller: lastNameController,
              validator: (value) =>
                  value.isEmpty ? "Last name cannot be empty" : null,
              style: _contentTextStyle(),
              decoration: _buildInputDecoration(lastNameController),
            ),
          );
        });
  }

  //INSTITUTION EDITABLE CONTENT WIDGET
  static var institutionController = TextEditingController();

  static Widget _institutionEditable(String content) {
    return StreamBuilder(
        stream: _contactService.getContactDetails(ContactDetails.contactDoc),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          institutionController.text = snapshot.data[content];
          return new SingleChildScrollView(
            child: new TextFormField(
              controller: institutionController,
              validator: (value) =>
                  value.isEmpty ? "Institution cannot be empty" : null,
              style: _contentTextStyle(),
              decoration: _buildInputDecoration(institutionController),
            ),
          );
        });
  }

  //NONE EDITABLE CONTENT WIDGET
  static Widget _contentNotEditable(String content) {
    return StreamBuilder(
        stream: _contactService.getContactDetails(ContactDetails.contactDoc),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          return new SingleChildScrollView(
            child: new TextFormField(
              enabled: false,
              validator: (value) =>
                  value.isEmpty ? "This field cannot be empty" : null,
              style: TextStyle(
                  color: Colors.grey, fontFamily: 'RadikalLight', fontSize: 20),
              decoration: new InputDecoration(
                hintText: snapshot.data[content],
              ),
            ),
          );
        });
  }

  //Build the textformfield decoration
  static InputDecoration _buildInputDecoration(
      TextEditingController controller) {
    return InputDecoration(
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyan)),
        hintStyle: TextStyle(color: Colors.grey),
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

  //Get image
  File imageFile;
  AsyncSnapshot docSnapshot;

  Future getImageFromGallery() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
  }

  //Get the image from storage
  Future<Widget> getImageFromFirestore(
      BuildContext context, String imageName, String docId) async {
    Image image;
    await FireStorageService.loadImage(context, imageName, docId).then((value) {
      image = Image.network(value.toString(), fit: BoxFit.scaleDown);
    });
    return image;
  }

  //Upload image
  Reference ref;

  Future uploadImage(String email, String docId) async {
    ref = FirebaseStorage.instance.ref().child("contacts/$email/$docId");
    ref.putFile(imageFile);
  }
}

//Helper class to get the image
class FireStorageService extends ChangeNotifier {
  FireStorageService();

  static Future<dynamic> loadImage(
      BuildContext context, String email, String docId) async {
    return await FirebaseStorage.instance
        .ref("contacts/$email/$docId")
        .getDownloadURL();
  }
}
