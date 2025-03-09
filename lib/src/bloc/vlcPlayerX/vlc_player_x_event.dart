import 'package:flutter_vlc_player/flutter_vlc_player.dart';

sealed class VlcPlayerXEvent {}

class VlcPlayerXInitialize extends VlcPlayerXEvent {
  final VlcPlayerController controller;
  VlcPlayerXInitialize(this.controller);
}

class VlcPlayerXProgressChanged extends VlcPlayerXEvent {
  VlcPlayerXProgressChanged();
}
class VlcPlayerXSeekRequested extends VlcPlayerXEvent {
  final double progress;
  VlcPlayerXSeekRequested(this.progress);
}

class VlcPlayerXVolumeChangeStarted extends VlcPlayerXEvent {}

class VlcPlayerXVolumeChanged extends VlcPlayerXEvent {
  final double volume;

  VlcPlayerXVolumeChanged({required this.volume});
}

class VlcPlayerXVolumeChangeEnded extends VlcPlayerXEvent {}

class VlcPlayerXPlayingStateChanged extends VlcPlayerXEvent {
  final bool isPlaying;
  VlcPlayerXPlayingStateChanged(this.isPlaying);
}

class VlcPlayerDispose extends VlcPlayerXEvent {}