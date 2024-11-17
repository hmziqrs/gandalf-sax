import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gandalf/Utils.dart';
import 'package:gandalf/configs/app.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';

import 'Navigator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  VideoPlayerMediaKit.ensureInitialized(
    android: true,
    iOS: true,
    macOS: true,
    windows: true,
    linux: true,
  );

  App.showAds = Utils.isMobile();

  runApp(ProviderScope(child: AppNavigator([])));
}
