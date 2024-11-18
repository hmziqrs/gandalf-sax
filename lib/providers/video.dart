import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

final videoControllerProvider =
    StateNotifierProvider<VideoControllerNotifier, VideoState>((ref) {
  return VideoControllerNotifier();
});

class VideoState {
  final VideoPlayerController? controller;
  final bool isPlaying;
  final bool isInitialized;
  final Duration currentPosition;
  final Duration totalDuration;
  final double volume;
  final bool isFirstSync;

  VideoState({
    this.controller,
    this.isPlaying = false,
    this.isInitialized = false,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.volume = 1.0,
    this.isFirstSync = true,
  });

  VideoState copyWith({
    VideoPlayerController? controller,
    bool? isPlaying,
    bool? isInitialized,
    Duration? currentPosition,
    Duration? totalDuration,
    double? volume,
    bool? isFirstSync,
  }) {
    return VideoState(
      controller: controller ?? this.controller,
      isPlaying: isPlaying ?? this.isPlaying,
      isInitialized: isInitialized ?? this.isInitialized,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      volume: volume ?? this.volume,
      isFirstSync: isFirstSync ?? this.isFirstSync,
    );
  }
}

class VideoControllerNotifier extends StateNotifier<VideoState> {
  VideoControllerNotifier() : super(VideoState());

  Future<void> initialize() async {
    final controller = VideoPlayerController.asset("assets/video.mp4");
    await controller.initialize();
    await controller.setLooping(true);
    await controller.seekTo(Duration(seconds: 0));

    state = state.copyWith(
      controller: controller,
      isInitialized: true,
      totalDuration: controller.value.duration,
    );
    if (!kIsWeb) {
      await syncVideo();
    } else {

    }
  }

  Future<void> syncVideo() async {
    if (!state.isInitialized) return;

    int currentTimeMicros = DateTime.now().toUtc().microsecondsSinceEpoch;
    int position = currentTimeMicros % state.totalDuration.inMicroseconds;
    int buffer = 55 + (state.isFirstSync ? 140 : 0);
    Duration seekPosition = Duration(microseconds: position + buffer);

    final beforeSeek = DateTime.now();
    await seekTo(seekPosition);
    final afterSeek = DateTime.now();
    debugPrint(
      'Seek took: ${afterSeek.difference(beforeSeek).inMilliseconds}ms',
    );
    final beforePlay = DateTime.now();
    await play();
    final afterPlay = DateTime.now();
    debugPrint(
      'Seek took: ${afterPlay.difference(beforePlay).inMilliseconds}ms',
    );
  }

  triggerFirstSync() {
    state = state.copyWith(isFirstSync: false);
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
