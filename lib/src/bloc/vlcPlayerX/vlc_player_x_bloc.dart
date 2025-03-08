import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vlc_player_x/src/bloc/vlcPlayerX/vlc_player_x_event.dart';
import 'package:vlc_player_x/src/bloc/vlcPlayerX/vlc_player_x_state.dart';


class VlcPlayerXBloc extends Bloc<VlcPlayerXEvent, VlcPlayerXState> {
  VlcPlayerXBloc() : super(VlcPlayerXLoading()) {
    on<VlcPlayerXInitialize>(_onInitialize);
    on<VlcPlayerXProgressChanged>(_onProgressChanged);
    on<VlcPlayerXSeekRequested>(_onSeekRequested);
    on<VlcPlayerXVolumeChanged>(_onVolumeChanged);
    on<VlcPlayerXPlayingStateChanged>(_onPlayingStateChanged);
  }

  Future<void> _onInitialize(
      VlcPlayerXInitialize event, Emitter<VlcPlayerXState> emit) async {
    try {
      final controller = event.controller;
      final initialVolumeInt = await controller.getVolume();
      final initialVolume = initialVolumeInt! / 100.0;

      controller.addListener(() {
        if (!isClosed) {
          add(VlcPlayerXPlayingStateChanged(controller.value.isPlaying));
        }
      });

      Timer.periodic(const Duration(milliseconds: 500), (timer) async {
        if (isClosed) {
          timer.cancel();
          return;
        }

        if (controller.value.isInitialized) {
          add(VlcPlayerXProgressChanged());
        }
      });


      emit(VlcPlayerXLoaded(
        controller: controller,
        position: Duration.zero,
        duration: Duration.zero,
        progress: 0.0,
        volume: initialVolume,
        isPlaying: controller.value.isPlaying,
      ));
    } catch (error, stackTrace) {
      debugPrint("Error initializing VLC Player: $error\n$stackTrace");
      emit(VlcPlayerXError(error: "Failed to initialize VLC player: $error"));
    }
  }

  Future<void> _onVolumeChanged(
      VlcPlayerXVolumeChanged event, Emitter<VlcPlayerXState> emit) async {
    final currentState = state;
    if (currentState is VlcPlayerXLoaded) {
      try {
        final volumeValue = (event.volume * 100).round();

        await currentState.controller.setVolume(volumeValue);

        // emit(VlcPlayerXLoaded(
        //   controller: currentState.controller,
        //   position: currentState.position,
        //   duration: currentState.duration,
        //   progress: currentState.progress,
        //   volume: event.volume,
        //   isPlaying: currentState.isPlaying,
        // ));
        emit(currentState.copyWith(volume: event.volume));

      } catch (error, stackTrace) {
        debugPrint("Error changing volume: $error\n$stackTrace");
        emit(VlcPlayerXError(error: "Failed to change volume: $error"));
      }
    }
  }

  Future<void> _onProgressChanged(
      VlcPlayerXProgressChanged event, Emitter<VlcPlayerXState> emit) async {
    final currentState = state;
    if (currentState is VlcPlayerXLoaded) {
      if (!currentState.controller.value.isInitialized) {
        return;
      }

      try {
        final position = await currentState.controller.getPosition();
        final duration = await currentState.controller.getDuration();

        final progress = duration.inMilliseconds > 0
            ? position.inMilliseconds / duration.inMilliseconds
            : 0.0;

        if (emit.isDone) return;

        // emit(VlcPlayerXLoaded(
        //   controller: currentState.controller,
        //   position: position,
        //   duration: duration,
        //   progress: progress,
        //   volume: currentState.volume,
        // ));
        emit(currentState.copyWith(
          position: position,
          duration: duration,
          progress: progress,
        ));
      } catch (error, stackTrace) {
        debugPrint("Error updating progress: $error\n$stackTrace");
        emit(VlcPlayerXError(error: "Failed to update video progress: $error"));
      }
    }
  }

  Future<void> _onPlayingStateChanged(
      VlcPlayerXPlayingStateChanged event, Emitter<VlcPlayerXState> emit) async {
    final currentState = state;
    if (currentState is VlcPlayerXLoaded) {
      if (currentState.isPlaying == event.isPlaying) return;

      // emit(VlcPlayerXLoaded(
      //   controller: currentState.controller,
      //   position: currentState.position,
      //   duration: currentState.duration,
      //   progress: currentState.progress,
      //   volume: currentState.volume,
      //   isPlaying: event.isPlaying,
      // ));

      try {
        emit(currentState.copyWith(isPlaying: event.isPlaying));
      } catch (e, stackTrace) {
        debugPrint("Error updating playing state: $e\n$stackTrace");
        emit(VlcPlayerXError(error: "Failed to update playing state: $e"));
      }
    }
  }

  Future<void> _onSeekRequested(
      VlcPlayerXSeekRequested event, Emitter<VlcPlayerXState> emit) async {
    final currentState = state;
    if (currentState is VlcPlayerXLoaded) {
      try {
        final duration = await currentState.controller.getDuration();
        final newPositionMillis = (duration.inMilliseconds * event.progress).toInt();

        if (currentState.controller.value.isEnded) {
          await currentState.controller.stop();
          await currentState.controller.seekTo(Duration(milliseconds: newPositionMillis));
          await currentState.controller.play();
        } else {
          await currentState.controller.seekTo(Duration(milliseconds: newPositionMillis));
        }

        add(VlcPlayerXProgressChanged());
      } catch (error, stackTrace) {
        debugPrint("Error seeking video: $error\n$stackTrace");
        emit(VlcPlayerXError(error: "Failed to seek video: $error"));
      }
    }
  }
}
