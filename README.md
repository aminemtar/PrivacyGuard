# Privacy Guard

Flutter app for experimenting with shoulder-surfing signals and privacy protection on Android and iOS.

## Current features

- Premium blue dashboard with a saved enable/disable preference.
- Front-camera preview and on-device ML Kit face detection while the detection screen is active.
- A debounced detection state machine that requires repeated multi-face frames before activating protection.
- In-app privacy shield preview.
- Android-only manual screen-wide dimming overlay using a native Kotlin service and the system Display over other apps permission.
- Unit tests for the detection state machine.
- Camera frames are processed locally and are not saved or uploaded by the app code.

## Important limitations

- **This is not a physical anti-spy filter.** An app cannot change the display's viewing angles. The Android overlay darkens/tints the screen and may reduce casual visibility, but it cannot make the display optically invisible from the side.
- The Android-wide overlay is **manual**, not automatically triggered by camera detection. The camera detector stops when the detection screen/app becomes inactive, as required by normal camera lifecycle handling and platform restrictions.
- A second face is only a rough heuristic. It does not prove that someone is looking at the display.
- iOS does not allow a general-purpose overlay over arbitrary other apps. The Android-wide tint feature is Android-only.
- Some Android vendors may restrict or kill background services. The user can stop the overlay from the app; if needed, revoke Display over other apps access in Android Settings or force-stop the app.
- The overlay is intentionally non-touchable so it does not intercept taps; its dim tint may make underlying content harder to read.

## Run locally

1. Install Flutter stable and clone this repository.
2. Ensure the iOS deployment target is at least 15.5 (required by ML Kit).
3. Run:

   ```bash
   flutter pub get
   flutter analyze
   flutter test
   flutter run
   ```

### Permissions

Android declares the camera permission and SYSTEM_ALERT_WINDOW. The camera plugin requests camera access when detection starts. The screen-wide overlay requires the user to explicitly grant **Display over other apps** access from Android Settings. No microphone permission is required.

iOS declares NSCameraUsageDescription in ios/Runner/Info.plist.

## Architecture

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Branch

Implementation is on [feature/flutter-mvp](https://github.com/aminemtar/PrivacyGuard/tree/feature/flutter-mvp).
