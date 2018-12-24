import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part "activities.g.dart";

@JsonSerializable(nullable: true)
class Activity {
  String name;
  String description;
  List<List> data;
  Activity(this.name, this.description, this.data) {
    List<String> words = name.split(" ");
    List<String> capitalized = [];
    words.forEach((f) {
      if (f.length > 0) {
        capitalized.add(f[0].toUpperCase() + f.substring(1));
      } else {
        capitalized.add(f);
      }
    });
    this.name = capitalized.reduce((a, b) {
      return a + b;
    });
  }
  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainScreenState();
  }
}

class MainScreenState extends State<MainScreen> {
  List<Activity> sampleActivities = [];
  @override
  void initState() {
    super.initState();
    readData() async {
      final directory = await getApplicationDocumentsDirectory();
      if (FileSystemEntity.typeSync("${directory.path}/activitiesData.csv") ==
          FileSystemEntityType.notFound) {
        return;
      }
      print("reading");
      final File file = File("${directory.path}/activitiesData.csv");

      List data = CsvToListConverter().convert(await file.readAsString())[0];
      print(data.length);
      List<Activity> sampleActivitiesTemp =
          List<Activity>.generate(data.length, (i) {
        return Activity.fromJson(jsonDecode(data[i]));
      });

      sampleActivities.addAll(sampleActivitiesTemp);
      print("Read success");
      print("${sampleActivities[0].data}");
      setState(() {});
    }

    readData();
  }

  Future<bool> autoSaveData() async {
    final directory = await getApplicationDocumentsDirectory();
    final File file = File("${directory.path}/activitiesData.csv");
    await file.writeAsString("");
    print(sampleActivities.length); // empty the previous contents
    List jsonData = [];
    sampleActivities.forEach((act) async {
      if (act.data.isEmpty) {
        return;
      }
      jsonData.add(jsonEncode(act.toJson()));
    });
    file.writeAsString(ListToCsvConverter().convert([jsonData]));
    print("Saved successfully");
    return true;
  }

  Future<void> launchEditActivityDialog(Activity activity) async {
    String name, description;
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add new activity'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Name: "),
                TextField(
                  maxLength: 20,
                  controller: TextEditingController(text: activity.name),
                  onChanged: (myStr) {
                    name = myStr;
                  },
                ),
                Text("Description: "),
                TextField(
                  controller: TextEditingController(text: activity.description),
                  maxLength: 255,
                  onChanged: (myStr) {
                    description = myStr;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('DELETE'),
              onPressed: () async {
                if (sampleActivities.contains(activity)) {
                  sampleActivities.remove(activity);
                }
                await autoSaveData();
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('DONE'),
              onPressed: (name != null && description != null)
                  ? () async {
                      sampleActivities.remove(activity);
                      sampleActivities
                          .add(Activity(name, description, activity.data));
                      await autoSaveData();
                      setState(() {});
                      Navigator.of(context).pop();
                    }
                  : null,
            ),
          ],
        );
      },
    );
  }

  Future<void> launchAddActivityDialog() async {
    String name, description;
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add new activity'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Name: "),
                TextField(
                  maxLength: 20,
                  onChanged: (myStr) {
                    name = myStr;
                  },
                ),
                Text("Description: "),
                TextField(
                  maxLength: 255,
                  onChanged: (myStr) {
                    description = myStr;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('ADD'),
              onPressed: () async {
                if (name != null && description != null) {
                  sampleActivities.add(Activity(name, description, []));
                  setState(() {});
                  await autoSaveData();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> launchActivityDialog(Activity activity) async {
    DateTime dateAdded = DateTime.now();
    TimeOfDay timeBegan, timeEnded;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add activity'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  title: Text('Day:'),
                  trailing: Icon(Icons.date_range),
                  onTap: () async {
                    dateAdded = await showDatePicker(
                      context: context,
                      lastDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      initialDate: DateTime(DateTime.now().year,
                          DateTime.now().month, DateTime.now().day),
                    );
                  },
                ),
                ListTile(
                  title: Text('Begin:'),
                  trailing: Icon(Icons.date_range),
                  onTap: () async {
                    timeBegan = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {});
                  },
                ),
                ListTile(
                  title: Text('End:'),
                  trailing: Icon(Icons.date_range),
                  onTap: () async {
                    timeEnded = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('ADD'),
              onPressed: () async {
                if (timeBegan != null &&
                    timeEnded != null &&
                    dateAdded != null) {
                  activity.data.add([
                    dateAdded.toIso8601String(),
                    timeBegan.format(context),
                    timeEnded.format(context)
                  ]);
                  setState(() {});
                  await autoSaveData();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget getActivityWidget(Activity activity) {
    return ListTile(
      leading: Icon(Icons.check),
      title: Text("${activity.name}"),
      subtitle: Text("${activity.description}"),
      trailing: IconButton(
        icon: Icon(Icons.add_box),
        onPressed: () {
          launchActivityDialog(activity);
        },
      ),
      onLongPress: () {
        launchEditActivityDialog(activity);
      },
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ActivityScreen(activity)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (sampleActivities.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("My Activities")),
        drawer: Scaffold.of(context).widget.drawer,
        body: Center(
            child: Text("Add new activities",
                style: TextStyle(fontWeight: FontWeight.w300))),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            launchAddActivityDialog();
          },
        ),
      );
    } else {
      autoSaveData();
      return Scaffold(
          appBar: AppBar(title: Text("My Activities")),
          drawer: Scaffold.of(context).widget.drawer,
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              launchAddActivityDialog();
            },
          ),
          body: ListView(
            children: List.generate(sampleActivities.length, (i) {
              return getActivityWidget(sampleActivities[i]);
            }),
          ));
    }
  }
}

class ActivityScreen extends StatefulWidget {
  final Activity myActivity;
  ActivityScreen(this.myActivity);
  @override
  State<StatefulWidget> createState() {
    return ActivityScreenState(this.myActivity);
  }
}

class ActivityScreenState extends State<ActivityScreen> {
  Activity myActivity;
  ActivityScreenState(this.myActivity);

  Future<void> launchActivityDialog(Activity activity) async {
    DateTime dateAdded = DateTime.now();
    TimeOfDay timeBegan, timeEnded;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add activity'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  title: Text('Day:'),
                  trailing: Icon(Icons.date_range),
                  onTap: () async {
                    dateAdded = await showDatePicker(
                      context: context,
                      lastDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      initialDate: DateTime(DateTime.now().year,
                          DateTime.now().month, DateTime.now().day),
                    );
                  },
                ),
                ListTile(
                  title: Text('Begin:'),
                  trailing: Icon(Icons.date_range),
                  onTap: () async {
                    timeBegan = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {});
                  },
                ),
                ListTile(
                  title: Text('End:'),
                  trailing: Icon(Icons.date_range),
                  onTap: () async {
                    timeEnded = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('ADD'),
              onPressed: () async {
                if (timeBegan != null &&
                    timeEnded != null &&
                    dateAdded != null) {
                  activity.data.add([
                    dateAdded.toIso8601String(),
                    timeBegan.format(context),
                    timeEnded.format(context)
                  ]);
                  setState(() {});
                  //await autoSaveData();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget activityDescriptionWidget(Activity act) {
    List<Widget> entries = List<Widget>.generate(act.data.length, (i) {
      return ListTile(
        title: Text(act.data[i][0].toString().substring(0, 10)),
        subtitle: Text("Start ${act.data[i][1]}\tEnd ${act.data[i][2]}"),
        isThreeLine: true,
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            setState(() {
              act.data.removeAt(i);
            });
          },
        ),
      );
    });
    return ListView(
      children: entries,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(myActivity.name),
      ),
      body: activityDescriptionWidget(myActivity),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          launchActivityDialog(myActivity);
        },
      ),
    );
  }
}
