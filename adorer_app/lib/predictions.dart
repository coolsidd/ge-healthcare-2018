import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'activities.dart' as Activities;
import 'dart:convert';

class PredictionsWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PredictionsWidgetState();
  }
}

enum AdviceType { good, bad, info }


class AdviceAboutClass {
  AdviceAbout asEnum;

  AdviceAboutClass(this.asEnum);
}
enum AdviceAbout {
  sleep,
  social,
  cognition,
}

class Advice {
  AdviceType type;
  AdviceAbout about;
  String name;
  Advice(this.type, this.about, this.name);
  Widget getAdviceWidget() {
    return Card(
        child: Column(children: [
      ListTile(
        leading: Icon(Icons.lightbulb_outline),
        title: Text("Advice regarding ${this.name}"),
      ),
      Container(
        padding: EdgeInsets.all(10.0),
        child: Text(
            "You should perform ${this.name} more as it seems to increase your performance in ${about.toString().substring(12)}"),
      ),
    ]));
  }

  factory Advice.fromActivity(Activities.Activity act) {
    return Advice(AdviceType.good, AdviceAbout.sleep, act.name);
  }
}

class PredictionsWidgetState extends State<PredictionsWidget> {
  List<Activities.Activity> activitiesList;
  Widget advice = Center(
      child: Text("We'll give you recommendations here as you go!",
          style: TextStyle(fontWeight: FontWeight.w300)));
  readData() async {
    final directory = await getApplicationDocumentsDirectory();
    List dataList = [];
    if (FileSystemEntity.typeSync("${directory.path}/activitiesData.csv") !=
        FileSystemEntityType.notFound) {
      final File file = File("${directory.path}/activitiesData.csv");
      String data = await file.readAsString();
      dataList = CsvToListConverter().convert(data)[0];
    }
    activitiesList = List<Activities.Activity>.generate(dataList.length, (i) {
      return Activities.Activity.fromJson(jsonDecode(dataList[i]));
    });
  }

  void generateAdvice() async {
    await readData();
    if (activitiesList.isNotEmpty) {
      advice = ListView(
        children: List<Widget>.generate(activitiesList.length, (i) {
          print("reading...");
          return Advice.fromActivity(activitiesList[i]).getAdviceWidget();
        }),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    generateAdvice();
    return advice;
  }
}
