import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'Navigator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Admob.initialize();
  // Admob.initialize(testDeviceIds: ['2FE9795DC4B7FF43E68A607C2D50ED53']);

  InAppPurchaseConnection.enablePendingPurchases();

  final analyticsObserver =
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics());

  FlutterError.onError = (FlutterErrorDetails err) {
    Crashlytics.instance.recordFlutterError(err);
  };

  runApp(AppNavigator(analyticsObserver));
}
