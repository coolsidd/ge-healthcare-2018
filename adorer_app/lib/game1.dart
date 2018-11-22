import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:vibrate/vibrate.dart';

enum TileState { covered, revealed, correctCovered, correctRevealed }

class Game1 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return Game1State();
  }
}

class Game1State extends State<Game1> {
  int stage = 0;
  int level = 4;
  int number = 10;
  int timeout = 3000;
  Widget returnStage() {
    switch (stage) {
      case 0:
        return Scaffold(
          appBar: AppBar(
            title: Text("Tutorial"),
          ),
          body: Column(
            children: <Widget>[
              Text("Tutorial Screen"),
              RaisedButton(
                child: Text("PLAY"),
                onPressed: () {
                  setState(() {
                    stage++;
                  });
                },
              )
            ],
          ),
        );
        break;
      case 1:
        return Board(4, 10, 3000,progressLevel);
      default:
        return Container();
    }
  }
   progressLevel() {
    setState(() {
      level++;
      number++;
      timeout -= 10;
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Game1",
      home: returnStage(),
    );
  }
}

class Board extends StatefulWidget {

  final int size;
  final int number;
  final int timeout;
  final dynamic callbackToNextLevel;
  Board(this.size, this.number, this.timeout, this.callbackToNextLevel);
  @override
  State<StatefulWidget> createState() {
    return BoardState();
  }
}

class BoardState extends State<Board> {
  Timer timer;
  @override
  initState(){
    super.initState();
    resetBoard();
    timer = new Timer(Duration(milliseconds: widget.timeout), () {
      setState(() {
        hideTiles();
      });
    });
  }
  @override
  void dispose(){
    super.dispose();
    timer.cancel();
  }
  List<List<TileState>> uiState;
  bool gameNotStarted = true;
  void resetBoard() {
    int leftToMark = widget.number;
    uiState = List<List<TileState>>.generate(widget.size, (row) {
      return List<TileState>.generate(widget.size, (column) {
        return TileState.covered;
      });
    });
    Random rand = Random();
    while (leftToMark > 0) {
      int randRow = rand.nextInt(widget.size);
      int randCol = rand.nextInt(widget.size);
      if (uiState[randRow][randCol] == TileState.correctRevealed) {
        continue;
      } else {
        uiState[randRow][randCol] = TileState.correctRevealed;
        leftToMark--;
      }
    }
  }
  void hideTiles(){
    for(int i = 0; i<uiState.length;i++){
      for (int j = 0; j < uiState[0].length; j++) {
        if(uiState[i][j] == TileState.correctRevealed){
          uiState[i][j] = TileState.correctCovered;
        }
      }
    }
  }
  void uncoverTile(row, col) {
    if (uiState[row][col] == TileState.correctCovered) {
      print("Congrats");
      setState(() {
        uiState[row][col] = TileState.correctRevealed;
      });
    } else {
      Vibrate.feedback(FeedbackType.warning);
      print("Oops");
    }
    if (winCheck()) {
      print("You won!");
      Navigator.of(context).pop();
      
    }
  }

  bool winCheck() {
    for (int i = 0; i < uiState.length; i++){
      for (int j = 0; j < uiState.length; j++){
        if(uiState[i][j] == TileState.correctCovered){
          return false;
        }
      }
    }
    return true;
  }

  Color getColor(row, col) {
    if (uiState[row][col] == TileState.revealed) {
      return Colors.red;
    } else if (uiState[row][col] == TileState.covered ||
        uiState[row][col] == TileState.correctCovered) {
      return Colors.amber;
    } else if (uiState[row][col] == TileState.correctRevealed) {
      return Colors.green;
    }
    return Colors.blueAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List<Widget>.generate(widget.size, (row) {
          return Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List<Widget>.generate(widget.size, (col) {
                return Expanded(
                  child: InkWell(
                  onTap: (){
                    uncoverTile(row, col);
                  },
                  child: Card(
                  color: getColor(row, col),
                )));
              })));
        }))));
  }
}