import 'package:equatable/equatable.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

sealed class VlcPlayerXState extends Equatable {
  const VlcPlayerXState();

  @override
  List<Object?> get props => [];
}

final class VlcPlayerXInitial extends VlcPlayerXState {
  const VlcPlayerXInitial();
}

final class VlcPlayerXLoading extends VlcPlayerXState {
  const VlcPlayerXLoading();
}

class VlcPlayerXLoaded extends VlcPlayerXState {
  final VlcPlayerController controller;
  final Duration position;
  final Duration duration;
  final double progress;
  final double volume;
  final bool isPlaying;

  const VlcPlayerXLoaded({
    required this.controller,
    required this.position,
    required this.duration,
    required this.progress,
    this.volume = 1.0,
    this.isPlaying = false,
  });

  VlcPlayerXLoaded copyWith({
    VlcPlayerController? controller,
    Duration? position,
    Duration? duration,
    double? progress,
    double? volume,
    bool? isPlaying,
  }) {
    return VlcPlayerXLoaded(
      controller: controller ?? this.controller,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      progress: progress ?? this.progress,
      volume: volume ?? this.volume,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  @override
  List<Object?> get props => [
    controller,
    position,
    duration,
    progress,
    volume,
    isPlaying,
  ];
}

class VlcPlayerXError extends VlcPlayerXState {
  final String error;

  const VlcPlayerXError({required this.error});

  @override
  List<Object?> get props => [error];
}