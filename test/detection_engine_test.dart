import 'package:flutter_test/flutter_test.dart';
import 'package:privacy_guard/features/detection/detection_engine.dart';

void main() {
  group('DetectionEngine', () {
    test('starts idle and disabled', () {
      final engine = DetectionEngine();
      expect(engine.state, PrivacyDetectionState.idle);
      expect(engine.isEnabled, isFalse);
    });

    test('requires repeated possible-viewer frames before protection', () {
      final engine = DetectionEngine(confirmationFrames: 3);
      engine.setEnabled(true);

      expect(engine.addFaceCount(2), PrivacyDetectionState.potentialViewer);
      expect(engine.addFaceCount(2), PrivacyDetectionState.potentialViewer);
      expect(engine.addFaceCount(2), PrivacyDetectionState.protected);
      expect(engine.shouldProtect, isTrue);
    });

    test('clears protection only after enough clear frames', () {
      final engine = DetectionEngine(confirmationFrames: 1, clearFrames: 2);
      engine.setEnabled(true);
      engine.addFaceCount(2);
      expect(engine.state, PrivacyDetectionState.protected);

      engine.addFaceCount(1);
      expect(engine.state, PrivacyDetectionState.protected);
      engine.addFaceCount(1);
      expect(engine.state, PrivacyDetectionState.monitoring);
    });

    test('disabling immediately resets the state', () {
      final engine = DetectionEngine(confirmationFrames: 1);
      engine.setEnabled(true);
      engine.addFaceCount(2);

      expect(engine.setEnabled(false), PrivacyDetectionState.idle);
      expect(engine.shouldProtect, isFalse);
    });

    test('ignores face counts when disabled', () {
      final engine = DetectionEngine();
      expect(engine.addFaceCount(4), PrivacyDetectionState.idle);
    });
  });
}
