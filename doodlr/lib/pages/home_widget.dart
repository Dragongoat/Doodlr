import 'package:flutter/material.dart';
import 'package:doodlr/services/authentication.dart';
import 'package:doodlr/pages/home_page.dart';
import 'package:doodlr/pages/placeholder_widget.dart';

class Home extends StatefulWidget {
  Home({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  int _currentIndex = 0;
  String _currentPageTitle;

  final List<Widget> _children = [
    HomeWidget(),
    PlaceholderWidget(Colors.lightBlue, "My Profile"),
    PlaceholderWidget(Colors.pink, "Leaderboard"),
    PlaceholderWidget(Colors.green, "How to Play"),
  ];

  @override
  void initState() {
    super.initState();
    _currentPageTitle = "Doodlr Home";
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  Widget _showDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).accentColor
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Text(
              'Doodlr Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 0;
                _currentPageTitle = 'Home';
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('My Profile'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 1;
                _currentPageTitle = 'My Profile';
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.assessment),
            title: Text('Leaderboard'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 2;
                _currentPageTitle = 'Leaderboard';
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('How to Play'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 3;
                _currentPageTitle = 'How to Play';
              });
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPageTitle),
        actions: <Widget>[
          FlatButton(
              child: Text('Logout',
                  style: TextStyle(
                      fontSize: 17.0,
                      color: Colors.white
                  )
              ),
              onPressed: signOut
          )
        ],
      ),
      drawer: _showDrawer(),
      body: _children[_currentIndex],
    );
  }
}
