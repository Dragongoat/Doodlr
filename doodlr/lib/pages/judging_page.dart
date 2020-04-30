import 'package:flutter/material.dart';

class JudgingWidget extends StatefulWidget {

  @override
  _JudgingWidgetState createState() => _JudgingWidgetState();
}

class _JudgingWidgetState extends State<JudgingWidget> {

  Widget _showPage() {
    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/img_colored_pencils_pixel.png"),
            fit: BoxFit.cover,
          ),
        ),
        constraints: BoxConstraints.expand(),
        child: Column(
          children: [
            _showInfoBox(),
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
                "Subject: house",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              Text("Tap a medal to assign it to a drawing:"),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text("Gold"),
                  Text("Silver"),
                  Text("Bronze")
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