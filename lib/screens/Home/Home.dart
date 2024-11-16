import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:gandalf/providers/video.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    // Initialize video on widget creation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VideoProvider.of(context).initialize();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final videoState = VideoProvider.of(context, true);
    return PopScope(
      onPopInvokedWithResult: (flag, data) {
        videoState.pause();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (videoState.isInitialized)
              Positioned.fill(
                  child: VideoPlayer(videoState.controller),
              ),
              Positioned.fill(
                child: Container(
                    // color: Colors.red,
                    ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
