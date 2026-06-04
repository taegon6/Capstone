# CSI Log Folder

Captured ESP32 CSI serial logs are saved here.

Recommended labels:
- `empty`: no person near the link
- `static_person`: person standing or sitting still
- `moving_person`: person walking or moving near the link

Use:

```powershell
python scripts/capture_csi_serial.py --port COM11 --seconds 30 --label empty
python scripts/capture_csi_serial.py --port COM11 --seconds 30 --label static_person
python scripts/capture_csi_serial.py --port COM11 --seconds 30 --label moving_person
```

