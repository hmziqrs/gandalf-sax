import 'package:flutter/material.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:provider/provider.dart';

import 'providers/IAP.dart';

import 'screens/Home/Home.dart';

class AppNavigator extends StatelessWidget {
  AppNavigator(this.observer);
  final FirebaseAnalyticsObserver observer;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<IAPProvider>(
      create: (_) => IAPProvider(),
      child: MaterialApp(
        title: 'Epic Sax Gandalf Infinite',
        navigatorObservers: [this.observer],
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
      ),
    );
  }
}
