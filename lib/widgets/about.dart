import 'package:flutter/material.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("About")),
      body: Padding(
        padding: EdgeInsetsGeometry.all(30.0),
        child: Column(
          children: [
            Text(
              "Deepnotes is a early state notes taking app which will be integrated with AI to enhance note taking experience, it is heavly inspired by Google Keep Notes",
            ),
            Text("2025 Copyright"),
          ],
        ),
      ),
    );
  }
}
