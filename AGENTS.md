# Project Agent Guide

This capstone project prioritizes a working demo over research-grade 3D pose reconstruction.

## Scope
- Implement ESP32 Wi-Fi CSI based presence, motion, simple activity, and optional respiration demos.
- Implement camera based human and posture assistance using MediaPipe when available.
- Keep mock paths working without ESP32, Raspberry Pi, or webcam hardware.

## Guardrails
- Do not claim actual 3D DensePose, wall-through 3D pose, or reliable heart-rate estimation.
- Do not hard-code API keys.
- Keep MATLAB and Python modules separated.
- Prefer rule-based and classical ML logic that can run on ordinary laptops.

