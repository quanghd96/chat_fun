import 'dart:async';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter/material.dart';
import 'package:chat_fun/chat.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => new _LoginState();
}

class _LoginState extends State<Login> {
  static final FacebookLogin facebookSignIn = new FacebookLogin();

  Future<Null> _login() async {
    final FacebookLoginResult result =
        await facebookSignIn.logInWithReadPermissions(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        //login success
        final FirebaseUser user =
            await _auth.signInWithFacebook(accessToken: accessToken.token);
        assert(user.email != null);
        assert(user.displayName != null);
        assert(!user.isAnonymous);
        assert(await user.getIdToken() != null);

        final FirebaseUser currentUser = await _auth.currentUser();
        assert(user.uid == currentUser.uid);

        Navigator.pop(context);
        break;
      case FacebookLoginStatus.cancelledByUser:
        //cancell login
        break;
      case FacebookLoginStatus.error:
        // login fail
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Login'),
        ),
        body: new Center(
          child: new RaisedButton(
            onPressed: _login,
            child: new Text("Login with facebook"),
          ),
        ),
      ),
    );
  }
}
