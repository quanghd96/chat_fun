import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat_fun/image.dart';
import 'package:chat_fun/login.dart';
import 'package:simple_moment/simple_moment.dart';

final DatabaseReference reference =
    FirebaseDatabase.instance.reference().child("message");

String _name, _avatar, _uid;
var moment = new Moment.now();
var _textController = new TextEditingController();

class Chat extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ChatState();
  }
}

class ChatState extends State<Chat> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((FirebaseUser user) {
      if (user == null) {
        Navigator.push(
            context, new MaterialPageRoute(builder: (context) => new Login()));
      } else {
        _uid = user.uid;
      }
    });
  }

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
              if (snapshot.value['id'] == _uid)
                return new ChatMessageRight(
                    snapshot: snapshot, animation: animation);
              else
                return new ChatMessageLeft(
                    snapshot: snapshot, animation: animation);
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
    await FirebaseAuth.instance.currentUser().then((FirebaseUser user) {
      if (user == null)
        Navigator.push(
            context, new MaterialPageRoute(builder: (context) => new Login()));
      else {
        _name = user.displayName;
        _avatar = user.photoUrl;
        _uid = user.uid;
      }
    });
    if (value.trim().length > 0)
      reference.push().set({
        'message': value,
        'senderName': _name,
        'senderAvatar': _avatar,
        'id': _uid,
        'timeSend': ServerValue.timestamp
      });
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
      'senderAvatar': _avatar,
      'id': _uid,
      'timeSend': ServerValue.timestamp
    });
  }
}

class ChatMessageLeft extends StatelessWidget {
  ChatMessageLeft({this.snapshot, this.animation});

  final Animation animation;

  final DataSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(right: 16.0, top: 15.0),
            child: new CircleAvatar(
              backgroundImage: new NetworkImage(snapshot.value['senderAvatar']),
            ),
          ),
          new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(snapshot.value['senderName'],
                  style: Theme.of(context).textTheme.subhead),
              new Text(moment.from(new DateTime.fromMillisecondsSinceEpoch(snapshot.value['timeSend'])),
                  style: Theme.of(context).textTheme.caption),
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
                                  builder: (context) =>
                                      new ImageView(snapshot.value['image'])));
                        },
                      )
                    : new Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: new BoxDecoration(
                            color: new Color.fromARGB(255, 39, 142, 139),
                            borderRadius: new BorderRadius.circular(15.0)),
                        child: new Text(
                          snapshot.value['message'],
                          style: new TextStyle(
                              color: new Color.fromARGB(255, 255, 255, 255)),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChatMessageRight extends StatelessWidget {
  ChatMessageRight({this.snapshot, this.animation});

  final Animation animation;

  final DataSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
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
                                  builder: (context) =>
                                      new ImageView(snapshot.value['image'])));
                        },
                      )
                    : new Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: new BoxDecoration(
                            color: new Color.fromARGB(255, 39, 142, 139),
                            borderRadius: new BorderRadius.circular(15.0)),
                        child: new Text(
                          snapshot.value['message'],
                          style: new TextStyle(
                              color: new Color.fromARGB(255, 255, 255, 255)),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
