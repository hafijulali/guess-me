import 'package:flutter/material.dart';
import 'package:guess_me/dialog.dart';
import 'app.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({
    Key? key,
    required this.title,
    required this.firstNumber,
    required this.secondNumber,
  }) : super(key: key);
  final String title;
  final int firstNumber;
  final int secondNumber;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  double deviceHeight = 0.0;
  double deviceWidth = 0.0;
  int firstNumber = 0;
  int secondNumber = 0;
  int guess = 0;
  int data = 0;

  @override
  void initState() {
    firstNumber = widget.firstNumber;
    secondNumber = widget.secondNumber;
    guess = (firstNumber + secondNumber) ~/ 2;
    data = guess;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[300],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width:
                  (deviceWidth > 1000) ? (deviceWidth / 2) : deviceWidth - 50,
              height: (deviceHeight > 500)
                  ? (deviceHeight / 2)
                  : deviceHeight - 100,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(5.0, 5.0),
                    blurRadius: 15.0,
                    spreadRadius: 1.0,
                  ),
                  BoxShadow(
                    color: Colors.white,
                    offset: Offset(-5.0, -5.0),
                    blurRadius: 15.0,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(children: _formElements(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _formElements(BuildContext context) {
    return <Widget>[
      Center(
        child: Column(
          children: <Widget>[
            _textField(data: data),
            const SizedBox(height: 40),
            _actionButton(context, 'HIGHER THAN $data'),
            const SizedBox(height: 40),
            _actionButton(context, 'LOWER  THAN $data'),
            const SizedBox(height: 40),
            _actionButton(context, 'GOT IT!   IT IS $data'),
          ],
        ),
      ),
    ];
  }

  ElevatedButton _actionButton(BuildContext context, String text) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade400,
        fixedSize: const Size.fromHeight(50),
      ),
      child: Text(text),
      onPressed: () async {
        print("$firstNumber $secondNumber");
        if (text.contains("HIGHER")) {
          firstNumber = guess;
        } else if (text.contains("LOWER")) {
          secondNumber = guess;
        } else if (firstNumber == secondNumber ||
            data == guess ||
            text.contains("GOT IT!")) {
          final String? result = await showAlertDialog(
            context,
            "Hurray",
            "Your Guessed Number is $guess. Do you want to exit?",
          );
          if (result == "OK" && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }
        guess = (firstNumber + secondNumber) ~/ 2;
        setState(() {
          data = guess;
        });
      },
    );
  }

  Text _textField({required int data}) {
    return Text(
      'Is your gussed number $data?',
      style: const TextStyle(fontSize: 40),
      textScaleFactor: 0.5,
    );
  }
}
