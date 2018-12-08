import 'package:flutter/material.dart';
import 'game1.dart';
import 'game2.dart';

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
        Container(
          constraints: BoxConstraints.tight(Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height * 0.3)),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.asset(
                'assets/images/misc/Cognitive.jpg',
                fit: BoxFit.cover,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.0, 0.0),
                    end: Alignment(0.0, 0.5),
                    colors: <Color>[Color(0x00000000), Color(0x70000000)],
                  ),
                ),
              ),
              Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Padding(
                    padding: EdgeInsets.only(bottom: 5.0),
                    child: Text(
                      "Cognitive Games",
                      style: TextStyle(fontWeight: FontWeight.w600,color: Colors.grey[50],fontSize: 40),
                    ))
              ]),
            ],
          ),
        ),
        ListTile(
          leading: Icon(Icons.gradient),
          title: Text("Short term memory"),
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Game1()));
          },
        ),
        Container(
          constraints: BoxConstraints.tight(Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height * 0.3)),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.asset(
                'assets/images/misc/Social.jpg',
                fit: BoxFit.cover,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.0, 0.0),
                    end: Alignment(0.0, 0.5),
                    colors: <Color>[Color(0x00000000), Color(0x70000000)],
                  ),
                ),
              ),
              Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Padding(
                    padding: EdgeInsets.only(bottom: 5.0),
                    child: Text(
                      "Social Skill Games",
                      style: TextStyle(fontWeight: FontWeight.w600,color: Colors.grey[50],fontSize: 40),
                    ))
              ]),
              
            ],
          ),
        ),
        ListTile(
          leading: Icon(Icons.face),
          title: Text("Emotion"),
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Game2()));
          },
        )
      ],
    );
  }
}
