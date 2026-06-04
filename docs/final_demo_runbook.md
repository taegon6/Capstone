# Final Demo Runbook

This runbook describes the practical capstone demo sequence.

## 1. ESP32 Live CSI
1. Connect ESP32-S3 to the laptop.
2. Confirm the serial port:
   ```powershell
   python -m serial.tools.list_ports -v
   ```
3. Monitor live CSI:
   ```powershell
   cd firmware/esp32_csi_logger
   python -m platformio device monitor --port COM11 --baud 921600
   ```
4. If collecting a dataset:
   ```powershell
   .\scripts\capture_csi_dataset.ps1 -Port COM11 -Seconds 30
   ```

## 2. Real CSI Analysis
Run the comparison of collected logs:

```matlab
run("matlab/examples/run_real_csi_dataset_comparison.m");
```

Outputs:
- `data/results/real_csi_dataset_summary.csv`
- `data/results/real_csi_dataset_comparison.png`

## 3. Public Dataset Validation
Download a small HomeHAR subset:

```powershell
python scripts/download_public_csi_subset.py --rows 800
```

Analyze it:

```matlab
run("matlab/examples/run_public_homehar_demo.m");
```

Outputs:
- `data/results/public_homehar_summary.csv`
- `data/results/public_homehar_summary.png`

Explain this as external validation only. Do not claim the public dataset was collected with this project's ESP32-S3 hardware.

## 4. Camera Pose Demo
Camera available:

```powershell
cd python
python webcam_demo.py
```

No camera:

```powershell
cd python
python mock_pose_demo.py
```

## 5. API/Dashboard Demo
Start API:

```powershell
cd python
python api_server.py
```

Seed demo data:

```powershell
curl -X POST http://127.0.0.1:8000/demo/mock_status
```

Run dashboard:

```powershell
python dashboard_app.py
```

## 6. One-Shot Verification

```powershell
.\scripts\run_project_verification.ps1
```

Use `-SkipMatlab` when MATLAB is not available.

