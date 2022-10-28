import 'package:flutter/material.dart';
import 'package:guess_me/dialog.dart';
import 'package:guess_me/result.dart';
import 'app.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNumberTextController =
      TextEditingController();
  final TextEditingController secondNumberTextController =
      TextEditingController();
  bool isFormDirty = false;

  double deviceHeight = 0.0;
  double deviceWidth = 0.0;

  @override
  void initState() {
    super.initState();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //       appBar: AppBar(
  //         title: const Text(appTitle),
  //         centerTitle: true,
  //       ),
  //       body: );
  // }

  @override
  Widget build(BuildContext context) {
    deviceWidth = (MediaQuery.of(context).size.width);
    deviceHeight = (MediaQuery.of(context).size.height);

    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[300],
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
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
                        spreadRadius: 1.0),
                    BoxShadow(
                        color: Colors.white,
                        offset: Offset(-5.0, -5.0),
                        blurRadius: 15.0,
                        spreadRadius: 1.0),
                  ]),
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(children: _formElements(context)))),
        ],
      )),
    );
  }

  List<Widget> _formElements(BuildContext context) {
    return <Widget>[
      Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: _inputFields(context),
        ),
      ),
      Row(
        children: _inputButtons(context),
      )
    ];
  }

  List<Widget> _inputButtons(BuildContext context) {
    return <Widget>[];
  }

  List<Widget> _inputFields(BuildContext context) {
    return <Widget>[
      _textField(
          labelText: 'First Number', controller: firstNumberTextController),
      const SizedBox(height: 16),
      _textField(
          labelText: 'Second Number', controller: secondNumberTextController),
      const SizedBox(height: 16),
      _add(context),
      const SizedBox(height: 16),
      _cancel(context),
    ];
  }

  ElevatedButton _add(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          fixedSize: Size.fromWidth(100),
        ),
        onPressed: () async {
          try {
            if (_formKey.currentState!.validate()) {
              if (firstNumberTextController.text !=
                  secondNumberTextController.text) {
                int firstNumber = int.parse(firstNumberTextController.text);
                int secondNumber = int.parse(secondNumberTextController.text);
                if (firstNumber > secondNumber) {
                  firstNumber = firstNumber + secondNumber;
                  secondNumber = firstNumber - secondNumber;
                  firstNumber = firstNumber - secondNumber;
                }

                Navigator.push(
                    context,
                    MaterialPageRoute<dynamic>(
                        builder: (context) => ResultPage(
                            title: 'Your Guess',
                            firstNumber: firstNumber,
                            secondNumber: secondNumber)));

                //await showAlertDialog(context, "Hurray", "Is your guessed number $firstNumber ?");
              } else {
                await showAlertDialog(
                    context, "Error", "Please enter a range greater than 0!");
              }
            }
            clearAllFields();
          } catch (e) {}
        },
        child: const Text('GO'));
  }

  ElevatedButton _cancel(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          fixedSize: Size.fromWidth(100),
        ),
        onPressed: clearAllFields, child: const Text('CANCEL'));
  }

  TextFormField _textField(
      {required String labelText, required TextEditingController controller}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      controller: controller,
      validator: (text) => text!.isEmpty ? 'Input must not be empty' : null,
      onChanged: (value) {
        setState(() {
          isFormDirty = true;
        });
      },
    );
  }

  void clearAllFields() {
    setState(() {
      firstNumberTextController.text = secondNumberTextController.text = '';
      isFormDirty = false;
    });
  }
}
