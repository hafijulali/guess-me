import 'package:flutter/material.dart';
import 'home.dart';

const appTitle = 'Guess Me';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: const HomePage(title: appTitle),
    );
  }
  
}
