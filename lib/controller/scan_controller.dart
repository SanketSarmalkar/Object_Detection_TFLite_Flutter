import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanController extends GetxController {
  late CameraController cameraController;
  late List<CameraDescription> cameras;

  var isCameraReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    initCamera();
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
      await cameraController.initialize();
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
}
