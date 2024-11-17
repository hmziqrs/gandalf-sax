import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gandalf/providers/app.dart';
import 'screens/Home/Home.dart';

import 'screens/Home/Home.dart';

class AppNavigator extends ConsumerWidget {
  AppNavigator(this.observers);
  final List<NavigatorObserver> observers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(appSettingsProvider);

    return MaterialApp(
      title: 'Epic Sax Gandalf Infinite',
      navigatorObservers: this.observers,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: appSettings.themeMode,
      home: HomeScreen(),
    );
  }
}
