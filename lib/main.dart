import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import './Screen.dart';

void main() {
  final analyticsObeserver =
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics());

  FlutterError.onError = (FlutterErrorDetails err) {
    Crashlytics.instance.recordFlutterError(err);
  };

  runApp(MyApp(analyticsObeserver));
}

class MyApp extends StatelessWidget {
  MyApp(this.observer);
  final FirebaseAnalyticsObserver observer;

  @override
  Widget build(BuildContext context) {
    this.observer.analytics.logEvent(name: "APP_LAUNCH");
    return MaterialApp(
      title: 'Epic Sax Gandalf Infinite',
      navigatorObservers: [this.observer],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Screen(),
      ),
    );
  }
}
