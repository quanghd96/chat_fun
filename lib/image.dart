import 'package:flutter/material.dart';

class ImageView extends StatefulWidget {
  String imageUrl;

  ImageView(this.imageUrl);

  @override
  _ImageState createState() => new _ImageState(this.imageUrl);
}

class _ImageState extends State<ImageView> {
  String imageUrl;

  _ImageState(this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        body: new Center(
          child: new Image.network(imageUrl),
        ),
      ),
    );
  }
}
