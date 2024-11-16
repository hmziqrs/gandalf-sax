import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VideoPlayerController controller;
  late int videoDurationMicros;

  Future<void> syncVideo() async {
    // Get current UTC timestamp in microseconds
    int currentTimeMicros = DateTime.now().toUtc().microsecondsSinceEpoch;

    // Calculate the position where video should be playing
    int position = currentTimeMicros % videoDurationMicros;

    // Convert to Duration
    Duration seekPosition = Duration(microseconds: position);

    // Seek to calculated position and play
    await controller.seekTo(seekPosition);
    await controller.play();
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    controller = VideoPlayerController.asset("assets/video.mp4");
    controller.setLooping(true);

    controller.initialize().then((value) async {
      videoDurationMicros = controller.value.duration.inMicroseconds;
      if (!kIsWeb) {
        syncVideo();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    controller.pause();
    controller.dispose();
    super.dispose();
  }



  onTap(BuildContext context) async {
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (flag, data) {
        controller.pause();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: VideoPlayer(controller),
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
