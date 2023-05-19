import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  runApp(MaterialApp(
    home: const App(),
    theme: ThemeData.light(useMaterial3: true),
  ));
}
