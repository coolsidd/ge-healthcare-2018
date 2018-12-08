import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'dart:async';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:path_provider/path_provider.dart';
import 'dart:core';
import 'dart:math';
import 'dart:io';
import 'package:csv/csv.dart' as csv;

class SleepScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SleepScreenState();
  }
}

class SleepScreenState extends State<SleepScreen> {
  Map<String, List<List>> previousData = Map();
  List<charts.Series<List, DateTime>> graphData;
  Future<Null> readData() async {
    final directory = await getApplicationDocumentsDirectory();
    if (FileSystemEntity.typeSync("${directory.path}/sleepData.csv") !=
            FileSystemEntityType.notFound &&
        FileSystemEntity.typeSync("${directory.path}/sleepMeta.csv") !=
            FileSystemEntityType.notFound) {
      final File file = File("${directory.path}/sleepData.csv");
      final File fileMeta = File("${directory.path}/sleepMeta.csv");
      previousData["history"] =
          csv.CsvToListConverter().convert(await fileMeta.readAsString());
      previousData["last"] =
          csv.CsvToListConverter().convert(await file.readAsString());
      print("data loaded");

      setState(() {});
    }
  }

  Widget getLastSleepsData() {
    List<Widget> results = [];
    if (!(previousData.containsKey("history") &&
        previousData.containsKey("last"))) {
      readData();
      results = [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          child: Text(
            "The results will display here once you start tracking your sleep.",
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        )
      ];
    } else {
      print("data loaded now processing");
      DateTime start =
          DateTime.parse(previousData["history"].last[0].toString());
      DateTime end = DateTime.parse(previousData['history'].last[1].toString());
      print(previousData["last"][0]);
      List<List> distanceOnly = List.generate(previousData["last"].length, (i) {
        return [
          DateTime.parse(previousData["last"][i][0]),
          (previousData["last"][i].sublist(1)).reduce((a, b) {
            return a.abs() + b.abs();
          })
        ];
      });
      print(distanceOnly);
      print("Sorting");
      distanceOnly.sort((a, b) {
        return b[1].compareTo(a[1]);
      });
      distanceOnly.removeRange(0, (distanceOnly.length * 0.05).toInt());
      distanceOnly.sort((a, b) {
        return a[0].compareTo(b[0]);
      });
      print('sorted');
      print(distanceOnly[0]);
      double max = distanceOnly[0][1];
      double mean = 0;
      distanceOnly.forEach((i) {
        mean += i[1];
      });
      mean = mean / distanceOnly.length;
      print(mean);
      distanceOnly.forEach((pt) {
        if (pt[1] > max) {
          max = pt[1];
        }
      });
      Map<String, List> classified = Map();
      List<List> normalized = List.generate(distanceOnly.length, (i) {
        return [
          distanceOnly[i][0],
          ((distanceOnly[i][1] - mean) / (max)).abs()
        ];
      });
      classified["rem"] = normalized.where((pt) {
        return (pt[1] > 0.5);
      }).toList();
      classified["deep"] = distanceOnly.where((pt) {
        return (pt[1] <= 0.5);
      }).toList();
      double score =
          classified["deep"].length * 1.0 + 0.5 * classified["rem"].length;
      graphData = [
        charts.Series<List, DateTime>(
          id: 'SleepData',
          domainFn: (List pt, _) => pt[0],
          measureFn: (List pt, _) => pt[1],
          data: normalized,
        ),
        charts.Series<List, DateTime>(
          id: 'SleepData',
          domainFn: (List pt, _) => pt[0],
          measureFn: (List pt, _) => mean,
          data: classified["deep"],
        ),
        charts.Series<List, DateTime>(
          id: 'SleepData',
          domainFn: (List pt, _) => pt[0],
          measureFn: (List pt, _) => mean,
          data: classified["rem"],
        )
      ];
      double deep = classified["deep"].length /
          (classified["rem"].length + classified["deep"].length);
      print("graphData ready");
      results = [
        ListTile(
          title: Text("Duration: ${end.difference(start).inMinutes} minutes"),
          subtitle: Text("Sleep Score: $score"),
          trailing: Text(
              "Deep: ${(deep * 100).round()}%\nREM: ${((1 - deep) * 100).round()}%"),
        ),
        Padding(
            padding: EdgeInsets.all(3.0),
            child: Text(
              "${start.toIso8601String().substring(0, 10)} ${start.toIso8601String().substring(12, 19)}",
            )),
        Container(
            constraints: BoxConstraints.tight(Size(
                MediaQuery.of(context).size.width * 0.95,
                MediaQuery.of(context).size.height * 0.4)),
            child: charts.TimeSeriesChart(
              graphData,
              animate: true,
            )),
      ];
    }

    return Card(
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
        child: Column(
          children: [
            [
              Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text("Previous Night's Sleep Statistics",
                      textAlign: TextAlign.center)),
              Divider()
            ],
            results
          ].expand((x) => x).toList(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ListTile(
        leading: Icon(Icons.hotel),
        title: Text("Begin Sleep Tracking"),
        trailing: FlatButton(
          child: Text("START"),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SleepWidget()));
          },
        ),
      ),
      getLastSleepsData(),
    ]);
  }
}

class SleepWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SleepWidgetState();
  }
}

class SleepWidgetState extends State<SleepWidget> {
  List<List> sensorValuesList = [];
  List<List> derivativesList = [];
  List<List> timeStampList = [];
  List<double> _gyroscopeValues = [0, 0, 0];
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];
  DateTime lastGyro, lastAccel;
  List<charts.Series<List, DateTime>> data;
  DateTime started, ended;

  Future<Null> writeData(String data, String meta) async {
    print(data);
    final directory = await getApplicationDocumentsDirectory();
    final File file = File("${directory.path}/sleepData.csv");
    final File fileMeta = File("${directory.path}/sleepMeta.csv");
    fileMeta.writeAsString(meta);
    file.writeAsString(data);
  }

  endTracking() {
    ended = DateTime.now();
    if (sensorValuesList.length > 1) {
      List<List> distanceOnly = List.generate(derivativesList.length, (i) {
        return [
          derivativesList[i][0],
          (derivativesList[i][1]).reduce((a, b) {
            return a.abs() + b.abs();
          })
        ];
      });
      print(distanceOnly);
      print("Sorting");
      distanceOnly.sort((a, b) {
        return b[1].compareTo(a[1]);
      });
      distanceOnly.removeRange(0, (distanceOnly.length * 0.01).toInt());
      distanceOnly.sort((a, b) {
        return a[0].compareTo(b[0]);
      });
      print('sorted');
      print(distanceOnly[0]);
      double max = distanceOnly[0][1];
      double mean = 0;
      distanceOnly.forEach((i) {
        mean += i[1];
      });
      mean = mean / distanceOnly.length;
      print(mean);
      distanceOnly.forEach((pt) {
        if (pt[1] > max) {
          max = pt[1];
        }
      });
      Map<String, List> classified = Map();
      classified["rem"] = distanceOnly.where((pt) {
        return ((pt[1] - mean / max) > 0.5);
      }).toList();
      classified["deep"] = distanceOnly.where((pt) {
        return ((pt[1] / max) <= 0.5);
      }).toList();
      double score =
          classified["deep"].length * 1.0 + 0.5 * classified["rem"].length;
      print("sleep classified");
      writeData(
          csv.ListToCsvConverter()
              .convert(List.generate(derivativesList.length, (i) {
            return derivativesList[i].expand((x) {
              if (x is DateTime) {
                return [x];
              } else {
                return x;
              }
            }).toList();
          })),
          csv.ListToCsvConverter().convert([
            [
              started.toIso8601String(),
              ended.toIso8601String(),
              classified["deep"],
              classified["rem"],
              score
            ]
          ]));
    }
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  startTracking() {
    started = DateTime.now();
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      DateTime now = DateTime.now();
      if (now.difference(lastAccel).inSeconds > 1) {
        lastAccel = now;
        sensorValuesList.add([
          now,
          <double>[
            event.x,
            event.y,
            event.z,
            _gyroscopeValues[0] * 10,
            _gyroscopeValues[1] * 10,
            _gyroscopeValues[2] * 10
          ],
        ]);
        if (sensorValuesList.length > 1) {
          List der = List.generate(sensorValuesList[0][1].length, (i) {
            return (sensorValuesList[sensorValuesList.length - 1][1][i] -
                sensorValuesList[sensorValuesList.length - 2][1][i]);
          });
          derivativesList
              .add([sensorValuesList[sensorValuesList.length - 2][0], der]);
        }
        _gyroscopeValues = [0.0, 0.0, 0.0];
        setState(() {
          refreshData();
        });
      }
    }));
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      var _gyroscopeValuesTemp = <double>[event.x, event.y, event.z];
      if (_gyroscopeValuesTemp.reduce((a, b) => (a + b)) >
          _gyroscopeValues.reduce((a, b) => a + b)) {
        _gyroscopeValues = _gyroscopeValuesTemp;
      }
    }));
  }

  @override
  void initState() {
    super.initState();
    lastGyro = lastAccel = DateTime.now();
    refreshData();
    startTracking();
  }

  refreshData() {
    data = List.generate(6, (i) {
      return charts.Series<List, DateTime>(
        id: 'AccelData',
        domainFn: (List pt, _) => pt[0],
        measureFn: (List pt, _) => min((pt[1][i]).abs() as double, 1.0),
        data: derivativesList,
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: null,
        body: Card(
            child: Column(children: [
          ListTile(
            leading: Icon(Icons.wb_sunny),
            title: Text("End Sleep Tracking"),
            trailing: FlatButton(
              child: Text("STOP"),
              onPressed: () {
                setState(() {
                  endTracking();
                  Navigator.of(context).pop();
                });
              },
            ),
          ),
          Divider(),
          Text("Sleep Graph"),
          Container(
              constraints: BoxConstraints.tight(Size(
                  MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height * 0.7)),
              child: charts.TimeSeriesChart(
                data,
                animate: false,
              ))
        ])));
  }
}
