import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:video_player/video_player.dart';

import 'package:gandalf/Ads.dart';

import 'package:gandalf/screens/Home/widgets/BottomSheet.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  VideoPlayerController controller;
  AdmobInterstitial interstitialAd;
  bool canClose = false;

  @override
  void initState() {
    this.interstitialAd = AdmobInterstitial(
      adUnitId: Ads.fullScreen(),
    );
    SystemChrome.setEnabledSystemUIOverlays([]);
    this.controller = VideoPlayerController.asset("assets/video.mp4");
    this.controller.setLooping(true);
    this.controller.initialize().then((value) {
      this.controller.play();
    });
    super.initState();
  }

  @override
  void dispose() {
    this.controller.pause();
    this.controller.dispose();
    super.dispose();
  }

  loadAdd() {
    this.interstitialAd.load();
    setState(
      () {
        this.canClose = true;
      },
    );
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

    this.controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        this.controller.pause();
        this.loadAdd();

        return this.canClose;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: VideoPlayer(this.controller),
              ),
              Builder(
                builder: (context) {
                  return Positioned.fill(
                    child: GestureDetector(
                      onTap: () => this.onTap(context),
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
