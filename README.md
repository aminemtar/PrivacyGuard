# Privacy Guard

Flutter app for experimenting with shoulder-surfing signals and in-app privacy protection on Android and iOS.

## Current MVP

- Premium blue dashboard with saved enable/disable preference.
- Front-camera preview and on-device ML Kit face detection.
- A debounced detection state machine that requires repeated multi-face frames before activating protection.
- In-app privacy shield preview.
- Unit tests for the detection state machine.
- Camera frames are processed locally and are not saved or uploaded by the app code.

## Important limitations

- Multiple faces are only a heuristic. Face detection does not prove that someone is looking at the display.
- The privacy shield only covers the Flutter UI in this app. It cannot change viewing-angle optics or protect arbitrary apps.
- iOS does not allow a general-purpose overlay over arbitrary other apps.
- Android cross-app overlay support would need a separate native implementation and special user-granted access. Background camera behavior is restricted by Android versions and device policies.

## Run locally

The repository includes the Flutter application and generated Android/iOS platform folders.

1. Install Flutter stable and clone this repository.
2. Ensure the iOS deployment target is at least 15.5 (required by ML Kit).
3. The Android camera permission and iOS camera usage description are already declared in the platform files. Then run:

   ```bash
   flutter pub get
   flutter analyze
   flutter test
   flutter run
   ```

### Required camera permissions

The camera usage description is declared in `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Privacy Guard uses the front camera to detect a possible nearby viewer. Frames are processed on this device.</string>
```

The Android camera permission is declared in `android/app/src/main/AndroidManifest.xml`, above the `<application>` element:

```xml
<uses-permission android:name="android.permission.CAMERA" />
```

The camera plugin requests runtime camera access when the camera is initialized. Do not add microphone permission; this app does not record audio.

## Architecture

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Branch

Initial implementation is on [`feature/flutter-mvp`](https://github.com/aminemtar/PrivacyGuard/tree/feature/flutter-mvp). The default branch was only initialized with a README.
