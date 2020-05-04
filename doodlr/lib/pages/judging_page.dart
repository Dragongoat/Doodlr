import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

enum SelectedMedal {
  NONE,
  BRONZE,
  SILVER,
  GOLD
}

class JudgingWidget extends StatefulWidget {

  @override
  _JudgingWidgetState createState() => _JudgingWidgetState();
}

class _JudgingWidgetState extends State<JudgingWidget> {

  SelectedMedal _selectedMedal = SelectedMedal.NONE;
  int _curBronze;
  int _curSilver;
  int _curGold;
  var _drawings = [
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black
  ];

  void _changeVote(index) {
    setState(() {
      switch (_selectedMedal) {
        case SelectedMedal.BRONZE:
          _drawings[index] = Colors.deepOrange;
          if (_curBronze != null) {
            _drawings[_curBronze] = Colors.black;
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
          _drawings[index] = Colors.grey;
          if (_curSilver != null) {
            _drawings[_curSilver] = Colors.black;
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
          _drawings[index] = Colors.amber;
          if (_curGold != null) {
            _drawings[_curGold] = Colors.black;
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
                _showDrawings(),
              ],
            ),
          ),
        )
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
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () => _changeVote(0),
                    child: Container(
                      child: SizedBox(height: 150.0,),
                      decoration: BoxDecoration(
                        border: Border.all(color: _drawings[0], width: (_drawings[0] == Colors.black) ? 2.0 : 4.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: _drawings[0],
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
                  ),
                ),
                SizedBox(width: 15.0,),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _changeVote(1),
                    child: Container(
                      child: SizedBox(height: 150.0,),
                      decoration: BoxDecoration(
                        border: Border.all(color: _drawings[1], width: (_drawings[1] == Colors.black) ? 2.0 : 4.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: _drawings[1],
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
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15.0,),
          FractionallySizedBox(
            widthFactor: 0.9,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () => _changeVote(2),
                    child: Container(
                      child: SizedBox(height: 150.0,),
                      decoration: BoxDecoration(
                        border: Border.all(color: _drawings[2], width: (_drawings[2] == Colors.black) ? 2.0 : 4.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: _drawings[2],
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
                  ),
                ),
                SizedBox(width: 15.0,),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _changeVote(3),
                    child: Container(
                      child: SizedBox(height: 150.0,),
                      decoration: BoxDecoration(
                        border: Border.all(color: _drawings[3], width: (_drawings[3] == Colors.black) ? 2.0 : 4.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: _drawings[3],
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
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15.0,),
          FractionallySizedBox(
            widthFactor: 0.9,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () => _changeVote(4),
                    child: Container(
                      child: SizedBox(height: 150.0,),
                      decoration: BoxDecoration(
                        border: Border.all(color: _drawings[4], width: (_drawings[4] == Colors.black) ? 2.0 : 4.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: _drawings[4],
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
                  ),
                ),
                SizedBox(width: 15.0,),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _changeVote(5),
                    child: Container(
                      child: SizedBox(height: 150.0,),
                      decoration: BoxDecoration(
                        border: Border.all(color: _drawings[5], width: (_drawings[5] == Colors.black) ? 2.0 : 4.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: _drawings[5],
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
                  ),
                ),
              ],
            ),
          ),
        ],
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
                            color: (_selectedMedal == SelectedMedal.BRONZE) ? Colors.green[100] : Colors.green[300],
                            shape: (_selectedMedal == SelectedMedal.BRONZE) ?
                            CircleBorder(
                              side: BorderSide(
                                  width: 1.0,
                                  color: Colors.deepOrange,
                              ),
                            ) : CircleBorder(),
                          ),
                          child: IconButton(
                            icon: Icon(FontAwesome5Solid.medal),
                            color: Colors.deepOrange,
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
                            color: (_selectedMedal == SelectedMedal.SILVER) ? Colors.green[100] : Colors.green[300],
                            shape: (_selectedMedal == SelectedMedal.SILVER) ?
                            CircleBorder(
                              side: BorderSide(
                                width: 1.0,
                                color: Colors.grey,
                              ),
                            ) : CircleBorder(),
                          ),
                          child: IconButton(
                            icon: Icon(FontAwesome5Solid.medal),
                            color: Colors.grey,
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
                            color: (_selectedMedal == SelectedMedal.GOLD) ? Colors.green[100] : Colors.green[300],
                            shape: (_selectedMedal == SelectedMedal.GOLD) ?
                            CircleBorder(
                              side: BorderSide(
                                width: 1.0,
                                color: Colors.amber,
                              ),
                            ) : CircleBorder(),
                          ),
                          child: IconButton(
                            icon: Icon(FontAwesome5Solid.medal),
                            color: Colors.amber,
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
                "1m 0s",
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

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _showPage(),
    );
  }
}