import 'package:flutter/material.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:provider/provider.dart';

import 'providers/IAP.dart';

import 'screens/Home/Home.dart';

class AppNavigator extends StatelessWidget {
  AppNavigator(this.observers);
  final List<NavigatorObserver> observers;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<IAPProvider>(
      create: (_) => IAPProvider(),
      child: MaterialApp(
        title: 'Epic Sax Gandalf Infinite',
        navigatorObservers: this.observers,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
      ),
    );
  }
}
