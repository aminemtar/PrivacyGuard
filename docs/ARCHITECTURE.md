# Privacy Guard architecture

## MVP boundary

The first milestone provides a Flutter dashboard, persisted enable/disable preference, a reusable in-app privacy shield, and a pure detection state machine with tests. The dashboard's camera integration is not implemented yet; the UI labels this honestly.

## Proposed flow

1. Ask the user to enable monitoring and explain why the front camera is needed.
2. Request camera permission only when the user starts detection.
3. Process camera frames on-device using ML Kit face detection.
4. Feed face counts into `DetectionEngine`.
5. Require repeated positive frames before protecting content and a clear-frame window before restoring it.
6. On camera errors, permission revocation, app backgrounding, or lifecycle changes, stop capture safely and show the current state clearly.

## Detection caveat

A second detected face is only a heuristic for a possible nearby viewer. Face detection does not establish gaze direction, screen attention, or malicious intent. The app must avoid describing this signal as certainty.

## Protection boundary

`PrivacyOverlay` only covers the Flutter subtree in which it is installed. It cannot change viewing-angle optics or hide content in arbitrary applications.

Android cross-app overlays require native implementation and user-granted special access; background camera access is separately restricted by Android versions and device policy. iOS does not provide a general-purpose overlay API for arbitrary apps. The cross-app feature is therefore an optional Android investigation, not a shared Flutter promise.

## Data minimization

- Do not upload camera frames or face data.
- Do not save frames or face geometry.
- Avoid logging image content or biometric data.
- Stop the camera when monitoring ends or the app becomes inactive.
- Provide clear permission rationale and a manual disable control.

## Next engineering steps

1. Add a camera controller service and platform-specific frame conversion.
2. Connect the frame stream to ML Kit with throttling and disposal handling.
3. Add app lifecycle behavior and permission denial states.
4. Add an interactive camera test screen.
5. Investigate Android overlay feasibility in a native Kotlin adapter after in-app detection is validated.
