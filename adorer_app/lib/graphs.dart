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
  List<charts.Series<List, DateTime>> scales;
  List<List<dynamic>> graphData;
  Future<Null> readData() async {
    final directory = await getApplicationDocumentsDirectory();
    if (FileSystemEntity.typeSync("${directory.path}/graphData.csv") ==
        FileSystemEntityType.notFound) {
      return;
    }
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

    graphData = [];
    scales = [];
    for (int i = 0; i < 2; i++) {
      graphData.insert(
          i,
          conv.where((a) {
            return a[1] == i + 1;
          }).toList());
    }
    scales.addAll([
      charts.Series<List, DateTime>(
          data: graphData[0],
          id: "Accuracy",
          displayName: "Short term memory score",
          colorFn: (_ ,__){
            return charts.MaterialPalette.deepOrange.shadeDefault;
          },
          domainFn: (List entry, _) {
            return DateTime.parse(entry[0]);
          },
          measureFn: (List entry, _) {
            return entry[5];
          }),
      charts.Series<List, DateTime>(
          data: graphData[0],
          colorFn: (_ ,__){
            return charts.MaterialPalette.deepOrange.shadeDefault;
          },
          id: "Speed",
          displayName: "Memory speed",
          overlaySeries: true,
          domainFn: (List entry, _) {
            return DateTime.parse(entry[0]);
          },
          measureFn: (List entry, _) {
            return entry[6];
          }),
    ]);
    scales.addAll([
      charts.Series<List, DateTime>(
          data: graphData[1],
          id: "Score2",
          displayName: "Emotion Score",
          colorFn: (_ ,__){
            return charts.MaterialPalette.deepOrange.shadeDefault;
          },
          domainFn: (List entry, _) {
            return DateTime.parse(entry[0]);
          },
          measureFn: (List entry, _) {
            print(entry[2]);
            return entry[2];
          }),
    ]);

    /* for (int j = 2; j < graphData[0].length; j++) {
      List<charts.Series<List, DateTime>> scalesList = [];
      for (int i = 0; i < 1; i++) {
        scalesList.add(charts.Series<List, DateTime>(
            data: graphData[0],
            id: 'Game 1',
            domainFn: (List entry, _) {
              return DateTime.parse(entry[0]);
            },
            measureFn: (List entry, _) {
              return entry[j];
            }));
      }
      scales.add(scalesList);
    } */
    print("scales length ${scales.length}");
    print(graphData[0]);
    setState(() {
      loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loaded == false) {
      readData();
      return Column(children: [
        CircularProgressIndicator(),
        Text(
          "Graphs will begin appearing here once you start playing the games",
          softWrap: true,
        )
      ]);
    }
    return ListView(
        children: List<Widget>.generate(scales.length, (i) {
      return Card(
          margin: EdgeInsets.all(20.0),
          child: Column(children: [
            Padding(
              padding: EdgeInsets.only(top: 15.0),
              child: Text(scales[i].displayName)),
            Container(
                constraints: BoxConstraints.tight(Size(1000, 300)),
                margin: EdgeInsets.all(10.0),
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                    child: charts.TimeSeriesChart(
                  [scales[i]],
                  defaultInteractions: false,
                  behaviors: [
                    new charts.SelectNearest(),
                    new charts.DomainHighlighter()
                  ],
                  domainAxis: new charts.DateTimeAxisSpec(
                    usingBarRenderer: true,
                  ),
                  animate: true,
                )))
          ]));
    }));
  }
}
