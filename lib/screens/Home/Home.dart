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
  // late AdmobInterstitial interstitialAd;
  bool canClose = false;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    this.controller = VideoPlayerController.asset("assets/video.mp4");
    this.controller.setLooping(true);
    this.controller.initialize().then((value) {
      this.controller.play();
    });
    if (App.showAds) {
      // this.interstitialAd = AdmobInterstitial(
      //   adUnitId: Ads.fullScreen(),
      // );
    }
    super.initState();
  }

  @override
  void dispose() {
    this.controller.pause();
    this.controller.dispose();
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
