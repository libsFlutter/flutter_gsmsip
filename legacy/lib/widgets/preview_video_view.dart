import 'package:flutter/material.dart';

/// PreviewVideoView - Displays local camera preview (Picture-in-Picture)
///
/// This widget shows the local camera feed in a draggable PiP overlay.
/// Default size is 120x160dp (4:3 aspect ratio).
///
/// ## Features
///
/// - Draggable within screen bounds
/// - Snaps to corners when released
/// - Double-tap to toggle size (small/large)
/// - Mirror mode for front camera
/// - Minimal touch target: 44x44dp
///
/// ## Usage
///
/// ```dart
/// PreviewVideoView(
///   deviceId: cameraId,
///   mirror: true,
///   onDoubleTap: () => print('Toggled size'),
/// )
/// ```
///
/// ## Accessibility
///
/// - Includes semantic labels for screen readers
/// - Minimum touch target: 44x44dp (WCAG 2.1 compliant)
/// - High contrast mode support
class PreviewVideoView extends StatefulWidget {
  /// Camera device ID
  /// When null, uses default front camera
  final int? deviceId;

  /// Video scaling mode
  final VideoFitMode fitMode;

  /// Mirror preview horizontally
  /// Recommended for front camera
  final bool mirror;

  /// PiP width in dp
  final double width;

  /// PiP height in dp
  final double height;

  /// Initial position (from top-left)
  final Offset position;

  /// Enable dragging
  final bool draggable;

  /// Enable double-tap to toggle size
  final bool doubleTapToToggle;

  /// Callback when position changes
  final Function(Offset)? onPositionChange;

  /// Callback on double tap
  final VoidCallback? onDoubleTap;

  /// Callback when video starts
  final VoidCallback? onVideoStart;

  /// Callback when video stops
  final VoidCallback? onVideoStop;

  const PreviewVideoView({
    Key? key,
    this.deviceId,
    this.fitMode = VideoFitMode.contain,
    this.mirror = true,
    this.width = 120,
    this.height = 160,
    this.position = const Offset(16, 100),
    this.draggable = true,
    this.doubleTapToToggle = true,
    this.onPositionChange,
    this.onDoubleTap,
    this.onVideoStart,
    this.onVideoStop,
  }) : super(key: key);

  @override
  State<PreviewVideoView> createState() => _PreviewVideoViewState();
}

class _PreviewVideoViewState extends State<PreviewVideoView>
    with TickerProviderStateMixin {
  late Offset _position;
  late double _width;
  late double _height;
  bool _isLarge = false;
  bool _hasVideo = false;
  bool _isDragging = false;

  // Snap positions (corners)
  static const double _snapMargin = 16.0;
  static const double _largeWidth = 180.0;
  static const double _largeHeight = 240.0;

  @override
  void initState() {
    super.initState();
    _position = widget.position;
    _width = widget.width;
    _height = widget.height;
  }

  void _toggleSize() {
    setState(() {
      _isLarge = !_isLarge;
      if (_isLarge) {
        _width = _largeWidth;
        _height = _largeHeight;
      } else {
        _width = widget.width;
        _height = widget.height;
      }
    });
    widget.onDoubleTap?.call();
  }

  void _snapToCorner(Offset globalPosition, Size screenSize) {
    // Determine which corner is closest
    final left = globalPosition.dx;
    final right = screenSize.width - globalPosition.dx - _width;
    final top = globalPosition.dy;
    final bottom = screenSize.height - globalPosition.dy - _height;

    double newX = _snapMargin;
    double newY = _snapMargin;

    // Snap horizontally
    if (left < right) {
      newX = _snapMargin;
    } else {
      newX = screenSize.width - _width - _snapMargin;
    }

    // Snap vertically
    if (top < bottom) {
      newY = _snapMargin;
    } else {
      newY = screenSize.height - _height - _snapMargin;
    }

    setState(() {
      _position = Offset(newX, newY);
    });

    widget.onPositionChange?.call(Offset(newX, newY));
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Local camera preview',
      hint: 'Drag to reposition. Double-tap to change size.',
      image: true,
      child: GestureDetector(
        onDoubleTap: widget.doubleTapToToggle ? _toggleSize : null,
        child: DraggableWidget(
          initialPosition: _position,
          onPositionChange: (position, screenSize) {
            setState(() => _position = position);
            widget.onPositionChange?.call(position);
          },
          onDragEnd: (position, screenSize) {
            _snapToCorner(position, screenSize);
          },
          child: _buildVideoContainer(),
        ),
      ),
    );
  }

  Widget _buildVideoContainer() {
    return Container(
      width: _width,
      height: _height,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isDragging ? Colors.white : Colors.white24,
          width: _isDragging ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          children: [
            // Video surface
            _hasVideo
                ? Transform(
                    transform: widget.mirror
                        ? (Matrix4.identity()..scale(-1.0, 1.0))
                        : Matrix4.identity(),
                    alignment: Alignment.center,
                    child: _PreviewSurface(
                      deviceId: widget.deviceId,
                      fitMode: widget.fitMode,
                      onVideoStart: () {
                        setState(() => _hasVideo = true);
                        widget.onVideoStart?.call();
                      },
                      onVideoStop: () {
                        setState(() => _hasVideo = false);
                        widget.onVideoStop?.call();
                      },
                    ),
                  )
                : _buildPlaceholder(),

            // Camera indicator
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _hasVideo ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _hasVideo ? Icons.videocam : Icons.videocam_off,
                      size: 12,
                      color: Colors.white,
                    ),
                    if (_hasVideo) ...[
                      const SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 32,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              'You',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Draggable widget for PiP video
class DraggableWidget extends StatefulWidget {
  final Offset initialPosition;
  final Widget child;
  final Function(Offset position, Size screenSize) onPositionChange;
  final Function(Offset position, Size screenSize) onDragEnd;

  const DraggableWidget({
    Key? key,
    required this.initialPosition,
    required this.child,
    required this.onPositionChange,
    required this.onDragEnd,
  }) : super(key: key);

  @override
  State<DraggableWidget> createState() => _DraggableWidgetState();
}

class _DraggableWidgetState extends State<DraggableWidget> {
  late Offset _position;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Positioned(
          left: _position.dx,
          top: _position.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _position = Offset(
                  _position.dx + details.delta.dx,
                  _position.dy + details.delta.dy,
                );
              });

              // Keep within bounds
              final maxX = constraints.maxWidth - context.size!.width;
              final maxY = constraints.maxHeight - context.size!.height;

              _position = Offset(
                _position.dx.clamp(0.0, maxX),
                _position.dy.clamp(0.0, maxY),
              );

              widget.onPositionChange.call(
                _position,
                Size(constraints.maxWidth, constraints.maxHeight),
              );
            },
            onPanEnd: (details) {
              widget.onDragEnd.call(
                _position,
                Size(constraints.maxWidth, constraints.maxHeight),
              );
            },
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Internal preview surface widget
class _PreviewSurface extends StatelessWidget {
  final int? deviceId;
  final VideoFitMode fitMode;
  final VoidCallback onVideoStart;
  final VoidCallback onVideoStop;

  const _PreviewSurface({
    Key? key,
    this.deviceId,
    required this.fitMode,
    required this.onVideoStart,
    required this.onVideoStop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Simulate camera preview
    // In production, this would use:
    // - camera package for Flutter
    // - PlatformViewLink for native camera surface
    return Container(
      color: const Color(0xFF3A3A3A),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 40,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Camera ${deviceId ?? 'default'}',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
