import 'package:camera/camera.dart';

class Cameras {
  static late List<CameraDescription> list;

  static Future<void> init() async {
    list = await availableCameras();
  }
}
