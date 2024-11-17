import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:gandalf/providers/video.dart';
import 'package:gandalf/screens/Home/widgets/sheet.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
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

  void onTap() async {
    final video = VideoProvider.of(context);
    await video.pause();
    await showMaterialModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Sheet();
      },
    );
    await video.syncVideo();
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
                  child: VideoPlayer(
                    videoState.controller,
                  ),
              ),
              Positioned.fill(
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
