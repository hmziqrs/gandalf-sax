import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoProvider extends ChangeNotifier {
  static VideoProvider of(BuildContext context, [bool listen = false]) {
    return Provider.of<VideoProvider>(context, listen: listen);
  }

  late VideoPlayerController _controller;
  late int _videoDurationMicros;
  bool _isPlaying = false;
  bool _isInitialized = false;

  VideoPlayerController get controller => _controller;
  bool get isPlaying => _isPlaying;
  bool get isInitialized => _isInitialized;
  Duration get currentPosition => _controller.value.position;
  Duration get totalDuration => _controller.value.duration;
  double get volume => _controller.value.volume;

  Future<void> initialize() async {
    _controller = VideoPlayerController.asset("assets/video.mp4");
    _controller.setLooping(true);

    await _controller.initialize();
    _videoDurationMicros = _controller.value.duration.inMicroseconds;

    _isInitialized = true;
    notifyListeners();

    if (!kIsWeb) {
      await syncVideo();
    }
  }

  Future<void> syncVideo() async {
    int currentTimeMicros = DateTime.now().toUtc().microsecondsSinceEpoch;
    int position = currentTimeMicros % _videoDurationMicros;
    Duration seekPosition = Duration(microseconds: position);

    await seekTo(seekPosition);
    await play();
  }

  Future<void> play() async {
    await _controller.play();
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> pause() async {
    await _controller.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> seekTo(Duration position) async {
    await _controller.seekTo(position);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    await _controller.setVolume(volume.clamp(0.0, 1.0));
    notifyListeners();
  }

  void dispose() {
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }
}
