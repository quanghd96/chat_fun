import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat_fun/image.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final DatabaseReference reference =
    FirebaseDatabase.instance.reference().child("message");

String _name;
String _avatar;
var _textController = new TextEditingController();

class Chat extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ChatState();
  }
}

class ChatState extends State<Chat> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("Chat room")),
      body: new Column(
        children: <Widget>[
          new Flexible(
              child: new FirebaseAnimatedList(
            query: reference,
            sort: (a, b) => b.key.compareTo(a.key),
            padding: new EdgeInsets.all(8.0),
            reverse: true,
            itemBuilder:
                (_, DataSnapshot snapshot, Animation<double> animation, int n) {
              return new ChatMessage(snapshot: snapshot, animation: animation);
            },
          )),
          new Divider(height: 1.0),
          new Container(
            decoration: new BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new IconButton(icon: new Icon(Icons.image), onPressed: _handlePick),
            new Flexible(
              child: new TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration:
                    new InputDecoration.collapsed(hintText: "Write message..."),
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
      ),
    );
  }

  void _handleSubmitted(String value) async {
    _textController.clear();
    await _auth.currentUser().then((FirebaseUser user) {
      _name = user.displayName;
      _avatar = user.photoUrl;
    });
    if (value.trim().length > 0)
      reference.push().set(
          {'message': value, 'senderName': _name, 'senderAvatar': _avatar});
  }

  void _handlePick() async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    int random = new Random().nextInt(100000);
    StorageReference ref =
        FirebaseStorage.instance.ref().child("image_$random.jpg");
    StorageUploadTask uploadTask = ref.putFile(imageFile);
    Uri downloadUrl = (await uploadTask.future).downloadUrl;
    reference.push().set({
      'image': downloadUrl.toString(),
      'senderName': _name,
      'senderAvatar': _avatar
    });
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage({this.snapshot, this.animation});

  final Animation animation;

  final DataSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: new CircleAvatar(
              backgroundImage: new NetworkImage(snapshot.value['senderAvatar']),
            ),
          ),
          new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(snapshot.value['senderName'],
                  style: Theme.of(context).textTheme.subhead),
              new Container(
                margin: const EdgeInsets.only(top: 5.0),
                child: snapshot.value['image'] != null
                    ? new GestureDetector(
                        child: new Image.network(
                          snapshot.value['image'],
                          width: 100.0,
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => new ImageView(snapshot.value['image'])));
                        },
                      )
                    : new Text(snapshot.value['message']),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
