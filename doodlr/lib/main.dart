import 'package:flutter/material.dart';
import 'package:doodlr/services/authentication.dart';
import 'package:doodlr/pages/root_page.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Flutter login demo',
//        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primarySwatch: Colors.blue,
          accentColor: Colors.blueAccent,
        ),
        debugShowCheckedModeBanner: false,
        home: new RootPage(auth: new Auth()));
  }
}