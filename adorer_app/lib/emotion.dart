import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:tflite/tflite.dart';

List<CameraDescription> cameras;

void launchDetect(BuildContext context) async {
  cameras = await availableCameras();
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => EmotionWidget()));
}

class EmotionWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EmotionWidgetState();
  }
}

class EmotionWidgetState extends State<EmotionWidget> {
  CameraController controller;
  String errorString = '';
  initCamera() async {
    cameras = await availableCameras();

    controller = CameraController(cameras.last, ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> takePicture() async {
    print("Cheese");
    if (!controller.value.isInitialized) {
      return;
    }
    final directory = await getApplicationDocumentsDirectory();
    if (controller.value.isTakingPicture) {
      return;
    }
    try {
      await controller.takePicture("${directory.path}/emotionPic.jpg");
      print("Snap!!");
    } on CameraException catch (e) {
      errorString = e.description;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Column(children: [
        CircularProgressIndicator(),
        Text("Please wait for the Camera to load"),
      ]);
    } else {
      return AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: GestureDetector(
            child: CameraPreview(controller),
            onTap: () {
              takePicture();
            },
          ));
    }
  }
}
