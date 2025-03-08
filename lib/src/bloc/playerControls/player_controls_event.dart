import 'package:equatable/equatable.dart';

abstract class PlayerControlsEvent extends Equatable {
  const PlayerControlsEvent();

  @override
  List<Object?> get props => [];
}

class ShowControls extends PlayerControlsEvent {}

class HideControls extends PlayerControlsEvent {}

class ToggleControls extends PlayerControlsEvent {}

class SetOnClose extends PlayerControlsEvent {
  final void Function()? onClose;

  const SetOnClose(this.onClose);

  @override
  List<Object?> get props => [onClose];
}