import 'package:flutter/material.dart';

/// A customizable progress bar for video playback.
///
/// [ProgressBar] provides:
/// - **Smooth progress animation** for video seeking.
/// - **Tap & drag interaction** to seek within the video.
/// - **Displays elapsed & remaining time**.
class ProgressBar extends StatefulWidget {
  /// Current playback progress (between 0.0 and 1.0).
  final double progress;

  /// Background color of the progress bar.
  final Color backgroundColor;

  /// Color of the played portion of the progress bar.
  final Color progressColor;

  /// Total height of the widget.
  final double height;

  /// Duration of the animation when progress updates.
  final Duration animationDuration;

  /// Total duration of the video.
  final Duration? totalDuration;

  /// Current playback position.
  final Duration? currentPosition;

  /// Custom border radius for the progress bar.
  final BorderRadius? borderRadius;

  /// Callback function when the user interacts with the progress bar.
  final ValueChanged<double>? onChanged;

  /// Color of the elapsed and remaining time text.
  final Color textColor;

  const ProgressBar({
    super.key,
    required this.progress,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.progressColor = Colors.white,
    this.height = 40.0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.borderRadius,
    this.onChanged,
    this.totalDuration,
    this.currentPosition,
    this.textColor = Colors.grey,
  });

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  /// Indicates whether the user is currently interacting with the progress bar.
  bool _isInteracting = false;

  /// Normal thickness of the progress bar.
  final double normalThickness = 8.0;
  /// Thickness when the user interacts with the progress bar.
  final double pressedThickness = 12.0;

  /// Updates the progress based on user interaction.
  void _updateProgress(Offset globalPosition, BoxConstraints constraints) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset local = box.globalToLocal(globalPosition);
    double newProgress = local.dx / constraints.maxWidth;
    newProgress = newProgress.clamp(0.0, 1.0);
    if (widget.onChanged != null) {
      widget.onChanged!(newProgress);
    }
  }

  /// Handles tap down events on the progress bar.
  void _handleTapDown(TapDownDetails details, BoxConstraints constraints) {
    setState(() => _isInteracting = true);
  }

  /// Handles drag start events on the progress bar.
  void _handleDragStart(DragStartDetails details, BoxConstraints constraints) {
    setState(() => _isInteracting = true);
    _updateProgress(details.globalPosition, constraints);
  }

  /// Handles drag update events on the progress bar.
  void _handleDragUpdate(
      DragUpdateDetails details, BoxConstraints constraints) {
    _updateProgress(details.globalPosition, constraints);
  }

  /// Handles the end of a drag event, resetting the interaction state.
  void _handleDragEnd(DragEndDetails details) {
    setState(() => _isInteracting = false);
  }

  /// Handles tap up events, resetting the interaction state.
  void _handleTapUp(TapUpDetails details) {
    setState(() => _isInteracting = false);
  }

  /// Handles tap cancel events, resetting the interaction state.
  void _handleTapCancel() {
    setState(() => _isInteracting = false);
  }

  /// Formats a duration into a **mm:ss** string.
  String _formatDuration(Duration? duration) {
    if (duration == null) return "00:00";

    int minutes = duration.inMinutes;
    int seconds = (duration.inSeconds % 60);
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double currentThickness =
            _isInteracting ? pressedThickness : normalThickness;

        final BorderRadius progressBorderRadius = widget.progress < 1.0
            ? BorderRadius.only(
                topLeft: Radius.circular(currentThickness / 2),
                bottomLeft: Radius.circular(currentThickness / 2),
              )
            : widget.borderRadius ??
                BorderRadius.circular(currentThickness / 2);
        final Duration currentPosition =
            widget.currentPosition ?? Duration.zero;
        final Duration totalDuration = widget.totalDuration ?? Duration.zero;
        final Duration remainingTime = totalDuration - currentPosition;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTapUp: _handleTapUp,
              onTapDown: (details) => _handleTapDown(details, constraints),
              onTapCancel: _handleTapCancel,
              onHorizontalDragStart: (details) =>
                  _handleDragStart(details, constraints),
              onHorizontalDragUpdate: (details) =>
                  _handleDragUpdate(details, constraints),
              onHorizontalDragEnd: _handleDragEnd,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: widget.progress),
                duration: widget.animationDuration,
                builder: (context, animatedProgress, child) {
                  return Container(
                    width: constraints.maxWidth,
                    height: widget.height,
                    color: Colors.transparent,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          top: (widget.height - currentThickness) / 2,
                          child: AnimatedContainer(
                            duration: widget.animationDuration,
                            height: currentThickness,
                            decoration: BoxDecoration(
                              color: widget.backgroundColor,
                              borderRadius: widget.borderRadius ??
                                  BorderRadius.circular(currentThickness / 2),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          top: (widget.height - currentThickness) / 2,
                          width: constraints.maxWidth * animatedProgress,
                          child: AnimatedContainer(
                            duration: widget.animationDuration,
                            height: currentThickness,
                            decoration: BoxDecoration(
                              color: widget.progressColor,
                              borderRadius: progressBorderRadius,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(widget.currentPosition),
                  style: TextStyle(
                    color: widget.textColor,
                    fontSize: 12,
                  ),
                ),
                Text(
                  "-${_formatDuration(remainingTime)}",
                  style: TextStyle(
                    color: widget.textColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
