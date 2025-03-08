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

class VlcPlayerXVolumeChanged extends VlcPlayerXEvent {
  final double volume;

  VlcPlayerXVolumeChanged(this.volume);
}

class VlcPlayerXPlayingStateChanged extends VlcPlayerXEvent {
  final bool isPlaying;
  VlcPlayerXPlayingStateChanged(this.isPlaying);
}


class VlcPlayerDispose extends VlcPlayerXEvent {}