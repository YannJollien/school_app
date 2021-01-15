import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:schoolapp/components/verifyEmail.dart';
import 'package:schoolapp/services/auth.dart';
import 'package:schoolapp/services/database.dart';
import 'package:schoolapp/shared/loading.dart';

//Inspiration https://github.com/PeterHdd/Firebase-Flutter-tutorials/blob/master/firebase_authentication_tutorial/lib/email_signup.dart

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  File imageFile;
  Reference ref;
  String downloadUrl;

  //Get image
  Future getImage() async {
    File image;
    image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageFile = image;
    });
  }

  //Upload image
  Future uploadImage(String email) async {
    ref = FirebaseStorage.instance.ref().child("images/$email");
    ref.putFile(imageFile);
    print("IMAGE PATH " + imageFile.path);
  }

  //Get image Url
  Future downloadImage() async {
    String downloadAddress = await ref.getDownloadURL();
    setState(() {
      downloadUrl = downloadAddress;
    });
  }

  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final databaseReference = Firestore.instance;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final AuthService _auth = AuthService();
  DatabaseService service = DatabaseService();
  String error = " ";
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String text = "No image";

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.grey[300],
            appBar: AppBar(title: Text("Sign Up")),
            body: Form(
                key: _formKey,
                child: SingleChildScrollView(
                    child: Column(children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Enter User Name",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter User Name';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Enter Email",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter an Email Address';
                        } else if (!value.contains('@')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: TextFormField(
                      obscureText: true,
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: "Enter Password",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter Password';
                        } else if (value.length < 6) {
                          return 'Password must be atleast 6 characters!';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20.0),
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
                                "TAp to add image",
                                style: TextStyle(color: Colors.grey[400]),
                              )
                            : Image.file(imageFile)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: RaisedButton(
                      color: Colors.lightBlue,
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          //Show Loading
                          setState(() {
                            isLoading = true;
                          });
                          dynamic result =
                              await _auth.registerWithEmailAndPassword(
                                  emailController.text,
                                  passwordController.text,
                                  nameController.text);
                          if (result == null) {
                            setState(() {
                              error = 'Please supply a valid email';
                              isLoading = false;
                            });
                          } else {
                            //Upload the image after the user is created (token access)
                            uploadImage(emailController.text);
                            downloadImage();

                            //Go to verification
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VerifyScreen()),
                            );
                          }
                        }
                      },
                      child: Text('Submit'),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    error,
                    style: TextStyle(color: Colors.red, fontSize: 14.0),
                  ),
                ]))));
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }
}
