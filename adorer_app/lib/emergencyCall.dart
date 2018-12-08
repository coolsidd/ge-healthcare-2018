import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class EmergencyCallWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EmergencyCallWidgetState();
  }
}

class EmergencyCallWidgetState extends State<EmergencyCallWidget> {
  String doctorNumber;
  String doctorName = "Doctor";
  @override
  void initState() {
    super.initState();
    readData();
  }

  Future<void> readData() async {
    final directory = await getApplicationDocumentsDirectory();
    final File file = File("${directory.path}/emergencyContact");
    if (doctorNumber != null) {
      return;
    }
    if (await file.exists()) {
      List data = (await file.readAsLines());
      print(data);
      doctorNumber = data[0];
      doctorName = data[1];
      setState(() {
              
            });
    }
  }

  Future<void> autoSaveData() async {
    final directory = await getApplicationDocumentsDirectory();
    final File file = File("${directory.path}/emergencyContact");
    await file.writeAsString("$doctorNumber\n");
    await file.writeAsString("$doctorName",mode: FileMode.append);
  }

  Future<void> launchEmergencyContactDialog() async {
    String name, phone;
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Emergency Dialog'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Name: "),
                TextField(
                  maxLength: 30,
                  onChanged: (myStr) {
                    name = myStr;
                  },
                ),
                Text("Phone No: "),
                TextField(
                  keyboardType: TextInputType.numberWithOptions(),
                  maxLength: 12,
                  onChanged: (myStr) {
                    phone = myStr;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('ADD'),
              onPressed: () async {
                if (name != null && phone != null) {
                  doctorNumber = phone;
                  doctorName = name;
                  await autoSaveData();
                  setState(() {});
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  callDoctor() {
    if (doctorNumber != null) {
      launch("tel://$doctorNumber");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Emergency Contact"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              launchEmergencyContactDialog();
            },
          )
        ],
      ),
      body: Center(
        child: FlatButton(
          child: Text("Call $doctorName",style: TextStyle(fontSize: 20),),
          disabledColor: Colors.redAccent,
          color: Colors.red,
          onPressed: (doctorNumber == null)
              ? null
              : () {
                  callDoctor();
                },
        ),
      ),
    );
  }
}
