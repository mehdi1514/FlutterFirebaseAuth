import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertestingapp/main.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Home extends StatelessWidget {
  final String user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  void signOut(BuildContext context) async{
    await _auth.signOut().then((val) => print("signed out"));
    await googleSignIn.signOut().then((val) => print("signed out"));
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage()));
  }
  Home(this.user);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home"),),
      body: Container(
        child: Center(
          child: RaisedButton(
            shape: StadiumBorder(),
            onPressed: () => signOut(context),
            child: Text("$user : Sign Out", style: TextStyle(color: Colors.white),),
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}