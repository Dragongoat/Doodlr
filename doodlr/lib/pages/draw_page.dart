// Code adapted from this medium article: https://medium.com/flutter-community/drawing-in-flutter-using-custompainter-307a9f1c21f8
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class Draw extends StatefulWidget {
  Draw({this.onJudgingRound});

  final onJudgingRound;

  @override
  _DrawState createState() => _DrawState();
}

class _DrawState extends State<Draw> {
  Color selectedColor = Colors.black;
  Color pickerColor = Colors.black;
  double strokeWidth = 3.0;
  List<DrawingPoints> points = List();
  double opacity = 1.0;
  StrokeCap strokeCap = StrokeCap.round;
  SelectedMode selectedMode = SelectedMode.Color;
  List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.amber,
    Colors.black,
    Colors.white
  ];
  @override
  Widget build(BuildContext context) {
    return _showPage();
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
        child: Column(
          children: [
            _showInfoBox(),
            _showCanvas(),
            _showTools(),
          ],
        )
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
                "You are drawing: house",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                child: Text("Time Remaining:"),
                onTap: () => widget.onJudgingRound(),
              ),
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
            setState(() {
              RenderBox renderBox = context.findRenderObject();
              double boxSize = MediaQuery.of(context).size.width * 0.9;
              Offset touchPosition = details.localPosition;
              if (touchPosition.dx < 0 || touchPosition.dy < 0 ||
                touchPosition.dx > boxSize || touchPosition.dy > boxSize) {
                points.add(null);
              }
              else {
                points.add(DrawingPoints(
                    points: details.localPosition,
                    paint: Paint()
                      ..strokeCap = strokeCap
                      ..isAntiAlias = true
                      ..color = selectedColor.withOpacity(opacity)
                      ..strokeWidth = strokeWidth));
              }
            });
          },
          onPanStart: (details) {
            setState(() {
              RenderBox renderBox = context.findRenderObject();
              points.add(DrawingPoints(
                  points: details.localPosition,
                  paint: Paint()
                    ..strokeCap = strokeCap
                    ..isAntiAlias = true
                    ..color = selectedColor.withOpacity(opacity)
                    ..strokeWidth = strokeWidth));
            });
          },
          onPanEnd: (details) {
            setState(() {
              points.add(null);
            });
          },
          child: ClipRect(
            child: CustomPaint(
              size: Size.square(MediaQuery.of(context).size.width * 0.9),
              painter: DrawingPainter(
                pointsList: points,
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
                                  color: (selectedMode == SelectedMode.Color) ? Colors.lightBlue : Colors.lightBlueAccent[100],
                                  shape: CircleBorder(side: BorderSide(width: 2.0, color: selectedColor)),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.color_lens),
                                  color: (selectedMode == SelectedMode.Color) ? Colors.white : Colors.black,
                                  onPressed: () {
                                    setState(() {
                                      selectedMode = SelectedMode.Color;
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
                                  color: (selectedMode == SelectedMode.StrokeWidth) ? Colors.lightBlue : Colors.lightBlueAccent[100],
                                  shape: CircleBorder(),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.album),
                                  color: (selectedMode == SelectedMode.StrokeWidth) ? Colors.white : Colors.black,
                                  onPressed: () {
                                    setState(() {
                                      selectedMode = SelectedMode.StrokeWidth;
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
                                  color: (selectedMode == SelectedMode.Opacity) ? Colors.lightBlue : Colors.lightBlueAccent[100],
                                  shape: CircleBorder(),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.opacity),
                                  color: (selectedMode == SelectedMode.Opacity) ? Colors.white : Colors.black,
                                  onPressed: () {
                                    setState(() {
                                      selectedMode = SelectedMode.Opacity;
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
                                                  points.clear();
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
                (selectedMode == SelectedMode.Color)
                    ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: getColorList(),
                ),
                    )
                    : Slider(
                    value: (selectedMode == SelectedMode.StrokeWidth)
                        ? strokeWidth
                        : opacity,
                    max: (selectedMode == SelectedMode.StrokeWidth)
                        ? 50.0
                        : 1.0,
                    min: 0.0,
                    onChanged: (val) {
                      setState(() {
                        if (selectedMode == SelectedMode.StrokeWidth)
                          strokeWidth = val;
                        else
                          opacity = val;
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
    for (Color color in colors) {
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
                pickerColor: pickerColor,
                onColorChanged: (color) {
                  pickerColor = color;
                },
                pickerAreaHeightPercent: 0.8,
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: const Text('Save'),
                onPressed: () {
                  setState(() => selectedColor = pickerColor);
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
          selectedColor = color;
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
