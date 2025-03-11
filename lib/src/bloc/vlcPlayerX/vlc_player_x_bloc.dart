import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vlc_player_x/src/bloc/vlcPlayerX/vlc_player_x_event.dart';
import 'package:vlc_player_x/src/bloc/vlcPlayerX/vlc_player_x_state.dart';
import 'package:volume_controller/volume_controller.dart';


class VlcPlayerXBloc extends Bloc<VlcPlayerXEvent, VlcPlayerXState> {
  VlcPlayerXBloc() : super(VlcPlayerXLoading()) {
    on<VlcPlayerXInitialize>(_onInitialize);
    on<VlcPlayerXProgressChanged>(_onProgressChanged);
    on<VlcPlayerXSeekRequested>(_onSeekRequested);
    on<VlcPlayerXVolumeChangeStarted>(_onVolumeChangeStarted);
    on<VlcPlayerXVolumeChanged>(_onVolumeChanged);
    on<VlcPlayerXVolumeChangeEnded>(_onVolumeChangeEnded);
    on<VlcPlayerXPlayingStateChanged>(_onPlayingStateChanged);
  }

  Future<void> _onInitialize(
      VlcPlayerXInitialize event, Emitter<VlcPlayerXState> emit) async {
    try {
      final controller = event.controller;
      final volumeInstance = VolumeController.instance;
      final isMobile = Platform.isAndroid || Platform.isIOS;
      final initialVolume = isMobile ? await VolumeController.instance.getVolume() : (await controller.getVolume())!.toDouble() / 100.0;

      if(isMobile) {
        VolumeController.instance.showSystemUI = false;

        volumeInstance.addListener((double volume) {
          if (state is VlcPlayerXLoaded && (state as VlcPlayerXLoaded).isUserAdjustingVolume) {
            return;
          }
          add(VlcPlayerXVolumeChanged(volume: volume));
        });
      }
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
        volumeController: volumeInstance
      ));
    } catch (error, stackTrace) {
      debugPrint("Error initializing VLC Player: $error\n$stackTrace");
      emit(VlcPlayerXError(error: "Failed to initialize VLC player: $error"));
    }
  }

  Future<void> _onVolumeChangeStarted(
      VlcPlayerXVolumeChangeStarted event, Emitter<VlcPlayerXState> emit) async {
    final currentState = state;
    if (currentState is VlcPlayerXLoaded) {
      emit(currentState.copyWith(isUserAdjustingVolume: true));
    }
  }

  Future<void> _onVolumeChanged(
      VlcPlayerXVolumeChanged event, Emitter<VlcPlayerXState> emit) async {
    final currentState = state;
    if (currentState is VlcPlayerXLoaded) {
      try {
        final volumeValue = (event.volume * 100).round();
        final isMobile = Platform.isAndroid || Platform.isIOS;

        if (isMobile && currentState.volumeController != null) {
          await currentState.volumeController!.setVolume(event.volume);
        } else {
          await currentState.controller.setVolume(volumeValue);
        }

        emit(currentState.copyWith(volume: event.volume));
      } catch (error, stackTrace) {
        debugPrint("Error changing volume: $error\n$stackTrace");
        emit(VlcPlayerXError(error: "Failed to change volume: $error"));
      }
    }
  }

  Future<void> _onVolumeChangeEnded(
      VlcPlayerXVolumeChangeEnded event, Emitter<VlcPlayerXState> emit) async {
    final currentState = state;
    if (currentState is VlcPlayerXLoaded) {
      emit(currentState.copyWith(isUserAdjustingVolume: false));
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

        debugPrint("Progress: $progress");
        if (emit.isDone) return;

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
        final newPosition = Duration(milliseconds: newPositionMillis);
        final isPlaying = currentState.controller.value.isPlaying;

        if (currentState.controller.value.isEnded) {
          await currentState.controller.stop();
          await currentState.controller.seekTo(newPosition);
          await currentState.controller.play();
        } else if(!isPlaying){
          await currentState.controller.play();
          await currentState.controller.seekTo(newPosition);
          await currentState.controller.pause();
        } else {
          await currentState.controller.seekTo(newPosition);

        }

        add(VlcPlayerXProgressChanged());
      } catch (error, stackTrace) {
        debugPrint("Error seeking video: $error\n$stackTrace");
        emit(VlcPlayerXError(error: "Failed to seek video: $error"));
      }
    }
  }
}

