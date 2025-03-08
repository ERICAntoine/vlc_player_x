import 'package:equatable/equatable.dart';

class PlayerControlsState extends Equatable {
  final bool hideControls;
  final void Function()? onClose;


  const PlayerControlsState({required this.hideControls, this.onClose});

  PlayerControlsState copyWith({bool? hideControls, void Function()? onClose}) {
    return PlayerControlsState(
      hideControls: hideControls ?? this.hideControls,
      onClose: onClose ?? this.onClose,
    );
  }

  @override
  List<Object?> get props => [hideControls, onClose];
}