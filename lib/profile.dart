import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_fun/login.dart';

var _uid, _photoUrl, _name;
var _auth = FirebaseAuth.instance;

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => new _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    super.initState();

    _auth.currentUser().then((FirebaseUser user) {
      if (user != null) {
        _uid = user.uid;
        _photoUrl = user.photoUrl;
        _name = user.displayName;
      } else
        Navigator.push(
            context, new MaterialPageRoute(builder: (context) => new Login()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: new Text("My profile"),
          ),
          body: new Row(
            children: <Widget>[
              new CircleAvatar(
                backgroundImage: new NetworkImage(_photoUrl),
              )
            ],
          )),
    );
  }
}
