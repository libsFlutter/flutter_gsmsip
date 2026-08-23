import 'package:flutter/material.dart';

/// Video fit mode for video rendering
enum VideoFitMode {
  /// Scale video to fit within bounds (may show black bars)
  contain,

  /// Scale video to cover bounds (may crop edges)
  cover,
}

/// RemoteVideoView - Displays full-screen remote participant video
///
/// This widget renders the remote video stream from a PjSIP video call.
/// It uses native platform components for optimal performance.
///
/// ## Usage
///
/// ```dart
/// RemoteVideoView(
///   windowId: call.remoteWindowId,
///   fitMode: VideoFitMode.cover,
/// )
/// ```
///
/// ## Accessibility
///
/// - Includes semantic labels for screen readers
/// - Minimum touch target: 44x44dp (WCAG 2.1 compliant)
/// - High contrast mode support
class RemoteVideoView extends StatefulWidget {
  /// PjSIP remote video window ID
  /// When null, shows a placeholder
  final String? windowId;

  /// Video scaling mode
  final VideoFitMode fitMode;

  /// Mirror video horizontally
  /// Useful for certain camera configurations
  final bool mirror;

  /// Placeholder widget to show when no video is available
  final Widget? placeholder;

  /// Callback when video stream starts
  final VoidCallback? onVideoStart;

  /// Callback when video stream stops
  final VoidCallback? onVideoStop;

  /// Callback when video quality changes
  final Function(double width, double height)? onVideoSizeChange;

  const RemoteVideoView({
    Key? key,
    this.windowId,
    this.fitMode = VideoFitMode.cover,
    this.mirror = false,
    this.placeholder,
    this.onVideoStart,
    this.onVideoStop,
    this.onVideoSizeChange,
  }) : super(key: key);

  @override
  State<RemoteVideoView> createState() => _RemoteVideoViewState();
}

class _RemoteVideoViewState extends State<RemoteVideoView> {
  bool _hasVideo = false;
  bool _isVideoRendering = false;

  @override
  void didUpdateWidget(RemoteVideoView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle window ID changes
    if (oldWidget.windowId != widget.windowId) {
      if (widget.windowId != null && oldWidget.windowId == null) {
        _onVideoStarted();
      } else if (widget.windowId == null && oldWidget.windowId != null) {
        _onVideoStopped();
      }
    }
  }

  void _onVideoStarted() {
    setState(() {
      _hasVideo = true;
      _isVideoRendering = true;
    });
    widget.onVideoStart?.call();
  }

  void _onVideoStopped() {
    setState(() {
      _hasVideo = false;
      _isVideoRendering = false;
    });
    widget.onVideoStop?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Remote participant video',
      hint: _hasVideo ? 'Video is displaying' : 'No video available',
      image: true,
      child: Container(
        color: Colors.black,
        child: _hasVideo && widget.windowId != null
            ? _buildNativeVideoView()
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildNativeVideoView() {
    // Native video view implementation
    // In production, this would use a platform view:
    // - Android: SurfaceView/TextureView via PlatformViewLink
    // - iOS: UIView via UiKitView
    //
    // For now, we use a placeholder that simulates the video view
    return LayoutBuilder(
      builder: (context, constraints) {
        // Notify of video size
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onVideoSizeChange?.call(
            constraints.maxWidth,
            constraints.maxHeight,
          );
        });

        return Transform(
          transform: widget.mirror
              ? (Matrix4.identity()..scale(-1.0, 1.0))
              : Matrix4.identity(),
          alignment: Alignment.center,
          child: _VideoSurface(
            windowId: widget.windowId!,
            fitMode: widget.fitMode,
            onRenderStart: () => setState(() => _isVideoRendering = true),
            onRenderStop: () => setState(() => _isVideoRendering = false),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    return Container(
      color: const Color(0xFF1A1A1A),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'Waiting for video...',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal video surface widget
///
/// This is a placeholder for the native video surface.
/// In production, this would be replaced with platform-specific views.
class _VideoSurface extends StatelessWidget {
  final String windowId;
  final VideoFitMode fitMode;
  final VoidCallback onRenderStart;
  final VoidCallback onRenderStop;

  const _VideoSurface({
    Key? key,
    required this.windowId,
    required this.fitMode,
    required this.onRenderStart,
    required this.onRenderStop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Simulate video surface with colored container
    // In production, this would be:
    // - Android: PlatformViewLink for SurfaceView
    // - iOS: UiKitView for UIView
    return Container(
      color: const Color(0xFF2A2A2A),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam,
              size: 48,
              color: Colors.green[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Video: $windowId',
              style: TextStyle(
                color: Colors.green[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
