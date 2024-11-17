import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gandalf/providers/video.dart';
import 'package:gandalf/screens/Home/widgets/sheet.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    // Initialize video on widget creation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(videoControllerProvider.notifier).initialize();
    });

    super.initState();
  }

  void onTap() async {
    final videoController = ref.read(videoControllerProvider.notifier);
    await videoController.pause();
    await showMaterialModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return Sheet();
      },
    );
    await videoController.syncVideo();
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(videoControllerProvider);

    return PopScope(
      onPopInvokedWithResult: (flag, data) {
        ref.read(videoControllerProvider.notifier).pause();
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
                    videoState.controller!,
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
