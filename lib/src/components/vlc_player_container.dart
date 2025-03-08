import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:vlc_player_x/src/bloc/vlcPlayerX/vlc_player_x_bloc.dart';
import 'package:vlc_player_x/src/bloc/vlcPlayerX/vlc_player_x_event.dart';

/// A widget that displays a VLC-based video player.
///
/// [VlcPlayerContainer] provides:
/// - **VLC player integration** using `flutter_vlc_player`.
/// - **Automatic state initialization** using [VlcPlayerXBloc].
/// - **A loading indicator** while the player initializes.
class VlcPlayerContainer extends StatefulWidget {
  final double aspectRatio;

  /// The VLC player controller that manages playback.
  final VlcPlayerController controller;

  const VlcPlayerContainer({
    super.key,
    required this.aspectRatio,
    required this.controller,
  });

  @override
  State<VlcPlayerContainer> createState() => _VlcPlayerContainerState();
}

class _VlcPlayerContainerState extends State<VlcPlayerContainer> {
  /// Indicates whether the video player is still loading.
  bool _isLoading = true;
  late VlcPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;

    controller.addListener(() {
      if (controller.value.isInitialized && mounted) {
        if(_isLoading) {
          context.read<VlcPlayerXBloc>().add(VlcPlayerXInitialize(controller));
        }
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        InteractiveViewer(
          child: Center(
            child: VlcPlayer(controller: controller, aspectRatio: 16/9),
          ),
        ),

        if (_isLoading)
          const Positioned.fill(
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}