import 'package:flutter/material.dart';

Future<void> safePop(BuildContext context) async {
  Navigator.canPop(context) ? Navigator.pop(context) : null;
}

Future<String?> safePopWithResult(BuildContext context, String result) async {
  Navigator.canPop(context) ? Navigator.pop(context, result) : 'NONE';
  return null;
}

Future<String?> validateTextFields(int firstNumber, int secondNumber)async {
  return null;
}
