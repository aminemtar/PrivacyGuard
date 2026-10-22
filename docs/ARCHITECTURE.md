# Privacy Guard architecture

## Detection flow

1. The user opens Live detection and grants camera access.
2. The front camera feeds frames to on-device ML Kit face detection.
3. Face counts are passed to `DetectionEngine`, which requires repeated detections before showing the in-app shield and a clear-frame window before removing it.
4. Camera capture stops when the detection screen is inactive or the app moves to the background.

## Detection caveat

A second detected face is only a heuristic for a possible nearby viewer. Face detection does not establish gaze direction, screen attention, or malicious intent.

## Protection layers

- `PrivacyOverlay` covers only the Flutter subtree where it is installed.
- Android's `PrivacyOverlayService` adds a manual, full-screen translucent tint using `WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY`. The user must grant Android's special Display over other apps access.
- The native overlay does not use the camera and is not currently linked to the face detector. It is a manual software tint, not an optical privacy filter and not equivalent to a physical privacy screen protector.
- iOS does not provide a general-purpose overlay API for arbitrary apps.

## Android background restrictions

Camera detection and cross-app overlay are deliberately separate. Android restricts background camera use; a service cannot safely promise continuous face-based detection while arbitrary apps are foregrounded. The current cross-app tint is manual, and OEM battery/service policies may stop it. The user can return to Privacy Guard to stop the overlay or revoke overlay access in Android Settings.

## Data minimization

- Do not upload camera frames or face data.
- Do not save frames or face geometry.
- Avoid logging image content or biometric data.
- Stop camera capture when monitoring ends or the app becomes inactive.
- Provide clear permission rationale and a manual disable control.

## Validation still required

- Run `flutter analyze` and `flutter test` on the developer machine.
- Build and test on a physical Android device, including granting/revoking overlay permission.
- Verify the overlay can be stopped after switching between apps and test behavior after screen lock, app process termination, and device restart.
- Test iOS camera permission and detection independently; Android-wide overlay is not available on iOS.
