import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gandalf/services/performace.dart';
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

  final _perf = FirebasePerformanceMonitoring();

  Future<void> initialize() async {
    await _perf.trace(
      name: 'video_initialization',
      operation: (trace) async {
        final controller = VideoPlayerController.asset("assets/video.mp4");

        await trace.timeOperation(
          name: 'init',
          operation: () => controller.initialize(),
        );

        await trace.timeOperation(
          name: 'loop_setup',
          operation: () => controller.setLooping(true),
        );

        await trace.timeOperation(
          name: 'initial_seek',
          operation: () => controller.seekTo(Duration.zero),
        );

        state = state.copyWith(
          controller: controller,
          isInitialized: true,
          totalDuration: controller.value.duration,
        );

        if (!kIsWeb) {
          await trace.timeOperation(
            name: 'initial_sync_video',
            operation: () => syncVideo(),
          );
        }
      },
    );
  }

  Future<void> syncVideo() async {
    if (!state.isInitialized) return;

    await _perf.trace(
      name: 'video_sync',
      attributes: {'is_first_sync': state.isFirstSync.toString()},
      operation: (trace) async {
        int currentTimeMicros = DateTime.now().toUtc().microsecondsSinceEpoch;
        int position = currentTimeMicros % state.totalDuration.inMicroseconds;
        int buffer = 25 + (state.isFirstSync ? 140 : 0);
        Duration seekPosition = Duration(microseconds: position + buffer);

        // Track seek operation
        trace.timeOperation(
          name: 'sync_seek_time',
          operation: () => seekTo(seekPosition),
        );

        // Track play operation
        trace.timeOperation(
          name: 'sync_play_time',
          operation: () => play(),
        );

        return;
      },
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
