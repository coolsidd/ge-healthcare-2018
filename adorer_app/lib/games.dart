import 'package:flutter/material.dart';
import 'game1.dart';

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainScreenState();
  }
}

class MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView(
        children: <Widget>[
          ListTile(
            title: Text("Game1"),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => Game1()));
            },
          )
        ],
      );
  }
}