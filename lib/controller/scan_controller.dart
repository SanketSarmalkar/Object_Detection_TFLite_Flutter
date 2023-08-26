import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanController extends GetxController {
  late CameraController cameraController;
  late List<CameraDescription> cameras;
  late CameraImage cameraImage;

  var isCameraReady = false.obs;
  var cameraCount = 0;

  @override
  void onInit() {
    super.onInit();
    initCamera();
    initTflite();
  }

  @override
  void onClose() {
    super.onClose();
    cameraController.dispose();
  }

  initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();
      cameraController = CameraController(cameras[0], ResolutionPreset.max);
      await cameraController.initialize().then((value) {
        cameraController.startImageStream((image) {
          cameraCount++;
          if (cameraCount % 100 == 0) {
            cameraCount = 0;
            objectDetecter(image);
          }
        });
      });
      isCameraReady.value = true;
      update();
    } else {
      Get.snackbar(
        'Camera Permission',
        'Please grant camera permission to use the app',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.camera_alt),
      );
    }
  }

  initTflite() async {
    var res = await Tflite.loadModel(
      model: 'assets/model.tflite',
      labels: 'assets/labels.txt',
      isAsset: true,
      numThreads: 1,
      useGpuDelegate: false,
    );
    debugPrint('Result: $res');
  }

  objectDetecter(CameraImage image) async {
    debugPrint("First Holla");
    var detector = await Tflite.runModelOnFrame(
        bytesList: image.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 1,
        threshold: 0.4,
        asynch: true);
    debugPrint("HOlla");
    if (detector != null) {
      debugPrint('Detector: $detector');
    }
  }
}
