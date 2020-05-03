import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doodlr/services/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileWidget extends StatefulWidget {
  ProfileWidget({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() {
    return ProfileWidgetState();
  }
}

class ProfileWidgetState extends State<ProfileWidget> {
  FirebaseUser _user;
  final _firestore = Firestore.instance;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  void getUser() async {
    var user = await widget.auth.getCurrentUser();
    setState(() {
      _user = user;
    });
  }

  Widget _showPage() {
    if (_user == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/colored_pencils_pixel.png"),
            fit: BoxFit.cover,
          ),
        ),
        constraints: BoxConstraints.expand(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 100.0, 20.0, 100.0),
            child: Card(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        _showAvatar(),
                        _showUsername(),
                      ],
                    ),
                  ),
                  Divider(),
                  Expanded(
                      child: _showStats()
                  ),
                ],
              ),
            ),
          )
        )
    );
  }

  Widget _showStats() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 25.0,
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  StreamBuilder(
                    stream: _firestore
                        .collection("users")
                        .document(_user.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Text("");
                      return Text(
                        snapshot.data["gamesPlayed"].toString(),
                        style: TextStyle(
                          fontSize: 25.0,
                          shadows: <Shadow>[
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 2.0,
                              color: Colors.grey,
                            )
                          ],
                        ),
                      );
                    }
                  ),
                  Text(
                    "games played",
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  StreamBuilder(
                      stream: _firestore
                          .collection("users")
                          .document(_user.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Text("");
                        return Text(
                          snapshot.data["goldMedals"].toString(),
                          style: TextStyle(
                            fontSize: 25.0,
                            color: Colors.amber,
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 2.0,
                                color: Colors.amber[900],
                              )
                            ],
                          ),
                        );
                      }
                  ),
                  Text(
                    "gold medals",
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 25.0,
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  StreamBuilder(
                      stream: _firestore
                          .collection("users")
                          .document(_user.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Text("");
                        return Text(
                          snapshot.data["silverMedals"].toString(),
                          style: TextStyle(
                            fontSize: 25.0,
                            color: Colors.grey,
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 2.0,
                                color: Colors.grey[900],
                              )
                            ],
                          ),
                        );
                      }
                  ),
                  Text(
                    "silver medals",
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  StreamBuilder(
                      stream: _firestore
                          .collection("users")
                          .document(_user.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Text("");
                        return Text(
                          snapshot.data["bronzeMedals"].toString(),
                          style: TextStyle(
                            fontSize: 25.0,
                            color: Colors.deepOrange,
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 2.0,
                                color: Colors.deepOrange[900],
                              )
                            ],
                          ),
                        );
                      }
                  ),
                  Text(
                    "bronze medals",
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _showUsername() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            _user.displayName,
            textAlign: TextAlign.left,
            style: TextStyle(
              shadows: <Shadow>[
                Shadow(
                  offset: Offset(1.0, 1.0),
                  blurRadius: 2.0,
                  color: Colors.grey,
                )
              ],
              fontSize: 20.0,
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          StreamBuilder(
              stream: _firestore
                  .collection("users")
                  .document(_user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Text("");
                return Text(
                  "Joined: " + DateFormat
                      .yMd()
                      .add_jm()
                      .format(snapshot
                              .data["joinDate"]
                              .toDate()
                              .toLocal())
                      .toString(),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 10.0,
                  ),
                );
              }
          ),
        ],
      ),
    );
  }

  Widget _showAvatar() {
    return Expanded(
      child: CircleAvatar(
        maxRadius: 80.0,
        minRadius: 40.0,
        backgroundImage: AssetImage("assets/profile_pic.jpg"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _showPage(),
    );
  }
}