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
  List<List<charts.Series<List, DateTime>>> scales;
  List<List<dynamic>> graphData;
  Future<Null> readData() async {
    final directory = await getApplicationDocumentsDirectory();
    final File file = File("${directory.path}/graphData.csv");
    String info = await file.readAsString();
    List<List> conv = CsvToListConverter().convert(info);
    print(conv.length);
    print(conv[0]);
    print(conv[1]);
    conv.sort((entry1, entry2) {
      return DateTime.parse(entry1[0].toString())
          .compareTo(DateTime.parse(entry2[0].toString()));
    });
    print("sorted!!");
    print("$conv");
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
    for (int j = 2; j < graphData[0].length; j++) {
      List<charts.Series<List, DateTime>> scalesList = [];
      for (int i = 0; i < 1; i++) {
        scalesList.add(charts.Series<List, DateTime>(
            data: graphData[0],
            id: 'Game 1',
            domainFn: (List entry, _) {
              print(DateTime.parse(entry[0]).toIso8601String().substring(0, 9));
              return DateTime.parse(entry[0]);
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
        children: List<Widget>.generate(scales.length, (i) {
      return Card(
          margin: EdgeInsets.all(20.0),
          
          child: Column(children: [
            Text("Graph Title"),
            Container(
                constraints: BoxConstraints.tight(Size(1000, 300)),
                margin: EdgeInsets.all(10.0),
                child: charts.TimeSeriesChart(
                  scales[i],
                  animate: true,
                ))
          ]));
    }));
  }
}
