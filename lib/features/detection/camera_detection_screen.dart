import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:privacy_guard/features/detection/detection_engine.dart';
import 'package:privacy_guard/features/protection/privacy_overlay.dart';


class CameraDetectionScreen extends StatefulWidget {
  const CameraDetectionScreen({super.key});

  @override
  State<CameraDetectionScreen> createState() => _CameraDetectionScreenState();
}

class _CameraDetectionScreenState extends State<CameraDetectionScreen>
    with WidgetsBindingObserver {
  final DetectionEngine _engine = DetectionEngine();
  late final FaceDetector _faceDetector;

  CameraController? _camera;
  bool _starting = true;
  bool _processingFrame = false;
  bool _monitoring = false;
  String? _error;
  int _faceCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        enableLandmarks: false,
        enableContours: false,
        enableClassification: false,
        enableTracking: false,
        minFaceSize: 0.12,
      ),
    );
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCameras = cameras
          .where((camera) => camera.lensDirection == CameraLensDirection.front)
          .toList();

      if (frontCameras.isEmpty) {
        throw CameraException('no_front_camera', 'No front-facing camera was found.');
      }

      final controller = CameraController(
        frontCameras.first,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup:
            Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
      );
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _camera = controller;
        _starting = false;
      });
      await _startMonitoring();
    } on CameraException catch (error) {
      _setError(_cameraErrorMessage(error));
    } catch (error) {
      _setError('Could not start the camera. Check camera permission and try again.');
      debugPrint('Privacy Guard camera initialization failed: $error');
    }
  }

  Future<void> _startMonitoring() async {
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized || _monitoring) return;

    try {
      await camera.startImageStream(_processFrame);
      _engine.setEnabled(true);
      if (!mounted) return;
      setState(() {
        _monitoring = true;
        _error = null;
      });
    } catch (error) {
      _setError('Camera monitoring could not start. Please retry.');
      debugPrint('Privacy Guard image stream failed: $error');
    }
  }

  Future<void> _stopMonitoring() async {
    final camera = _camera;
    _engine.setEnabled(false);
    if (camera != null && camera.value.isStreamingImages) {
      try {
        await camera.stopImageStream();
      } catch (error) {
        debugPrint('Privacy Guard could not stop image stream cleanly: $error');
      }
    }
    if (mounted) {
      setState(() {
        _monitoring = false;
        _faceCount = 0;
      });
    }
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_processingFrame || !_monitoring || !mounted) return;
    _processingFrame = true;

    try {
      final camera = _camera;
      if (camera == null) return;

      final inputImage = _toInputImage(image, camera.description);
      if (inputImage == null) return;

      final faces = await _faceDetector.processImage(inputImage);
      if (!mounted || !_monitoring) return;

      final state = _engine.addFaceCount(faces.length);
      setState(() {
        _faceCount = faces.length;
      });

      if (state == PrivacyDetectionState.protected && faces.length >= 2) {
        // State changes are reflected by the UI; camera frames are never saved.
      }
    } catch (error) {
      debugPrint('Privacy Guard frame processing failed: $error');
    } finally {
      _processingFrame = false;
    }
  }

  InputImage? _toInputImage(CameraImage image, CameraDescription description) {
    final rotation = InputImageRotationValue.fromRawValue(description.sensorOrientation);
    if (rotation == null || image.planes.isEmpty) return null;

    final format = Platform.isAndroid
        ? InputImageFormat.nv21
        : InputImageFormat.bgra8888;
    final plane = image.planes.first;

    // NV21 and BGRA8888 are configured above as single-plane stream formats.
    // Refuse unexpected layouts rather than silently interpreting bytes wrongly.
    if (image.planes.length != 1) return null;

    return InputImage.fromBytes(
      bytes: Uint8List.fromList(plane.bytes),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  void _setError(String message) {
    if (!mounted) return;
    setState(() {
      _error = message;
      _starting = false;
      _monitoring = false;
    });
  }

  String _cameraErrorMessage(CameraException error) {
    switch (error.code) {
      case 'CameraAccessDenied':
      case 'CameraAccessDeniedWithoutPrompt':
        return 'Camera permission is required to detect a possible nearby viewer.';
      case 'no_front_camera':
        return error.description ?? 'No front-facing camera was found.';
      default:
        return error.description ?? 'The camera could not be started.';
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_stopMonitoring());
    } else if (state == AppLifecycleState.resumed && mounted) {
      unawaited(_startMonitoring());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _engine.setEnabled(false);
    final camera = _camera;
    if (camera != null) {
      unawaited(camera.dispose());
    }
    unawaited(_faceDetector.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final protected = _engine.shouldProtect;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live detection'),
        actions: [
          IconButton(
            tooltip: _monitoring ? 'Stop detection' : 'Start detection',
            onPressed: _monitoring ? _stopMonitoring : _startMonitoring,
            icon: Icon(_monitoring ? Icons.pause_circle_outline : Icons.play_circle_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Container(
              height: 360,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFF10223A),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white12),
              ),
              child: _buildPreview(protected),
            ),
            const SizedBox(height: 18),
            _buildDetectionStatus(protected),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10223A),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'Privacy note: frames are analyzed on this device and are not saved or uploaded. Multiple faces are only a rough signal; this cannot confirm that another person is reading your screen.',
                style: TextStyle(color: Colors.white70, height: 1.45, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(bool protected) {
    final camera = _camera;
    if (_starting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_outlined, size: 42, color: Colors.white54),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _initializeCamera, child: const Text('Try again')),
            ],
          ),
        ),
      );
    }
    if (camera == null || !camera.value.isInitialized) {
      return const Center(child: Text('Camera unavailable'));
    }

    return PrivacyOverlay(
      protect: protected,
      message: 'Possible nearby viewer detected',
      child: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(camera),
          Positioned(
            left: 12,
            top: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .58),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _monitoring ? const Color(0xFF55D6E8) : Colors.white38,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(_monitoring ? 'LIVE · ON DEVICE' : 'PAUSED'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionStatus(bool protected) {
    final title = protected
        ? 'Privacy shield active'
        : _engine.state == PrivacyDetectionState.potentialViewer
            ? 'Checking a possible viewer…'
            : _monitoring
                ? 'Monitoring for additional faces'
                : 'Detection paused';
    final subtitle = protected
        ? 'The preview is covered until the scene clears.'
        : 'Faces detected in current frame: $_faceCount';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: protected
            ? const Color(0xFF173D50)
            : const Color(0xFF10223A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: protected ? const Color(0xFF55D6E8) : Colors.white12,
        ),
      ),
      child: Row(
        children: [
          Icon(
            protected ? Icons.shield_rounded : Icons.face_retouching_natural_rounded,
            color: const Color(0xFF55D6E8),
            size: 28,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 5),
                Text(subtitle, style: const TextStyle(color: Colors.white60)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
