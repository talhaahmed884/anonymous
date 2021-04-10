import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'anonymous';
    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: Text(appTitle),
        ),
        body: MyCustomForm(),
      ),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  @override
  Form createState() {
    return Form();
  }
}

class Form extends State<MyCustomForm> {
  TextEditingController _rollNo = new TextEditingController();
  TextEditingController _message = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: SingleChildScrollView(
          child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 25),
            child: TextFormField(
              controller: _rollNo,
              decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Recipient Roll-No',
                  alignLabelWithHint: true,
                  hintText: '18I-1234'),
            ),
          ),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 35),
              child: TextFormField(
                maxLines: null,
                controller: _message,
                decoration: InputDecoration(
                    hintText: 'I HATE THAT BITCH!!!',
                    border: UnderlineInputBorder(),
                    labelText: 'Your Message',
                    alignLabelWithHint: true),
              )),
          ElevatedButton(
            autofocus: true,
            onPressed: () {
              if (_rollNo.text.isNotEmpty && _message.text.isNotEmpty) {
                Message current = new Message(_rollNo.text, _message.text);
                FocusScope.of(context).unfocus();
                SystemChannels.textInput.invokeMethod('TextInput.hide');
                Future<int> msg = current.upload();
                if (msg.whenComplete(() => null) != null) {
                  final snackBar = SnackBar(
                    content: Text('Your message has been sent!!'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } else {
                  final snackBar = SnackBar(
                    content: Text('Couldn\'t send your message!!'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
                _rollNo.clear();
                _message.clear();
              }
            },
            child: Text('Lets Go!!'),
            style: ElevatedButton.styleFrom(
                primary: Colors.blue, onPrimary: Colors.white),
          )
        ],
      )),
    ));
  }
}

class Message {
  String message;
  String rollNo;

  Message(String rollNo, String message) {
    this.message = message;
    this.rollNo = rollNo;
  }

  void setMessage(String message) {
    this.message = message;
  }

  String getMessage() {
    return message;
  }

  void setRollNo(String rollNo) {
    this.rollNo = rollNo;
  }

  String getRollNo() {
    return rollNo;
  }

  bool isEmpty() {
    if (rollNo.isEmpty || message.isEmpty) {
      return true;
    }
    return false;
  }

  void display() {
    print('Roll-No: ' + rollNo + '\n');
    print('Message: ' + message + '\n');
  }

  Future<int> upload() async {
    await Firebase.initializeApp();
    Map<String, dynamic> data = {"RollNo": rollNo, "Message": message};
    CollectionReference reference =
        FirebaseFirestore.instance.collection('Message');
    try {
      await reference.add(data);
      return 1;
    } catch (error) {
      return 0;
    }
  }
}
