import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A customizable volume control bar.
///
/// [Volume] provides:
/// - **Smooth animation** when volume changes.
/// - **Drag interaction** for adjusting the volume.
/// - **Displays a volume icon** that dynamically updates based on volume level.
class Volume extends StatefulWidget {
  /// Current volume level (between 0.0 and 1.0).
  final double progress;

  /// Background color of the volume bar (unfilled portion).
  final Color backgroundColor;

  /// Color of the filled portion of the volume bar.
  final Color progressColor;

  /// Total height of the widget.
  final double height;

  /// Duration of the animation when progress updates.
  final Duration animationDuration;

  /// Custom border radius for the volume bar.
  final BorderRadius? borderRadius;

  /// Callback function when the user interacts with the volume bar.
  final ValueChanged<double>? onChanged;

  /// Current volume level (between 0 and 1) used to determine the volume icon.
  final double volume;

  const Volume({
    super.key,
    required this.progress,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.progressColor = Colors.white,
    this.height = 40.0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.borderRadius,
    this.onChanged,
    this.volume = 1.0,
  });

  @override
  State<Volume> createState() => _VolumeState();
}

class _VolumeState extends State<Volume> {
  /// Fixed thickness of the volume bar.
  final double fixedThickness = 8.0;

  /// Updates the volume level based on user interaction.
  void _updateProgress(Offset globalPosition, BoxConstraints constraints) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset local = box.globalToLocal(globalPosition);
    double newProgress = local.dx / constraints.maxWidth;
    newProgress = newProgress.clamp(0.0, 1.0);
    if (widget.onChanged != null) {
      widget.onChanged!(newProgress);
    }
  }

  /// Handles drag update events for adjusting the volume.
  void _handleDragUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    _updateProgress(details.globalPosition, constraints);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double iconSpace = fixedThickness * 2.5 + 16.0;
        final double barWidth = constraints.maxWidth - iconSpace;
        final double thickness = fixedThickness;

        final BorderRadius progressBorderRadius = widget.progress < 1.0
            ? BorderRadius.only(
          topLeft: Radius.circular(thickness / 2),
          bottomLeft: Radius.circular(thickness / 2),
        )
            : widget.borderRadius ?? BorderRadius.circular(thickness / 2);

        return GestureDetector(
          onHorizontalDragUpdate: (details) =>
              _handleDragUpdate(details, constraints),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: barWidth,
                alignment: Alignment.centerRight,
                height: widget.height,
                color: Colors.transparent,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: (widget.height - thickness) / 2,
                      child: AnimatedContainer(
                        duration: widget.animationDuration,
                        height: thickness,
                        decoration: BoxDecoration(
                          color: widget.backgroundColor,
                          borderRadius: widget.borderRadius ??
                              BorderRadius.circular(thickness / 2),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: (widget.height - thickness) / 2,
                      width: barWidth * widget.progress,
                      child: AnimatedContainer(
                        duration: widget.animationDuration,
                        height: thickness,
                        decoration: BoxDecoration(
                          color: widget.progressColor,
                          borderRadius: progressBorderRadius,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(
                  _getVolumeIcon(widget.volume),
                  size: thickness * 2.5,
                  color: widget.progressColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Returns the appropriate volume icon based on the current volume level.
  IconData _getVolumeIcon(double volume) {
    if (volume <= 0.0) {
      return CupertinoIcons.volume_mute;
    } else if (volume < 0.5) {
      return CupertinoIcons.volume_down;
    } else {
      return CupertinoIcons.volume_up;
    }
  }
}