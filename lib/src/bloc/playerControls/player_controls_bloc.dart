import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vlc_player_x/src/bloc/playerControls/player_controls_event.dart';
import 'package:vlc_player_x/src/bloc/playerControls/player_controls_state.dart';

class PlayerControlsBloc extends Bloc<PlayerControlsEvent, PlayerControlsState> {
  PlayerControlsBloc() : super(const PlayerControlsState(hideControls: true)) {
    on<ShowControls>((event, emit) => emit(PlayerControlsState(hideControls: false, onClose: state.onClose)));
    on<HideControls>((event, emit) => emit(PlayerControlsState(hideControls: true, onClose: state.onClose)));
    on<ToggleControls>((event, emit) => emit(state.copyWith(hideControls: !state.hideControls)));
    on<SetOnClose>((event, emit) => emit(state.copyWith(onClose: event.onClose)));
  }
}
