import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gandalf/configs/app.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';

import 'Navigator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  App.showAds = false;
  VideoPlayerMediaKit.ensureInitialized(
    linux: true,
    windows: true,
    web: false,
    
    android: false,
    iOS: false,
    macOS: false,
  );


  runApp(ProviderScope(child: AppNavigator([])));
}
