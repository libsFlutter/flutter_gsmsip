import 'package:flutter/material.dart';

/// Video quality levels
enum VideoQuality {
  /// Excellent quality: 3 bars, green
  excellent,

  /// Good quality: 2 bars, light green
  good,

  /// Fair quality: 1 bar, yellow
  fair,

  /// Poor quality: warning, red
  poor,

  /// Unknown quality: gray, no signal
  unknown,
}

/// Video quality indicator widget
///
/// Displays the current video call quality using visual bars and colors.
///
/// ## Quality Levels
///
/// | Level | Bars | Color | Condition |
/// |-------|------|-------|-----------|
/// | Excellent | ▮▮▮ | Green (#10B981) | Packet loss < 1%, Jitter < 30ms |
/// | Good | ▮▮▯ | Light Green (#34D399) | Packet loss < 5%, Jitter < 60ms |
/// | Fair | ▮▯▯ | Yellow (#F59E0B) | Packet loss < 10%, Jitter < 100ms |
/// | Poor | ▯▯▯ | Red (#EF4444) | Packet loss >= 10% or Jitter >= 100ms |
/// | Unknown | ▯▯▯ | Gray (#6B7280) | No data available |
///
/// ## Usage
///
/// ```dart
/// VideoQualityIndicator(
///   quality: VideoQuality.good,
///   showLabel: true,
/// )
/// ```
class VideoQualityIndicator extends StatelessWidget {
  /// Current video quality level
  final VideoQuality quality;

  /// Show text label
  final bool showLabel;

  /// Show quality bars
  final bool showBars;

  /// Show warning icon for poor quality
  final bool showWarning;

  /// Custom size for the indicator
  final double size;

  const VideoQualityIndicator({
    Key? key,
    required this.quality,
    this.showLabel = true,
    this.showBars = true,
    this.showWarning = true,
    this.size = 24,
  }) : super(key: key);

  /// Calculate quality from network metrics
  static VideoQuality calculateFromMetrics({
    required double packetLoss,
    required int jitter,
    required int bitrate,
  }) {
    if (packetLoss < 0.01 && jitter < 30 && bitrate >= 1000) {
      return VideoQuality.excellent;
    } else if (packetLoss < 0.05 && jitter < 60 && bitrate >= 500) {
      return VideoQuality.good;
    } else if (packetLoss < 0.10 && jitter < 100 && bitrate >= 200) {
      return VideoQuality.fair;
    } else {
      return VideoQuality.poor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Video quality: ${_getQualityLabel()}',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showBars) _buildQualityBars(),
          if (showLabel) ...[
            const SizedBox(width: 8),
            _buildQualityLabel(),
          ],
          if (showWarning && quality == VideoQuality.poor) ...[
            const SizedBox(width: 4),
            _buildWarningIcon(),
          ],
        ],
      ),
    );
  }

  Widget _buildQualityBars() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final filled = _getFilledBars() > index;
        return Container(
          width: size * 0.25,
          height: size * (0.3 + (index * 0.25)),
          margin: EdgeInsets.only(right: size * 0.08),
          decoration: BoxDecoration(
            color: filled ? _getQualityColor() : _getQualityColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(size * 0.06),
          ),
        );
      }),
    );
  }

  Widget _buildQualityLabel() {
    return Text(
      _getQualityLabel(),
      style: TextStyle(
        color: _getQualityColor(),
        fontSize: size * 0.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildWarningIcon() {
    return Icon(
      Icons.warning_amber_rounded,
      size: size,
      color: _getQualityColor(),
    );
  }

  String _getQualityLabel() {
    switch (quality) {
      case VideoQuality.excellent:
        return 'Excellent';
      case VideoQuality.good:
        return 'Good';
      case VideoQuality.fair:
        return 'Fair';
      case VideoQuality.poor:
        return 'Poor';
      case VideoQuality.unknown:
        return 'Unknown';
    }
  }

  Color _getQualityColor() {
    switch (quality) {
      case VideoQuality.excellent:
        return const Color(0xFF10B981);
      case VideoQuality.good:
        return const Color(0xFF34D399);
      case VideoQuality.fair:
        return const Color(0xFFF59E0B);
      case VideoQuality.poor:
        return const Color(0xFFEF4444);
      case VideoQuality.unknown:
        return const Color(0xFF6B7280);
    }
  }

  int _getFilledBars() {
    switch (quality) {
      case VideoQuality.excellent:
        return 3;
      case VideoQuality.good:
        return 2;
      case VideoQuality.fair:
        return 1;
      case VideoQuality.poor:
      case VideoQuality.unknown:
        return 0;
    }
  }
}

/// Compact version for overlay display
class CompactVideoQualityIndicator extends StatelessWidget {
  final VideoQuality quality;
  final double size;

  const CompactVideoQualityIndicator({
    Key? key,
    required this.quality,
    this.size = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Video quality: ${_getQualityLabel()}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMiniBars(),
            const SizedBox(width: 4),
            Text(
              _getQualityLabel(),
              style: TextStyle(
                color: _getQualityColor(),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBars() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final filled = _getFilledBars() > index;
        return Container(
          width: 3,
          height: 4 + (index * 3),
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: filled ? _getQualityColor() : _getQualityColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }

  String _getQualityLabel() {
    switch (quality) {
      case VideoQuality.excellent:
        return 'Excellent';
      case VideoQuality.good:
        return 'Good';
      case VideoQuality.fair:
        return 'Fair';
      case VideoQuality.poor:
        return 'Poor';
      case VideoQuality.unknown:
        return '---';
    }
  }

  Color _getQualityColor() {
    switch (quality) {
      case VideoQuality.excellent:
        return const Color(0xFF10B981);
      case VideoQuality.good:
        return const Color(0xFF34D399);
      case VideoQuality.fair:
        return const Color(0xFFF59E0B);
      case VideoQuality.poor:
        return const Color(0xFFEF4444);
      case VideoQuality.unknown:
        return const Color(0xFF6B7280);
    }
  }

  int _getFilledBars() {
    switch (quality) {
      case VideoQuality.excellent:
        return 3;
      case VideoQuality.good:
        return 2;
      case VideoQuality.fair:
        return 1;
      case VideoQuality.poor:
      case VideoQuality.unknown:
        return 0;
    }
  }
}

/// Video quality statistics display
class VideoQualityStats extends StatelessWidget {
  final double packetLoss;
  final int jitter;
  final int bitrate;
  final int framerate;

  const VideoQualityStats({
    Key? key,
    required this.packetLoss,
    required this.jitter,
    required this.bitrate,
    required this.framerate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quality = VideoQualityIndicator.calculateFromMetrics(
      packetLoss: packetLoss,
      jitter: jitter,
      bitrate: bitrate,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Video Quality',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              VideoQualityIndicator(
                quality: quality,
                showLabel: false,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildStatRow('Packet Loss', '${(packetLoss * 100).toStringAsFixed(1)}%'),
          _buildStatRow('Jitter', '$jitter ms'),
          _buildStatRow('Bitrate', '$bitrate kbps'),
          _buildStatRow('Frame Rate', '$framerate FPS'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
