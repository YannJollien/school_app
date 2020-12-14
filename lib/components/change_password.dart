import 'package:flutter/material.dart';
import 'package:schoolapp/services/auth.dart';

class Password extends StatefulWidget {
  @override
  _PasswordState createState() => _PasswordState();
}

class _PasswordState extends State<Password> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController passwordController1 = TextEditingController();
  TextEditingController passwordController2 = TextEditingController();
  AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
        appBar: AppBar(title: Text("Sign Up")),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
                child: Column(children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: TextFormField(
                      obscureText: true,
                      controller: passwordController1,
                      decoration: InputDecoration(
                        labelText: "Enter new password",
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
                    child: TextFormField(
                      obscureText: true,
                      controller: passwordController2,
                      decoration: InputDecoration(
                        labelText: "Repeate new password",
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
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: RaisedButton(
                      color: Colors.lightBlue,
                      onPressed: () async{
                         _auth.changePassword(passwordController1.text, passwordController2.text);
                         Navigator.of(context).pushNamed("/opening");
                      },
                      child: Text('Submit'),
                    ),
                  ),
                ]))));;
  }
}
