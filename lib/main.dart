import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart'; // for runApp

import 'package:rock_carrot/main_cupertino.dart';
import 'package:rock_carrot/main_material.dart';

void main() {
  try {
    // Platform is not working on Web
    if (Platform.isAndroid) {
      runApp(RockCarrotMaterial());
      return;
    }
    if (Platform.isIOS) {
      runApp(RockCarrotMaterial());
      //runApp(RockCarrotCupertino());
      return;
    }
  } catch (e) {
    throw Exception(e);
  }
  print('not a supported platform');
}
