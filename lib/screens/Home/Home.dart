import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:gandalf/configs/app.dart';
import 'package:video_player/video_player.dart';

import 'package:gandalf/screens/Home/widgets/BottomSheet.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VideoPlayerController controller;
  bool canClose = false;

  // Video duration in microseconds
  late int videoDurationMicros;

  Future<void> syncVideo() async {
    // Get current UTC timestamp in microseconds
    int currentTimeMicros = DateTime.now().toUtc().microsecondsSinceEpoch;
    print("Suncing video $currentTimeMicros ");

    // Calculate the position where video should be playing
    int position = currentTimeMicros % videoDurationMicros;

    // Convert to Duration
    Duration seekPosition = Duration(microseconds: position);
    print("seek: $seekPosition ${seekPosition.inSeconds}");
    print("Position: $position current: ${controller.value.position}");

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

  loadAdd() {
    setState(
      () {
        this.canClose = true;
      },
    );
    if (!App.showAds) return;
    // this.interstitialAd.load();
  }

  onTap(BuildContext context) async {
    this.controller.pause();
    final sheet = showBottomSheet(
      backgroundColor: Colors.black.withOpacity(0.11),
      context: context,
      builder: (ctx) {
        return HomeBottomSheet();
      },
    );

    await sheet.closed;

    syncVideo();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.pause();
        loadAdd();
        return canClose;
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
              Builder(
                builder: (context) {
                  return Positioned.fill(
                    child: GestureDetector(
                      onTap: () => onTap(context),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
