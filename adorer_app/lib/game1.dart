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
  Stopwatch watch;
  Board board;
  @override
  void initState(){
    super.initState();
    watch = Stopwatch()..start();
  }
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
      default:
        board = new Board(level, number, timeout, progressLevel);
        return Scaffold(
          body: board,
        );
    }
  }

  progressLevel(double accuracy, int time) {
    print("Accuracy = $accuracy");
    print("Time = $time");
    print("LNT: $level$number$timeout");
    if(watch.elapsed.inSeconds > 90){
      Navigator.pop(context);
    }
    if(accuracy<0.7){
      stage = 0;
      setState(() {});
      return;
    }
    level++;
    number++;
    timeout -= 10;
    stage =0;
    board.createState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print("Building");
    return returnStage();
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
    return new BoardState();
  }
}

class BoardState extends State<Board> {
  int tries;
  Timer timer;
  @override
  initState() {
    super.initState();
    resetBoard();
    timer = new Timer(Duration(milliseconds: widget.timeout), () {
      setState(() {
        hideTiles();
      });
    });
    tries = 0;
    watch = Stopwatch();
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  List<List<TileState>> uiState;
  bool gameNotStarted = true;
  Stopwatch watch;
  void resetBoard() {
    print("reseting board");
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
    print("board reset");
  }

  void hideTiles() {
    print("hiding tiles");
    for (int i = 0; i < uiState.length; i++) {
      for (int j = 0; j < uiState[0].length; j++) {
        if (uiState[i][j] == TileState.correctRevealed) {
          uiState[i][j] = TileState.correctCovered;
        }
      }
    }
    watch.start();
    this.gameNotStarted = false;
    print("tiles hid");
  }

  void uncoverTile(row, col) {
    if (this.gameNotStarted) {
      return;
    }
    tries++;
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
      widget.callbackToNextLevel(
          (widget.number) / tries, watch.elapsed.inMilliseconds);
    }
  }

  bool winCheck() {
    if(widget.number/tries < 0.25){
      return true;
    }
    for (int i = 0; i < uiState.length; i++) {
      for (int j = 0; j < uiState.length; j++) {
        if (uiState[i][j] == TileState.correctCovered) {
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
    print("Building : LNT${widget.size}${widget.number}${widget.timeout}");
    return Scaffold(
        body: Container(
            constraints: BoxConstraints.expand(),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List<Widget>.generate(widget.size, (row) {
                  return Row(
                          children: List<Widget>.generate(widget.size, (col) {
                            return Expanded(
                                child: InkWell(
                                    onTap: () {
                                      uncoverTile(row, col);
                                    },
                                    child: AspectRatio(
                                      child: Card(
                                      color: getColor(row, col),                                      
                                    ), aspectRatio: 1.0,
                                    
                                    )));
                          }));
                }))));
  }
}
