import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gandalf/Utils.dart';
import 'package:gandalf/configs/app.dart';
import 'package:gandalf/firebase_options.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';

import 'Navigator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  VideoPlayerMediaKit.ensureInitialized(
    web: false,
    linux: false,
    windows: false,
    android: true,
    iOS: true,
    macOS: true,
  );

  App.showAds = Utils.isMobile();
  if (App.showAds) {
    await MobileAds.instance.initialize();
  }

  if (Utils.isMobile()) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  FlutterError.onError = (FlutterErrorDetails err) {
    FirebaseCrashlytics.instance.recordFlutterError(err);
  };

  runApp(ProviderScope(
    child: AppNavigator([
      FirebaseAnalyticsObserver(
        analytics: FirebaseAnalytics.instance,
      ),
    ]),
  ));
}
