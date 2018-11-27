import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'dart:async';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:path_provider/path_provider.dart';
import 'dart:core';
import 'dart:io';
import 'package:csv/csv.dart' as csv;

class SleepWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SleepWidgetState();
  }
}

class SleepWidgetState extends State<SleepWidget> {
  final List<List> sensorData = [
    [DateTime(2018, 9, 19), 5],
    [DateTime(2018, 9, 20), 15],
    [DateTime(2018, 9, 21), 5],
    [DateTime(2018, 9, 22), 25],
  ];
  List<List> _accelerometerValuesList = [];
  List<double> _gyroscopeValues = [0, 0, 0];
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];
  DateTime lastGyro, lastAccel;
  List<charts.Series<List, DateTime>> data, data1;
  bool _sleeping = false;
  bool get sleeping {
    return _sleeping;
  }
  DateTime started, ended;

  set sleeping(value) {
    _sleeping = value;
    if (value) {
      startTracking();
    }
  }
  Future<Null> writeData(String data, String meta) async{
    final directory = await getApplicationDocumentsDirectory();
    final File file = File("${directory.path}/sleepData.csv");
    print("saving in ${directory.path}");
    final File fileMeta = File("${directory.path}/sleepMeta.csv");
    fileMeta.writeAsString(meta);
    file.writeAsString(data);
  }

  endTracking(){
    ended = DateTime.now();
    writeData(csv.ListToCsvConverter().convert(List.generate(_accelerometerValuesList.length, (i){
      return _accelerometerValuesList.expand((x) => x).toList();
    })),"");
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }

  }

  startTracking() {
    started = DateTime.now();
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      DateTime now = DateTime.now();
      if (now.difference(lastAccel).inSeconds > 5) {
        lastAccel = now;
        _accelerometerValuesList.add([
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
    sleeping = false;
    lastGyro = lastAccel = DateTime.now();
    refreshData();
  }

  refreshData() {
    data = List.generate(6, (i) {
      return charts.Series<List, DateTime>(
        id: 'AccelData',
        domainFn: (List pt, _) => pt[0],
        measureFn: (List pt, _) => pt[1][i],
        data: _accelerometerValuesList,
      );
    });
    /* 
    data..addAll(List.generate(1, (i){
      return charts.Series<List, DateTime>(
        id: 'GyroData',
        domainFn: (List pt, _) => pt[0],
        measureFn: (List pt, _) => pt[1][i],
        data: _gyroscopeValues,
      );
    })); */
    /* data = [
      charts.Series<List, DateTime>(
        id: 'AccelData',
        domainFn: (List pt, _) => pt[0],
        measureFn: (List pt, _) => (pt[1][0] + pt[1][1] + pt[1][2])/3,
        data: _accelerometerValuesList,
      ),
    ]; */
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
    if (sleeping == true) {
      return Card(
          child: Column(children: [
        ListTile(
          leading: Icon(Icons.wb_sunny),
          title: Text("End Sleep Tracking"),
          trailing: FlatButton(
            child: Text("STOP"),
            onPressed: () {
              setState(() {
                endTracking();
                sleeping = false;
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
      ]));
    } else {
      return ListTile(
        leading: Icon(Icons.hotel),
        title: Text("Begin Sleep Tracking"),
        trailing: FlatButton(
          child: Text("START"),
          onPressed: () {
            print(sleeping);
            setState(() {
              sleeping = true;
            });
          },
        ),
      );
    }
  }
}
