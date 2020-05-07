// Code adapted from this medium article: https://medium.com/flutter-community/drawing-in-flutter-using-custompainter-307a9f1c21f8
import 'dart:async';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class Draw extends StatefulWidget {
  Draw({this.auth, this.onJudgingRound});

  final auth;
  final onJudgingRound;

  @override
  _DrawState createState() => _DrawState();
}

class _DrawState extends State<Draw> {
  final _firestore = Firestore.instance;
  Color _selectedColor = Colors.black;
  Color _pickerColor = Colors.black;
  double _strokeWidth = 3.0;
  List<DrawingPoints> _points = List();
  double _opacity = 1.0;
  StrokeCap _strokeCap = StrokeCap.round;
  SelectedMode _selectedMode = SelectedMode.Color;
  List<Color> _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.amber,
    Colors.black,
    Colors.white
  ];
  Timer _timer;
  String _subject;
  DateTime _countdownTime;
  int _timeDiffMin = 0;
  int _timeDiffSec = 0;
  bool _roundRedirect = false;
  FirebaseUser _user;

  void getData() async {
    final response = await http.get('https://doodlr.org/public/data/');

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

  void getTimeDiff() {
    if (_countdownTime != null) {
      Duration difference = _countdownTime.difference(DateTime.now().toUtc());
      setState(() {
        _timeDiffMin = difference.inSeconds < 0 ? 0 : difference.inMinutes;
        _timeDiffSec = difference.inSeconds < 0 ? 0 : difference.inSeconds -
            (difference.inMinutes * 60);
        if (difference.inSeconds < 0 && !_roundRedirect) {
          _roundRedirect = true;
          saveAndSendDrawing();
        }
      });
    }
  }

  void saveAndSendDrawing() async {
    String result = await _saveDrawing(_user.uid);
    await _firestore.collection("drawings")
        .document(_user.displayName)
        .setData(
        {
          'drawingLink' : result,
          'user' : _user.displayName,
        });
    widget.onJudgingRound();
  }

  Future<String> _saveDrawing(String imageId) async {
    PictureRecorder recorder = PictureRecorder();
    Canvas canvas = Canvas(recorder);
    DrawingPainter painter = DrawingPainter(pointsList: _points);
    var size = Size(MediaQuery.of(context).size.width * 0.9, MediaQuery.of(context).size.width * 0.9);
    painter.paint(canvas, size);
    final img = await recorder.endRecording().toImage(size.width.floor(), size.height.floor());

    final pngBytes = await img.toByteData(format: ImageByteFormat.png);
    StorageReference ref =
    FirebaseStorage.instance.ref().child("drawings").child("$imageId.png");
    StorageUploadTask uploadTask = ref.putData(pngBytes.buffer.asUint8List(pngBytes.offsetInBytes, pngBytes.lengthInBytes));
    return await (await uploadTask.onComplete).ref.getDownloadURL();
  }

  @override
  void initState() {
    super.initState();
    getData();
    getUser();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => getTimeDiff());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _showPage();
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
          child: Column(
            children: [
              _showInfoBox(),
              _showCanvas(),
              _showTools(),
            ],
          )
        ),
        (_roundRedirect) ? Center(
          child: CircularProgressIndicator(),
        ) : Container(),
      ]
    );
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
                "You are drawing: $_subject",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Time Remaining:",
              ),
              Text(
                "${_timeDiffMin}m ${_timeDiffSec}s",
                style: TextStyle(
                  fontSize: 20,
                  color: (_timeDiffMin == 0 && _timeDiffSec < 30) ? Colors.red : Colors.black,
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showCanvas() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2.0),
          color: Colors.white,
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
        child: GestureDetector(
          onPanUpdate: (details) {
            if (!_roundRedirect) {
              setState(() {
                double boxSize = MediaQuery.of(context).size.width * 0.9;
                Offset touchPosition = details.localPosition;
                if (touchPosition.dx < 0 || touchPosition.dy < 0 ||
                    touchPosition.dx > boxSize || touchPosition.dy > boxSize) {
                  _points.add(null);
                }
                else {
                  _points.add(DrawingPoints(
                      points: details.localPosition,
                      paint: Paint()
                        ..strokeCap = _strokeCap
                        ..isAntiAlias = true
                        ..color = _selectedColor.withOpacity(_opacity)
                        ..strokeWidth = _strokeWidth));
                }
              });
            }
          },
          onPanStart: (details) {
            if (!_roundRedirect) {
              setState(() {
                _points.add(DrawingPoints(
                    points: details.localPosition,
                    paint: Paint()
                      ..strokeCap = _strokeCap
                      ..isAntiAlias = true
                      ..color = _selectedColor.withOpacity(_opacity)
                      ..strokeWidth = _strokeWidth));
              });
            }
          },
          onPanEnd: (details) {
            setState(() {
              _points.add(null);
            });
          },
          child: ClipRect(
            child: CustomPaint(
              size: Size.square(MediaQuery.of(context).size.width * 0.9),
              painter: DrawingPainter(
                pointsList: _points,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _showTools() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      child: FractionallySizedBox(
        widthFactor: 0.9,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2.0),
            color: Colors.lightBlueAccent[100],
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
              _showOldTools(),
            ],
          )
        ),
      ),
    );
  }

  Widget _showOldTools() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        ClipOval(
                          child: Material(
                            color: Colors.lightBlueAccent[100],
                            child: Center(
                              child: Ink(
                                decoration: ShapeDecoration(
                                  color: (_selectedMode == SelectedMode.Color) ? Colors.lightBlue : Colors.lightBlueAccent[100],
                                  shape: CircleBorder(side: BorderSide(width: 2.0, color: _selectedColor)),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.color_lens),
                                  color: (_selectedMode == SelectedMode.Color) ? Colors.white : Colors.black,
                                  onPressed: () {
                                    setState(() {
                                      _selectedMode = SelectedMode.Color;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text("Color")
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        ClipOval(
                          child: Material(
                            color: Colors.lightBlueAccent[100],
                            child: Center(
                              child: Ink(
                                decoration: ShapeDecoration(
                                  color: (_selectedMode == SelectedMode.StrokeWidth) ? Colors.lightBlue : Colors.lightBlueAccent[100],
                                  shape: CircleBorder(),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.album),
                                  color: (_selectedMode == SelectedMode.StrokeWidth) ? Colors.white : Colors.black,
                                  onPressed: () {
                                    setState(() {
                                      _selectedMode = SelectedMode.StrokeWidth;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text("Stroke")
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        ClipOval(
                          child: Material(
                            color: Colors.lightBlueAccent[100],
                            child: Center(
                              child: Ink(
                                decoration: ShapeDecoration(
                                  color: (_selectedMode == SelectedMode.Opacity) ? Colors.lightBlue : Colors.lightBlueAccent[100],
                                  shape: CircleBorder(),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.opacity),
                                  color: (_selectedMode == SelectedMode.Opacity) ? Colors.white : Colors.black,
                                  onPressed: () {
                                    setState(() {
                                      _selectedMode = SelectedMode.Opacity;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text("Opacity")
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        ClipOval(
                          child: Material(
                            color: Colors.lightBlueAccent[100],
                            child: Center(
                              child: Ink(
                                decoration: ShapeDecoration(
                                  color: Colors.lightBlueAccent[100],
                                  shape: CircleBorder(),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.delete),
                                  color: Colors.black,
                                  onPressed: () {
                                    showDialog<void>(
                                      context: context,
                                      barrierDismissible: true, // user must tap button!
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Clear Drawing?'),
                                          content: SingleChildScrollView(
                                            child: ListBody(
                                              children: <Widget>[
                                                Text('Are you sure you want to clear your drawing?'),
                                              ],
                                            ),
                                          ),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text('No'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            FlatButton(
                                              child: Text('Yes'),
                                              onPressed: () {
                                                setState(() {
                                                  _points.clear();
                                                });
                                                Navigator.of(context).pop();
                                              },
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text("Clear")
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                (_selectedMode == SelectedMode.Color)
                    ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: getColorList(),
                ),
                    )
                    : Slider(
                    value: (_selectedMode == SelectedMode.StrokeWidth)
                        ? _strokeWidth
                        : _opacity,
                    max: (_selectedMode == SelectedMode.StrokeWidth)
                        ? 50.0
                        : 1.0,
                    min: 0.0,
                    onChanged: (val) {
                      setState(() {
                        if (_selectedMode == SelectedMode.StrokeWidth)
                          _strokeWidth = val;
                        else
                          _opacity = val;
                      });
                    }),
              ],
            ),
          )
      ),
    );
  }

  getColorList() {
    List<Widget> listWidget = List();
    for (Color color in _colors) {
      listWidget.add(colorCircle(color));
    }
    Widget colorPicker = GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          child: AlertDialog(
            title: const Text('Pick a color!'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: _pickerColor,
                onColorChanged: (color) {
                  _pickerColor = color;
                },
                pickerAreaHeightPercent: 0.8,
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: const Text('Save'),
                onPressed: () {
                  setState(() => _selectedColor = _pickerColor);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.only(bottom: 16.0),
          height: 36,
          width: 36,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red, Colors.green, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )),
        ),
      ),
    );
    listWidget.add(colorPicker);
    return listWidget;
  }

  Widget colorCircle(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.only(bottom: 16.0),
          height: 36,
          width: 36,
          color: color,
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  DrawingPainter({this.pointsList});
  List<DrawingPoints> pointsList;
  List<Offset> offsetPoints = List();
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(pointsList[i].points, pointsList[i + 1].points,
            pointsList[i].paint);
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        offsetPoints.clear();
        offsetPoints.add(pointsList[i].points);
        offsetPoints.add(Offset(
            pointsList[i].points.dx + 0.1, pointsList[i].points.dy + 0.1));
        canvas.drawPoints(PointMode.points, offsetPoints, pointsList[i].paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

class DrawingPoints {
  Paint paint;
  Offset points;
  DrawingPoints({this.points, this.paint});
}

enum SelectedMode { StrokeWidth, Opacity, Color }
