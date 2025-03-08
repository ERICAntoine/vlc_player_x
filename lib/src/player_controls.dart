import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:vlc_player_x/src/bloc/playerControls/player_controls_bloc.dart';
import 'package:vlc_player_x/src/bloc/playerControls/player_controls_event.dart';
import 'package:vlc_player_x/src/bloc/playerControls/player_controls_state.dart';
import 'package:vlc_player_x/src/bloc/vlcPlayerX/vlc_player_x_bloc.dart';
import 'package:vlc_player_x/src/bloc/vlcPlayerX/vlc_player_x_event.dart';
import 'package:vlc_player_x/src/bloc/vlcPlayerX/vlc_player_x_state.dart';
import 'package:vlc_player_x/src/components/volume.dart';
import 'package:vlc_player_x/src/components/play_pause.dart';
import 'package:vlc_player_x/src/components/progress_bar.dart';
import 'dart:math' as math;

/// [PlayerControls] is a customizable video control overlay for VLC Player.
///
/// This widget handles:
/// - **Play/Pause functionality**
/// - **Skipping forward/backward**
/// - **Volume control**
/// - **Progress bar for seeking**
/// - **Auto-hide feature for better UX**
class PlayerControls extends StatefulWidget {
  const PlayerControls({
    super.key,
  });

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  /// Timer to automatically hide controls after a few seconds of inactivity.
  Timer? _hideControlsTimer;

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  /// Resets the auto-hide timer and ensures the controls are visible.
  ///
  /// This is triggered when the user interacts with the screen.
  void _resetHideControlsTimer(PlayerControlsBloc bloc) {
    _hideControlsTimer?.cancel();
    bloc.add(ShowControls());
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      bloc.add(HideControls());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (_) => _resetHideControlsTimer(context.read<PlayerControlsBloc>()),
      child: GestureDetector(
          onTap: () {
            final bloc = context.read<PlayerControlsBloc>();
            _resetHideControlsTimer(bloc);
          },
          child: AbsorbPointer(
            absorbing: context.watch<PlayerControlsBloc>().state.hideControls,
            child: BlocBuilder<PlayerControlsBloc, PlayerControlsState>(
              builder: (context, state) {
                return AnimatedOpacity(
                  opacity: state.hideControls ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: _buildControls(),
                  ),
                );
              },
            ),
          )
      ),
    );
  }

  /// Skips the video backward by 10 seconds.
  Future<void> _skipBack(VlcPlayerController controller) async {
    double selectedSpeed = 1.0;
    final position = await controller.getPosition();
    const beginning = 0;
    final skip = (position - const Duration(seconds: 10)).inMilliseconds;
    final newPosition = Duration(milliseconds: math.max(skip, beginning));
    await controller.seekTo(newPosition);
    Future.delayed(const Duration(milliseconds: 1000), () {
      controller.setPlaybackSpeed(selectedSpeed);
    });
  }

  /// Builds the skip back button.
  GestureDetector _buildSkipBack(VlcPlayerController controller) {
    return GestureDetector(
      onTap: () => _skipBack(controller),
      child: Container(
        color: Colors.transparent,
        margin: const EdgeInsets.only(left: 10.0),
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: Icon(
          CupertinoIcons.gobackward_10,
          color: Colors.white,
          size: 36.0,
        ),
      ),
    );
  }

  /// Toggles play/pause state of the video.
  void _playPause(VlcPlayerController controller) {
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  /// Skips the video forward by 10 seconds.
  Future<void> _skipForward(VlcPlayerController controller) async {
    double selectedSpeed = 1.0;
    final duration = await controller.getDuration();
    final position = await controller.getPosition();
    final end = duration.inMilliseconds;
    final skip = (position + const Duration(seconds: 10)).inMilliseconds;
    final newPosition = Duration(milliseconds: math.min(skip, end));
    await controller.seekTo(newPosition);
    Future.delayed(const Duration(milliseconds: 1000), () {
      controller.setPlaybackSpeed(selectedSpeed);
    });
  }

  /// Builds the skip forward button.
  GestureDetector _buildSkipForward(VlcPlayerController controller) {
    return GestureDetector(
      onTap: () => _skipForward(controller),
      child: Container(
        color: Colors.transparent,
        margin: const EdgeInsets.only(right: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: Icon(
          CupertinoIcons.goforward_10,
          color: Colors.white,
          size: 36.0,
        ),
      ),
    );
  }

  /// Builds the full video control overlay.
  Widget _buildControls() {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    final onClose = context.read<PlayerControlsBloc>().state.onClose;
                    if (onClose != null) {
                      onClose();
                    }
                  },
                  child: Icon(
                    CupertinoIcons.clear,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                BlocSelector<VlcPlayerXBloc, VlcPlayerXState, double>(
                  selector: (state) =>
                      state is VlcPlayerXLoaded ? state.volume : 0,
                  builder: (context, volume) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width / 5,
                      child: Volume(
                        progressColor: Colors.white,
                        backgroundColor: Colors.grey.shade700,
                        progress: volume,
                        volume: volume,
                        onChanged: (newVolume) {
                          context
                              .read<VlcPlayerXBloc>()
                              .add(VlcPlayerXVolumeChanged(newVolume));
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(child: SizedBox(height: double.infinity)),
          BlocSelector<VlcPlayerXBloc, VlcPlayerXState, VlcPlayerController?>(
            selector: (state) =>
                state is VlcPlayerXLoaded ? state.controller : null,
            builder: (context, controller) {
              if (controller == null) {
                return Container();
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 72,
                children: [
                  _buildSkipBack(controller),
                  BlocSelector<VlcPlayerXBloc, VlcPlayerXState, bool>(
                    selector: (state) =>
                        state is VlcPlayerXLoaded ? state.isPlaying : false,
                    builder: (context, isPlaying) {
                      final bloc = context.read<VlcPlayerXBloc>();
                      final state = bloc.state;

                      if (state is VlcPlayerXLoaded) {
                        final controller = state.controller;
                        return PlayPause(
                          playing: isPlaying,
                          onTap: () => _playPause(controller),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                  _buildSkipForward(controller),
                ],
              );
            },
          ),
          Expanded(child: SizedBox(height: double.infinity)),
          BlocBuilder<VlcPlayerXBloc, VlcPlayerXState>(
            builder: (context, state) {
              if (state is! VlcPlayerXLoaded) {
                return Container();
              }
              return ProgressBar(
                progress: state.progress,
                backgroundColor: Colors.grey.shade700,
                progressColor: Colors.white,
                height: 28,
                currentPosition: state.position,
                totalDuration: state.duration,
                animationDuration: const Duration(milliseconds: 150),
                onChanged: (newProgress) {
                  context
                      .read<VlcPlayerXBloc>()
                      .add(VlcPlayerXSeekRequested(newProgress));
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
