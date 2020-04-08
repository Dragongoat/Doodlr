import 'package:flutter/material.dart';
import 'package:doodlr/services/authentication.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Doodlr Home'),
        actions: <Widget>[
          new FlatButton(
              child: new Text('Logout',
                  style: new TextStyle(
                      fontSize: 17.0,
                      color: Colors.white
                  )
              ),
              onPressed: signOut
          )
        ],
      ),
      drawer: Drawer(
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
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('My Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.assessment),
              title: Text('Leaderboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('How to Play'),
              onTap: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/img_colored_pencils_pixel.png"),
            fit: BoxFit.cover,
          ),
        ),
        constraints: BoxConstraints.expand(),
        child: Center(
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 100.0,
                ),
                Stack(
                  children: <Widget>[
                    Text(
                      'Welcome to Doodlr!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 72.0,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 3.0
                          ..color = Colors.black,
                      ),
                    ),
                    Text(
                      'Welcome to Doodlr!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 72.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 150.0,
                ),
                RaisedButton(
                  onPressed: () {},
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80.0)
                  ),
                  padding: EdgeInsets.all(0.0),
                  child: Ink(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).accentColor
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(30.0)
                    ),
                    child: Container(
                      constraints: BoxConstraints(
                          maxWidth: 300.0,
                          minHeight: 60.0
                      ),
                      alignment: Alignment.center,
                      child: Stack(
                        children: <Widget>[
                          Text(
                            'Enter public game',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30.0,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 1.0
                                ..color = Colors.black,
                            ),
                          ),
                          Text(
                            'Enter public game',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30.0,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
        )
      ),
    );
  }
}
