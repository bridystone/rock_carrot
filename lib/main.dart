import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart'; // for runApp

import 'package:yacguide_flutter/main_cupertino.dart';
import 'package:yacguide_flutter/main_material.dart';

void main() {
  try {
    // Platform is not working on Web
    if (Platform.isAndroid) {
      runApp(YacGuideFlutterMaterial());
      return;
    }
    if (Platform.isIOS) {
      runApp(YacGuideFlutterCupertino());
      return;
    }
  } catch (e) {}
  print("not a supported platform");
}
