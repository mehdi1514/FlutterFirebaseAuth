import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertestingapp/register.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Testing',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key,}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<FirebaseUser> getUser() async{
    return await _auth.currentUser();
  }

  @override
  void initState(){
    super.initState();
    getUser().then((user){
      if(user != null){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home(user.displayName)));
      }
    });
  }

  Future<FirebaseUser> _signIn() async {
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth =
        await googleSignInAccount.authentication;
    AuthCredential authCredential = GoogleAuthProvider.getCredential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    FirebaseUser user = (await _auth.signInWithCredential(authCredential)).user;
    print("user display name:  ${user.displayName}");
    return user;
  }

  Future<FirebaseUser> handleSignInEmail(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      print(_auth.currentUser());
      assert(user != null);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      return user;
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firebase Testing"),
      ),
      body: Container(
        child: Center(
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          } else if (!(value.contains("@"))) {
                            return "Invalid email id";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          } else if (value.length < 6) {
                            return "Password should contain atleast 6 characters";
                          }
                          return null;
                        },
                      ),
                      RaisedButton(
                        color: Colors.blue,
                        splashColor: Colors.blueAccent,
                        onPressed: () {
                          // Validate returns true if the form is valid, otherwise false.
                          if (_formKey.currentState.validate()) {
                            handleSignInEmail(_emailController.text,
                                    _passwordController.text)
                                .then((user) {
                                  if(user!=null){
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Home(user.displayName)));
                                  }else{
                                    showDialog(
                                      context: context,
                                      builder: (context){
                                        return AlertDialog(
                                          title: Text("Invalid email or password!"),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text("Ok"),
                                              onPressed: () => Navigator.pop(context),
                                            )
                                          ],
                                        );
                                      }
                                    );
                                  }

                            }).catchError((e) => print(e));
                          }
                        },
                        child: Text('Sign In', style: TextStyle(color: Colors.white),),
                      )
                    ],
                  ),
                ),
              ),
              RaisedButton(
                elevation: 3.0,
                shape: StadiumBorder(),
                onPressed: () {
                  _signIn().then((user) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Home(user.displayName)));
                  }).catchError((e) => print(e));
                },
                color: Colors.red,
                splashColor: Colors.redAccent,
                child: Text(
                  "Sign in with Google",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: Center(
                  child: GestureDetector(
                    onTap: (){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                    },
                    child: Text(
                      "Create an account",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
