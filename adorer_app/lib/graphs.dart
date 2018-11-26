import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'dart:core';

class GraphsWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GraphsWidgetState();
  }
}

class GraphsWidgetState extends State<GraphsWidget> {
  bool loaded = false;
  List<List<charts.Series<List, String>>> scales;
  List<List<dynamic>> graphData;
  void loadFile() async {
    final String input = await File("/assets/graphData.csv").readAsString();
    List<List> conv = CsvToListConverter().convert(input);
    print("${conv.length}");
    print("${conv[0].length}");
  }

  Future<Null> readData() async {
    final directory = await getApplicationDocumentsDirectory();
    final File file = File("${directory.path}/graphData.csv");
    String info = await file.readAsString();
    List<List> conv = CsvToListConverter().convert(info);
    conv.sort((entry1, entry2) {
      DateTime.parse(entry1[0].toString())
          .compareTo(DateTime.parse(entry2[0].toString()));
    });
    print("$info");
    graphData = [];
    scales = [];
    for (int i = 0; i < 1; i++) {
      graphData.insert(
          i,
          conv.where((a) {
            return a[1] == i + 1;
          }).toList());
    }
    print("graphs data: $graphData");
    for (int i = 0; i < 1; i++) {
      List<charts.Series<List, String>> scalesList = [];
      for (int j = 2; j < graphData[i].length; j++) {
        scalesList.add(charts.Series<List, String>(
            data: graphData[0],
            id: 'Game 1',
            domainFn: (List entry, _) {
              print(DateTime.parse(entry[0]).toIso8601String().substring(5, 9));
              return DateTime.parse(entry[0]).toIso8601String().substring(5, 9);
            },
            measureFn: (List entry, _) {
              print("$entry");
              return entry[j];
            }));
      }
      scales.add(scalesList);
    }
    print("scales length ${scales.length}");
    setState(() {
      loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loaded == false) {
      readData();
      return Center(child: CircularProgressIndicator());
    }
    return ListView(
      children: <Widget>[
        Text("Don"),
        Container(
            constraints: BoxConstraints.tight(Size(1000, 300)),
            child: Card(
                margin: EdgeInsets.all(5.0),
                child: charts.BarChart(
                  scales[0],
                  animate: true,
                  barGroupingType: charts.BarGroupingType.grouped,
                ))),
      ],
    );
  }
}
