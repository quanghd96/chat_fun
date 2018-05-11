import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Chat extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ChatState();
  }
}

class ChatState extends State<Chat> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text("Chat")),
        body: _buildTextComposer());
  }

  Widget _buildTextComposer() {
    var _textController = new TextEditingController();
    return new IconTheme(
      //new
      data: new IconThemeData(color: Theme.of(context).accentColor), //new
      child: new Container(
        //modified
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: new TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration:
                    new InputDecoration.collapsed(hintText: "Send a message"),
              ),
            ),
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: () => _handleSubmitted(_textController.text)),
            ),
          ],
        ),
      ), //new
    );
  }

  void _handleSubmitted(String value) {}
}
