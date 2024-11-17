import 'package:flutter/material.dart';
import 'package:gandalf/providers/app.dart';
import 'package:gandalf/providers/video.dart';
import 'package:provider/provider.dart';


import 'screens/Home/Home.dart';

class AppNavigator extends StatelessWidget {
  AppNavigator(this.observers);
  final List<NavigatorObserver> observers;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Epic Sax Gandalf Infinite',
      navigatorObservers: this.observers,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => VideoProvider()),
          ChangeNotifierProvider(create: (_) => AppProvider()),
        ],
        child: HomeScreen(),
      ),
    );
  }
}
