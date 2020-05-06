import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResultsWidget extends StatefulWidget {
  ResultsWidget({this.auth, this.onPlayAgain});

  final onPlayAgain;
  final auth;

  @override
  _ResultsWidgetState createState() => _ResultsWidgetState();
}

class _ResultsWidgetState extends State<ResultsWidget> {
  final _firestore = Firestore.instance;
  FirebaseUser _user;
  Timer _refreshTimer;
  bool _awardedMedal = false;
  String _goldWinner = "Gold";
  String _goldDrawing;
  String _silverWinner = "Silver";
  String _silverDrawing;
  String _bronzeWinner = "Bronze";
  String _bronzeDrawing;

  @override
  void initState() {
    super.initState();
    getUser();
    _refreshTimer = Timer.periodic(Duration(seconds: 5), (Timer t) => getWinners());
    getWinners();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void getUser() async {
    var user = await widget.auth.getCurrentUser();
    setState(() {
      _user = user;
    });
  }

  void getWinners() async {
    DocumentSnapshot doc = await _firestore
        .collection("votes")
        .document("vote_counts")
        .get()
        .catchError((e) => print("Firestore error: $e"));
    var goldVotes = 0;
    var silverVotes = 0;
    var bronzeVotes = 0;
    var goldUser = "";
    var silverUser = "";
    var bronzeUser = "";
    if (doc.data != null && doc.data.containsKey(_user.displayName)) {
      doc.data?.forEach((key, value) {
        if (value > goldVotes) {
          bronzeUser = silverUser;
          bronzeVotes = silverVotes;
          silverUser = goldUser;
          silverVotes = goldVotes;
          goldUser = key;
          goldVotes = value;
        }
        else if (value > silverVotes) {
          bronzeUser = silverUser;
          bronzeVotes = silverVotes;
          silverUser = key;
          silverVotes = value;
        }
        else if (value > bronzeVotes) {
          bronzeUser = key;
          bronzeVotes = value;
        }
      });

      setState(() {
        if (goldUser != "") {
          _goldWinner = goldUser;
        }
        if (silverUser != "") {
          _silverWinner = silverUser;
        }
        if (bronzeUser != "") {
          _bronzeWinner = bronzeUser;
        }
      });

      // Get the three winning drawings
      DocumentSnapshot goldDoc = await _firestore
          .collection("drawings")
          .document(_goldWinner)
          .get()
          .catchError((e) => print("Firestore error: $e"));
      DocumentSnapshot silverDoc = await _firestore
          .collection("drawings")
          .document(_silverWinner)
          .get()
          .catchError((e) => print("Firestore error: $e"));
      DocumentSnapshot bronzeDoc = await _firestore
          .collection("drawings")
          .document(_bronzeWinner)
          .get()
          .catchError((e) => print("Firestore error: $e"));
      setState(() {
        _goldDrawing =
        (goldDoc.data == null) ? null : goldDoc.data["drawingLink"];
        _silverDrawing =
        (silverDoc.data == null) ? null : silverDoc.data["drawingLink"];
        _bronzeDrawing =
        (bronzeDoc.data == null) ? null : bronzeDoc.data["drawingLink"];
      });

      if (_awardedMedal == false) {
        if (_goldWinner == _user.displayName) {
          DocumentSnapshot doc = await _firestore
              .collection("users")
              .document(_user.uid)
              .get();

          var curGoldMedals = doc.data["goldMedals"];
          await _firestore
              .collection("users")
              .document(_user.uid)
              .updateData({
            "goldMedals": curGoldMedals + 1,
          });
          _awardedMedal = true;
        }
        else if (_silverWinner == _user.displayName) {
          DocumentSnapshot doc = await _firestore
              .collection("users")
              .document(_user.uid)
              .get();

          var curSilverMedals = doc.data["silverMedals"];
          await _firestore
              .collection("users")
              .document(_user.uid)
              .updateData({
            "silverMedals": curSilverMedals + 1,
          });
          _awardedMedal = true;
        }
        else if (_bronzeWinner == _user.displayName) {
          DocumentSnapshot doc = await _firestore
              .collection("users")
              .document(_user.uid)
              .get();

          var curBronzeMedals = doc.data["bronzeMedals"];
          await _firestore
              .collection("users")
              .document(_user.uid)
              .updateData({
            "bronzeMedals": curBronzeMedals + 1,
          });
          _awardedMedal = true;
        }
      }
    }
  }

  Widget _showInfoBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: FractionallySizedBox(
        widthFactor: 0.9,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2.0),
            color: Colors.green[300],
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 10.0,
                spreadRadius: 1.0,
                offset: Offset(
                  5.0,
                  5.0,
                ),
              )
            ],
          ),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 5),
              Text(
                "Results will load as users vote",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showResults() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
      child: Column(
        children: <Widget>[
          FractionallySizedBox(
            widthFactor: 0.9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.width * 0.4,
                      child: (_goldDrawing == null) ? Center(child: CircularProgressIndicator(),) : Image.network(_goldDrawing),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.amber, width: 2.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber,
                            blurRadius: 10.0,
                            spreadRadius: 1.0,
                            offset: Offset(
                              5.0,
                              5.0,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10.0,),
          FractionallySizedBox(
            widthFactor: 0.9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: AutoSizeText(
                      _goldWinner,
                      maxLines: 1,
                      textAlign: TextAlign.center,
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
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15.0),
          FractionallySizedBox(
            widthFactor: 0.9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: MediaQuery.of(context).size.width * 0.4,
                        child: (_silverDrawing == null) ? Center(child: CircularProgressIndicator(),) : Image.network(_silverDrawing),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 2.0),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 10.0,
                              spreadRadius: 1.0,
                              offset: Offset(
                                5.0,
                                5.0,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: MediaQuery.of(context).size.width * 0.4,
                        child: (_bronzeDrawing == null) ? Center(child: CircularProgressIndicator(),) : Image.network(_bronzeDrawing),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.deepOrange, width: 2.0),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepOrange,
                              blurRadius: 10.0,
                              spreadRadius: 1.0,
                              offset: Offset(
                                5.0,
                                5.0,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.0,),
          FractionallySizedBox(
            widthFactor: 0.9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: AutoSizeText(
                      _silverWinner,
                      maxLines: 1,
                      textAlign: TextAlign.center,
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
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: AutoSizeText(
                      _bronzeWinner,
                      maxLines: 1,
                      textAlign: TextAlign.center,
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
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _showPlayAgain() {
    return RaisedButton(
      onPressed: () {
        widget.onPlayAgain();
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
            'Play again',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _showPage() {
    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/colored_pencils_pixel.png"),
            fit: BoxFit.cover,
          ),
        ),
        constraints: BoxConstraints.expand(),
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _showInfoBox(),
                _showResults(),
                _showPlayAgain(),
              ],
            ),
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _showPage(),
    );
  }
}