import 'dart:math' as math;

/// Coarse states for shoulder-surfing signals.
///
/// Face count is only a heuristic; it does not prove that a person is looking
/// at the display. The engine requires repeated detections to reduce flicker.
enum PrivacyDetectionState {
  idle,
  monitoring,
  potentialViewer,
  protected,
}

/// Converts face counts into stable privacy state transitions.
class DetectionEngine {
  DetectionEngine({
    this.confirmationFrames = 3,
    this.clearFrames = 8,
  })  : assert(confirmationFrames > 0),
        assert(clearFrames > 0);

  final int confirmationFrames;
  final int clearFrames;

  PrivacyDetectionState _state = PrivacyDetectionState.idle;
  int _positiveFrames = 0;
  int _clearFrames = 0;
  bool _enabled = false;

  PrivacyDetectionState get state => _state;
  bool get isEnabled => _enabled;
  bool get shouldProtect => _state == PrivacyDetectionState.protected;

  PrivacyDetectionState setEnabled(bool enabled) {
    _enabled = enabled;
    _positiveFrames = 0;
    _clearFrames = 0;
    _state = enabled
        ? PrivacyDetectionState.monitoring
        : PrivacyDetectionState.idle;
    return _state;
  }

  /// Supply the number of faces found in the latest usable frame.
  ///
  /// A second detected face is treated as a possible nearby viewer. This is
  /// deliberately conservative and should be tuned using real-device tests.
  PrivacyDetectionState addFaceCount(int faceCount) {
    if (!_enabled) return _state;

    if (faceCount >= 2) {
      _positiveFrames++;
      _clearFrames = 0;
      _state = _positiveFrames >= confirmationFrames
          ? PrivacyDetectionState.protected
          : PrivacyDetectionState.potentialViewer;
    } else {
      _clearFrames++;
      _positiveFrames = 0;
      if (_clearFrames >= clearFrames) {
        _state = PrivacyDetectionState.monitoring;
      }
    }

    return _state;
  }

  /// A normalized score for UI only; it is not a calibrated probability.
  double get displayConfidence {
    if (!_enabled) return 0;
    return math.min(1, _positiveFrames / confirmationFrames);
  }
}
