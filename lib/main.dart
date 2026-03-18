import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Center(
              child: Text("KrakFlow"),
            ),
            Center(
              child: Text("Organizacja studiów"),
            ),
            Center(
              child: Text("Dzisiejsze zadania"),
            )
          ],
        )
      )
    );
  }
}