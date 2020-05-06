import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum SelectedMedal {
  NONE,
  BRONZE,
  SILVER,
  GOLD
}

class JudgingWidget extends StatefulWidget {
  JudgingWidget({this.auth, this.onResultsRound, this.onReturnHome});

  final onResultsRound;
  final onReturnHome;
  final auth;

  @override
  _JudgingWidgetState createState() => _JudgingWidgetState();
}

class _JudgingWidgetState extends State<JudgingWidget> {
  final _firestore = Firestore.instance;
  SelectedMedal _selectedMedal = SelectedMedal.NONE;
  int _curBronze;
  int _curSilver;
  int _curGold;
  var _drawingBorders = [
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black
  ];
  List<JudgingDrawing> _drawings = [];
  Timer _timer;
  String _subject;
  DateTime _countdownTime;
  int _timeDiffMin = 0;
  int _timeDiffSec = 0;
  bool _roundRedirect = false;
  FirebaseUser _user;

  void getData() async {
    final response = await http.get('https://doodlr.org/judging/data/');

    if (response.statusCode == 200) {
      Map<String, dynamic> data= json.decode(response.body);
      setState(() {
        _subject = data['subject'];
        _countdownTime = DateTime.parse(data['timer']);
        getTimeDiff();
      });
    }
  }

  void getUser() async {
    var user = await widget.auth.getCurrentUser();
    setState(() {
      _user = user;
    });
  }

  void getDrawings() async {
    QuerySnapshot querySnapshot = await Firestore.instance.collection("drawings").getDocuments();
    FirebaseUser user = await widget.auth.getCurrentUser();
    var docList = querySnapshot.documents;
    List<String> userList = [];
    int group = 0;
    docList.forEach((e) => userList.add(e.documentID));

    if (userList.contains(user.displayName)) {
      group = await getJudgingGroup();
      for (var i = (group * 6); i < docList.length && i <= ((group + 1) * 6); i++) {
        if (docList[i].documentID != user.displayName) {
          var tmpDrawing = JudgingDrawing(
            drawingLink: docList[i].data["drawingLink"],
            user: docList[i].data["user"],
          );
          setState(() {
            _drawings.add(tmpDrawing);
          });
        }
      }
    }
  }

  Future<int> getJudgingGroup() async {
    QuerySnapshot querySnapshot = await Firestore.instance.collection("drawings").getDocuments();
    FirebaseUser user = await widget.auth.getCurrentUser();
    var docList = querySnapshot.documents;
    var userList = List<String>();
    docList.forEach((e) => userList.add(e.documentID));

    int group = 0;
    for (var i = 0; i < docList.length; i++) {
      if (docList[i].documentID == user.displayName) {
        group = (i ~/ 6);
        break;
      }
    }

    return group;
  }

  void getTimeDiff() {
    Duration difference = _countdownTime.difference(DateTime.now().toUtc());
    setState(() {
      _timeDiffMin = difference.inSeconds < 0 ? 0 : difference.inMinutes;
      _timeDiffSec = difference.inSeconds < 0 ? 0 : difference.inSeconds - (difference.inMinutes * 60);
      if (difference.inSeconds < 0 && !_roundRedirect) {
        _roundRedirect = true;
        widget.onReturnHome();
      }
    });
  }

  void _clearVotes() {
    setState(() {
      for (var i = 0; i < _drawingBorders.length; i++) {
        _drawingBorders[i] = Colors.black;
      }
      _curBronze = null;
      _curSilver = null;
      _curGold = null;
    });
  }

  void _changeVote(index) {
    setState(() {
      switch (_selectedMedal) {
        case SelectedMedal.BRONZE:
          _drawingBorders[index] = Colors.deepOrange;
          if (_curBronze != null) {
            _drawingBorders[_curBronze] = Colors.black;
          }
          if (_curSilver == index) {
            _curSilver = null;
          }
          if (_curGold == index) {
            _curGold = null;
          }
          _curBronze = index;
          break;
        case SelectedMedal.SILVER:
          _drawingBorders[index] = Colors.grey;
          if (_curSilver != null) {
            _drawingBorders[_curSilver] = Colors.black;
          }
          if (_curBronze == index) {
            _curBronze = null;
          }
          if (_curGold == index) {
            _curGold = null;
          }
          _curSilver = index;
          break;
        case SelectedMedal.GOLD:
          _drawingBorders[index] = Colors.amber;
          if (_curGold != null) {
            _drawingBorders[_curGold] = Colors.black;
          }
          if (_curBronze == index) {
            _curBronze = null;
          }
          if (_curSilver == index) {
            _curSilver = null;
          }
          _curGold = index;
          break;
        case SelectedMedal.NONE:
          break;
      }
    });
  }

  void _submitVotes() {
    if(_drawings.length == 1 && _curGold == null) {
      _displayVotingError('Please assign the gold medal to a drawing before submitting.');
      return;
    }
    else if (_drawings.length == 2 && (_curGold == null || _curSilver == null)) {
      _displayVotingError("Please assign the gold and silver medals to a drawing before submitting.");
      return;
    }
    else if (_drawings.length >= 3 && (_curGold == null || _curSilver == null || _curBronze ==  null)) {
      _displayVotingError("Please assign all medals to a drawing before submitting.");
      return;
    }
    else if (_drawings.length != 0) {
      if (_curSilver == null) {
        final TransactionHandler createTransaction = (Transaction tx) async {
          final DocumentSnapshot docRef = await tx.get(_firestore.collection("votes").document("vote_counts"));
          final curGoldUser = _drawings[_curGold].user;
          final curGoldCount = docRef.data.containsKey(curGoldUser) ? docRef.data[curGoldUser] : 0;
          final Map<String, dynamic> data = {
            curGoldUser: curGoldCount + 5,
          };
          await tx.update(docRef.reference, data);

          return data;
        };
        _firestore.runTransaction(createTransaction);
      } else if (_curBronze == null) {
        final TransactionHandler createTransaction = (Transaction tx) async {
          final DocumentSnapshot docRef = await tx.get(_firestore.collection("votes").document("vote_counts"));
          final curGoldUser = _drawings[_curGold].user;
          final curGoldCount = docRef.data.containsKey(curGoldUser) ? docRef.data[curGoldUser] : 0;
          final curSilverUser = _drawings[_curSilver].user;
          final curSilverCount = docRef.data.containsKey(curSilverUser) ? docRef.data[curSilverUser] : 0;
          final Map<String, dynamic> data = {
            curGoldUser: curGoldCount + 5,
            curSilverUser: curSilverCount + 3,
          };
          await tx.update(docRef.reference, data);

          return data;
        };
        _firestore.runTransaction(createTransaction);
      } else {
        final TransactionHandler createTransaction = (Transaction tx) async {
          final DocumentSnapshot docRef = await tx.get(_firestore.collection("votes").document("vote_counts"));
          final curGoldUser = _drawings[_curGold].user;
          final curGoldCount = docRef.data.containsKey(curGoldUser) ? docRef.data[curGoldUser] : 0;
          final curSilverUser = _drawings[_curSilver].user;
          final curSilverCount = docRef.data.containsKey(curSilverUser) ? docRef.data[curSilverUser] : 0;
          final curBronzeUser = _drawings[_curBronze].user;
          final curBronzeCount = docRef.data.containsKey(curBronzeUser) ? docRef.data[curBronzeUser] : 0;
          final Map<String, dynamic> data = {
            curGoldUser: curGoldCount + 5,
            curSilverUser: curSilverCount + 3,
            curBronzeUser: curBronzeCount + 1,
          };
          await tx.update(docRef.reference, data);

          return data;
        };
        _firestore.runTransaction(createTransaction);
      }
      widget.onResultsRound();
    }
  }

  void _displayVotingError(message) {
    showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Voting Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getData();
    getUser();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => getTimeDiff());
    getDrawings();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _showPage() {
    if (_subject == null || _countdownTime == null || _user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text("Loading game data..."),
            ),
            CircularProgressIndicator(),
          ],
        ),
      );
    }
    return Stack(
      children: <Widget>[
        Container(
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
                    _showDrawings(),
                  ],
                ),
              ),
            )
        ),
        (_roundRedirect) ? Center(
          child: CircularProgressIndicator(),
        ) : Container(),
      ]
    );
  }

  Widget _showDrawings() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
      child: Column(
        children: <Widget>[
          FractionallySizedBox(
            widthFactor: 0.9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _showDrawingBox(0),
                _showDrawingBox(1),
              ],
            ),
          ),
          SizedBox(height: 15.0,),
          FractionallySizedBox(
            widthFactor: 0.9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _showDrawingBox(2),
                _showDrawingBox(3),
              ],
            ),
          ),
          SizedBox(height: 15.0,),
          FractionallySizedBox(
            widthFactor: 0.9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _showDrawingBox(4),
                _showDrawingBox(5),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _showDrawingBox(index) {
    if (_drawings.length <= index) {
      return Container();
    }
    return GestureDetector(
      onTap: () => _changeVote(index),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.width * 0.4,
        child: Image.network(_drawings[index].drawingLink),
        decoration: BoxDecoration(
          border: Border.all(color: _drawingBorders[index], width: (_drawingBorders[index] == Colors.black) ? 2.0 : 4.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: _drawingBorders[index],
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
    );
  }

  Widget _showClearVotes() {
    return RaisedButton(
      onPressed: () {
        _clearVotes();
      },
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(80.0)
      ),
      padding: EdgeInsets.all(0.0),
      child: Ink(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red,
                Colors.redAccent
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30.0)
        ),
        child: Container(
          constraints: BoxConstraints(
              maxWidth: 300.0,
              minHeight: 40.0
          ),
          alignment: Alignment.center,
          child: Text(
            'Clear Selection',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _showSubmit() {
    return RaisedButton(
      onPressed: () => _submitVotes(),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(80.0)
      ),
      padding: EdgeInsets.all(0.0),
      child: Ink(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green,
                Colors.green[400]
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30.0)
        ),
        child: Container(
          constraints: BoxConstraints(
              maxWidth: 300.0,
              minHeight: 40.0
          ),
          alignment: Alignment.center,
          child: Text(
            'Submit',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _showInfoBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: FractionallySizedBox(
        widthFactor: 0.9,
        child: Container(
          padding: EdgeInsets.only(left: 50.0, right: 50.0),
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
                "Subject: house",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              Text("Tap a medal to assign it to a drawing:"),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ClipOval(
                    child: Material(
                      color: Colors.lightBlueAccent[100],
                      child: Center(
                        child: Ink(
                          decoration: ShapeDecoration(
                            color: (_selectedMedal == SelectedMedal.BRONZE) ? Colors.deepOrange : Colors.green[300],
                            shape: CircleBorder(),
                          ),
                          child: IconButton(
                            icon: Icon(FontAwesome5Solid.medal),
                            color: (_selectedMedal == SelectedMedal.BRONZE) ? Colors.white : Colors.deepOrange,
                            onPressed: () {
                              setState(() {
                                _selectedMedal = SelectedMedal.BRONZE;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  ClipOval(
                    child: Material(
                      color: Colors.lightBlueAccent[100],
                      child: Center(
                        child: Ink(
                          decoration: ShapeDecoration(
                            color: (_selectedMedal == SelectedMedal.SILVER) ? Colors.grey : Colors.green[300],
                            shape: CircleBorder(),
                          ),
                          child: IconButton(
                            icon: Icon(FontAwesome5Solid.medal),
                            color: (_selectedMedal == SelectedMedal.SILVER) ? Colors.white : Colors.grey,
                            onPressed: () {
                              setState(() {
                                _selectedMedal = SelectedMedal.SILVER;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  ClipOval(
                    child: Material(
                      color: Colors.lightBlueAccent[100],
                      child: Center(
                        child: Ink(
                          decoration: ShapeDecoration(
                            color: (_selectedMedal == SelectedMedal.GOLD) ? Colors.amber : Colors.green[300],
                            shape: CircleBorder(),
                          ),
                          child: IconButton(
                            icon: Icon(FontAwesome5Solid.medal),
                            color: (_selectedMedal == SelectedMedal.GOLD) ? Colors.white : Colors.amber,
                            onPressed: () {
                              setState(() {
                                _selectedMedal = SelectedMedal.GOLD;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text("Time Remaining:"),
              Text(
                "${_timeDiffMin}m ${_timeDiffSec}s",
                style: TextStyle(
                  fontSize: 20,
                  color: (_timeDiffMin == 0 && _timeDiffSec < 30) ? Colors.red : Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              _showClearVotes(),
              _showSubmit(),
              const SizedBox(height: 5),
            ],
          ),
        ),
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

class JudgingDrawing {
  String drawingLink;
  String user;
  JudgingDrawing({this.drawingLink, this.user});
}