import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class Screen extends StatefulWidget {
  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  VideoPlayerController controller;
  Future<void> init;

  @override
  void initState() {
    this.controller = VideoPlayerController.asset("assets/video.mp4");
    this.controller.setLooping(true);
    this.init = this.controller.initialize();
    SystemChrome.setEnabledSystemUIOverlays([]);
    this.init.then((value) {
      this.controller.play();
    });
    super.initState();
  }

  @override
  void dispose() {
    this.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: VideoPlayer(this.controller),
          ),
          Positioned.fill(
            child: GestureDetector(
              onTap: () => this.controller.value.isPlaying
                  ? this.controller.pause()
                  : this.controller.play(),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
