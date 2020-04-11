import 'package:flutter/material.dart';

class PlaceholderWidget extends StatelessWidget {
  final Color color;
  final String bodyText;

  PlaceholderWidget(this.color, this.bodyText);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: color,
        child: Center(
            child: Column (
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      "Current page:"
                  ),
                  Text(
                    bodyText,
                    style: Theme.of(context).textTheme.headline,
                  )
                ]
            )
        )
    );
  }
}