import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:vlc_player_x/src/player_controls.dart';
import 'package:vlc_player_x/src/bloc/playerControls/player_controls_bloc.dart';
import 'package:vlc_player_x/src/bloc/vlcPlayerX/vlc_player_x_bloc.dart';
import 'package:vlc_player_x/src/components/vlc_player_container.dart';
import 'package:vlc_player_x/src/bloc/playerControls/player_controls_event.dart';

/// A widget that provides a complete VLC-based video player with controls.
///
/// [VlcPlayerX] wraps a VLC player inside a **MultiBlocProvider**,
/// managing both **video playback state** and **player controls state**.
///
/// It displays a video player inside a `Stack`, where:
/// - [VlcPlayerContainer] renders the video.
/// - [PlayerControls] provides playback controls.
///
/// The aspect ratio of the player is dynamically adjusted based on the screen size.
class VlcPlayerX extends StatefulWidget {
  /// The aspect ratio of the video player (e.g., `16/9`).
  final double aspectRatio;

  /// The [VlcPlayerController] instance for managing playback.
  final VlcPlayerController controller;

  /// Callback triggered when the player is closed.
  /// If `null`, no action is performed.
  final void Function()? onClose;

  const VlcPlayerX({
    super.key,
    required this.aspectRatio,
    required this.controller,
    this.onClose,
  });

  @override
  State<VlcPlayerX> createState() => _VlcPlayerXState();
}

class _VlcPlayerXState extends State<VlcPlayerX> {
  /// Dynamically calculates the optimal aspect ratio based on the screen size.
  ///
  /// - If the screen is **wider than it is tall**, it uses `width / height`.
  /// - If the screen is **taller than it is wide**, it uses `height / width`.
  ///
  /// This ensures a proper fit for different screen orientations.
  double calculateAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return width > height ? width / height : height / width;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Provides the BLoC responsible for managing VLC player state.
        BlocProvider<VlcPlayerXBloc>(
          create: (_) => VlcPlayerXBloc(),
        ),
        // Provides the BLoC responsible for handling player controls.
        BlocProvider<PlayerControlsBloc>(
          create: (_) => PlayerControlsBloc()..add(SetOnClose(widget.onClose)),
        ),
      ],
      child: Scaffold(
          backgroundColor: Colors.black,
          body: LayoutBuilder(builder: (context, constraints) {
            return SizedBox(
              height: constraints.maxHeight,
              width: constraints.maxWidth,
              child: AspectRatio(
                  aspectRatio: calculateAspectRatio(context),
                  child: Stack(
                    children: [
                      // VLC Player
                      VlcPlayerContainer(
                          controller: widget.controller,
                          aspectRatio: widget.aspectRatio),
                      // Video Playback Controls Overlay
                      PlayerControls(),
                    ],
                  )),
            );
          })),
    );
  }
}