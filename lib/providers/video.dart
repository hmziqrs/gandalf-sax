import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

final videoControllerProvider = StateNotifierProvider<VideoControllerNotifier, VideoState>((ref) {
  return VideoControllerNotifier();
});

class VideoState {
  final VideoPlayerController? controller;
  final bool isPlaying;
  final bool isInitialized;
  final Duration currentPosition;
  final Duration totalDuration;
  final double volume;

  VideoState({
    this.controller,
    this.isPlaying = false,
    this.isInitialized = false,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.volume = 1.0,
  });

  VideoState copyWith({
    VideoPlayerController? controller,
    bool? isPlaying,
    bool? isInitialized,
    Duration? currentPosition,
    Duration? totalDuration,
    double? volume,
  }) {
    return VideoState(
      controller: controller ?? this.controller,
      isPlaying: isPlaying ?? this.isPlaying,
      isInitialized: isInitialized ?? this.isInitialized,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      volume: volume ?? this.volume,
    );
  }
}

class VideoControllerNotifier extends StateNotifier<VideoState> {
  VideoControllerNotifier() : super(VideoState());

  Future<void> initialize() async {
    final controller = VideoPlayerController.asset("assets/video.mp4");
    await controller.initialize();
    controller.setLooping(true);

    state = state.copyWith(
      controller: controller,
      isInitialized: true,
      totalDuration: controller.value.duration,
    );

    await syncVideo();
  }

  Future<void> syncVideo() async {
    if (!state.isInitialized) return;

    int currentTimeMicros = DateTime.now().toUtc().microsecondsSinceEpoch;
    int position = currentTimeMicros % state.totalDuration.inMicroseconds;
    Duration seekPosition = Duration(microseconds: position);

    await seekTo(seekPosition);
    await play();
  }

  Future<void> play() async {
    if (!state.isInitialized) return;
    await state.controller!.play();
    state = state.copyWith(isPlaying: true);
  }

  Future<void> pause() async {
    if (!state.isInitialized) return;
    await state.controller!.pause();
    state = state.copyWith(isPlaying: false);
  }

  Future<void> seekTo(Duration position) async {
    if (!state.isInitialized) return;
    await state.controller!.seekTo(position);
    state = state.copyWith(currentPosition: position);
  }

  Future<void> setVolume(double volume) async {
    if (!state.isInitialized) return;
    await state.controller!.setVolume(volume.clamp(0.0, 1.0));
    state = state.copyWith(volume: volume);
  }

  @override
  void dispose() {
    state.controller?.dispose();
    super.dispose();
  }
}
