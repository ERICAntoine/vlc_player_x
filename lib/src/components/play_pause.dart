import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A customizable play/pause button.
///
/// [PlayPause] provides:
/// - **Smooth scale and fade animations** for a responsive UI.
/// - **Tap interaction with press effect**.
class PlayPause extends StatefulWidget {
  const PlayPause({
    super.key,
    required this.playing,
    required this.onTap,
  });

  /// Indicates whether the media is currently playing.
  final bool playing;

  /// Callback function triggered when the button is tapped.
  final VoidCallback onTap;

  @override
  State<PlayPause> createState() => _PlayPauseState();
}

class _PlayPauseState extends State<PlayPause>
    with SingleTickerProviderStateMixin {
  /// Animation controller for handling play/pause transitions.
  late final AnimationController _controller;

  /// Scale animation for a subtle bounce effect.
  late final Animation<double> _scaleAnimation;

  /// Fade animation for smooth transitions.
  late final Animation<double> _fadeAnimation;

  /// Tracks whether the button is currently pressed.
  bool _isPressed = false;

  /// The size of the play/pause icon.
  final double size = 64.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedScale(
            scale: _isPressed ? 0.85 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: Container(
              decoration: BoxDecoration(
                color: _isPressed
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(size * 0.2),
              child: Icon(
                widget.playing
                    ? CupertinoIcons.pause_fill
                    : CupertinoIcons.play_fill,
                size: size,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}