import 'package:flutter/material.dart';
import 'package:listzly/pages/intro_page.dart';
import 'package:listzly/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: IntroPage(),
      routes: {
        '/intropage': (context) => IntroPage(),
        '/homepage': (context) => HomePage(),
      }
    );
  }
}