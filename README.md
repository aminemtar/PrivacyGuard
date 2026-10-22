# Privacy Guard

A Flutter app exploring shoulder-surfing detection with on-device face detection and privacy protection inside the app.

## Scope and platform limits

- Android and iOS Flutter application.
- Front-camera face detection is a signal, not proof of gaze or intent.
- Camera frames should be processed locally and not uploaded.
- In-app privacy overlays are supported by the application UI.
- Cross-app overlays are platform-specific, permission-gated, and not available as a general solution on iOS.
- This repository is being initialized with the Dart application layer first. Generate the native Flutter platform scaffolding with `flutter create . --platforms=android,ios` after cloning, if it is not already present.

## Development

1. Install Flutter stable.
2. Run `flutter create . --platforms=android,ios` if the `android/` and `ios/` directories are absent.
3. Run `flutter pub get`.
4. Run `flutter analyze` and `flutter test`.

See `docs/ARCHITECTURE.md` for the initial design.