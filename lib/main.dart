import 'package:flutter/material.dart';

import 'package:chat_fun/login.dart';

void main() {
  runApp(new MaterialApp(
    title: 'Navigation Basics',
    home: new MyApp(),
  ));
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new Login();
  }
}
