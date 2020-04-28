import 'package:flutter/material.dart';

class HomeWidget extends StatefulWidget {
  HomeWidget({this.onStartGame});

  final onStartGame;

  @override
  State<StatefulWidget> createState() {
    return HomeWidgetState();
  }
}

class HomeWidgetState extends State<HomeWidget> {

  @override
  void initState() {
    super.initState();
  }

  Widget _showHome() {
    return Container(
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
                Text(
                  'Welcome to Doodlr!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 62.0,
                    color: Colors.white,
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(3.0, 3.0),
                        blurRadius: 2.0,
                        color: Colors.black,
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 150.0,
                ),
                RaisedButton(
                  onPressed: () {
                    widget.onStartGame();
                  },
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
                      child: Text(
                        'Enter public game',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
      return _showHome();
  }
}