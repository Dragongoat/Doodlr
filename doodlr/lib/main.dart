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
        title: 'Flutter login',
        theme: new ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.lightBlue,
          accentColor: Colors.lightBlueAccent,
        ),
        darkTheme: new ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.blue,
          accentColor: Colors.blueAccent,
        ),
        debugShowCheckedModeBanner: false,
        home: new RootPage(auth: new Auth()));
  }
}