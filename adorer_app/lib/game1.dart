import 'package:flutter/material.dart';

enum TileState {covered, revealed, correctCovered, correctRevealed}

class Game1 extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return Game1State();
  }
}

class Game1State extends State <Game1> {
  int stage = 0;
  Widget returnStage(){
    switch(stage){
      case 0:
      return Scaffold(
        appBar: AppBar(
          title: Text("Tutorial"),
        ),
        body: Column(
          children: <Widget>[
            Text("Tutorial Screen"),
            FlatButton(
              child: Text("PLAY"),
              onPressed: (){
                setState(() {stage++;});
              },
            )
          ],
        ),
        );
      break;
      case 1:
      return Board(1);
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Game1",
      home: returnStage(),
    );
  }
}

class Board extends StatefulWidget{
  final int level;
  Board(this.level);
  @override
  State<StatefulWidget> createState(){
    return BoardState();
  }
}

class BoardState extends State<Board>{
  List<List<TileState>> uiState;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[

      ],
    );
  }
}