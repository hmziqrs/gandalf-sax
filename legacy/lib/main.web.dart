import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gandalf/configs/app.dart';
import 'package:gandalf/firebase_options.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';

import 'Navigator.dart';
import 'services/analytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web,
  );
  Analytics.initialize(
    firebaseAnalytics: FirebaseAnalytics.instance,
  );

  VideoPlayerMediaKit.ensureInitialized(
    web: false,
  );

  App.showAds = false;

  runApp(ProviderScope(
    child: AppNavigator([
      FirebaseAnalyticsObserver(
        analytics: FirebaseAnalytics.instance,
      ),
    ]),
  ));
}
