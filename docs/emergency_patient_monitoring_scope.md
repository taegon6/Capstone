# Emergency Patient Monitoring Scope

This capstone can be positioned as a proof-of-concept CSI-only patient monitoring assistant.

## Intended CSI-Only Emergency Logic
Normal actions are grouped as non-emergency:
- standing
- sitting
- walking or small movement
- static or low-motion states

Emergency candidate:
- CSI shows abrupt impact-like amplitude change
- the impact is followed by a low-motion/static window
- the pattern is classified as `emergency_fall`

## Practical CSI-Only Rule
Use CSI feature windows as the only emergency signal.

Example:

```text
if csi_classifier == emergency_fall:
    emergency = true
elif csi_diff_energy is very high and next window becomes low-motion:
    emergency_candidate = true
else:
    emergency = false
```

## What This Project Can Claim
- It implements MATLAB CSI feature extraction and demo classifiers.
- It demonstrates a mock CSI emergency fall classifier.
- It can be extended to real fall datasets or real staged fall collection.
- The emergency/patient-monitoring concept uses CSI only, without camera input.

## What This Project Should Not Claim
- Do not claim clinical-grade fall detection.
- Do not claim reliable emergency response without real fall data validation.
- Do not claim heart-rate monitoring.
- Do not claim wall-through 3D pose or DensePose.

## Next Data Needed
For a stronger patient-monitoring demo, collect or obtain:
- standing normal CSI
- sitting normal CSI
- walking normal CSI
- low-motion normal CSI
- staged fall CSI or public fall CSI dataset samples

The current `run_emergency_fall_ai_demo.m` is intentionally mock-based and should be described as an algorithm structure demo.
