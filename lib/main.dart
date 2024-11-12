import 'package:flutter/material.dart';
import 'package:gandalf/Utils.dart';
import 'package:gandalf/configs/app.dart';

import 'Navigator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  App.showAds = Utils.isMobile();



  runApp(AppNavigator([]));
}
