import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:schoolapp/components/register.dart';
import 'package:schoolapp/services/auth.dart';
import 'package:schoolapp/shared/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String error = "";

  @override
  Widget build(BuildContext context) {
    return isLoading ? Loading() : Scaffold(
      backgroundColor: Colors.grey[300],
        appBar: AppBar(title: Text("Login")),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
                child: Column(children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Enter Email Address",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter Email Address';
                        } else if (!value.contains('@')) {
                          return 'Please enter a valid email address!';
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
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child:  RaisedButton(
                      color: Colors.lightBlue,
                      onPressed: () async{
                        if (_formKey.currentState.validate()) {
                          //Show loading
                          setState(() {
                            isLoading = true;
                          });
                          SharedPreferences preferences = await SharedPreferences.getInstance();
                          preferences.setString("email", emailController.text);
                          dynamic result = await _auth.signInWithEmailAndPassword(emailController.text, passwordController.text);
                          if(result == null){
                            setState(() {
                              error = 'Could not sign in with those credentials';
                              isLoading = false;
                            });
                          } else {
                            //Go to home
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => Home()),
                            );
                          }
                        }
                      },
                      child: Text('Submit'),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child:  FlatButton(
                      color: Colors.white,
                      onPressed: () async{
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => Register()),
                            );
                        },
                      child: Text(
                          'Not registered yet clik here',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.0),
                  Text(
                    error,
                    style: TextStyle(color: Colors.red, fontSize: 14.0),
                  ),
                ]))));
  }


}