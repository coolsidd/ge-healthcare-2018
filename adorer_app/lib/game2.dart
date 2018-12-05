library adorer_app.game2;

import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:vibrate/vibrate.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:core';

class Game2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return Game2State();
  }
}

class Game2State extends State<Game2> {
  int stage = 0;
  int tries = 0;
  int timeout = 3000;
  int gamesWon = 0;
  Stopwatch watch = Stopwatch();
  GameDay board;
  @override
  void initState() {
    super.initState();
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
        if (watch.isRunning == false) {
          watch = Stopwatch()..start();
        }
        board = GameDay(progressLevel);
        return Scaffold(
          body: board,
        );
    }
  }

  Future<Null> writeData(String data) async {
    final directory = await getApplicationDocumentsDirectory();
    final File file = File("${directory.path}/graphData.csv");
    file.writeAsString(data, mode: FileMode.append);
  }

  progressLevel(double accuracy, int time) {
    print("Accuracy = $accuracy");
    print("Time = $time");
    String data = ListToCsvConverter().convert([
      [
        DateTime.now().toIso8601String(),
        2,
        accuracy,
        time,
        tries,
      ]
    ]); // 1 corresponds to the gameNo.
    data = data + "\r\n";
    writeData(data);
    if (watch.elapsed.inSeconds > 90) {
      Navigator.pop(context);
    }
    tries++;
    if (accuracy < 0.7) {
      stage = 0;
      setState(() {});
      return;
    }
    timeout -= 10;
    stage = 0;
    gamesWon++;
    board.createState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print("Building");
    return returnStage();
  }
}

class GameDay extends StatefulWidget {
  final dynamic callbackToNextLevel;
  GameDay(this.callbackToNextLevel);
  @override
  State<StatefulWidget> createState() {
    return GameDayState();
  }
}

enum Emotion { angry, surprise, sad, happy, neutral }

class GameDayState extends State<GameDay> {
  Stopwatch watch;
  Emotion imgName;
  List<Emotion> name = [];
  int choiceSize = 3;
  int tries = 1;
  int imgChoice; // used to generate the name of the image used in the game
  @override
  void initState() {
    super.initState();
    watch = Stopwatch();
    watch.start();
    Random rand = Random();
    while (name.length < choiceSize) {
      int choice = rand.nextInt(Emotion.values.length);
      if (name.contains(Emotion.values[choice])) {
        continue;
      } else {
        name.add(Emotion.values[choice]);
      }
    }
    imgChoice = rand.nextInt(2)+1;
    imgName = name[rand.nextInt(choiceSize)];
  }

  void checkAnswer(int i) {
    if (i == name.indexOf(imgName)) {
      widget.callbackToNextLevel(1 / tries, watch.elapsed.inMilliseconds);
    } else {
      tries++;
      Vibrate.feedback(FeedbackType.warning);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      primary: true,
      
      body: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        CircleAvatar(
          child: Image(
            image: AssetImage("assets/images/emotion/${imgName.toString().substring(8)}/${imgName.toString().substring(8)+imgChoice.toString()}.png"),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          radius: 80.0,
        ),
        ButtonBar(
          mainAxisSize: MainAxisSize.min,
          alignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (i) {
            return FlatButton(
              child: Text("${name[i].toString().substring(8).toUpperCase()}"),
              onPressed: () {
                checkAnswer(i);
              },
            );
          }),
        )
      ],
    ));
  }
}
