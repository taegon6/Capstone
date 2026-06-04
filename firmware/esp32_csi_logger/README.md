# ESP32-S3 CSI Logger Firmware

This PlatformIO firmware turns one ESP32-S3-DevKitC-1 into a Wi-Fi CSI serial logger.

## Behavior
- Starts a SoftAP named `CSI_CAPSTONE_AP`.
- Enables ESP-IDF CSI callbacks through Arduino framework.
- Prints CSI rows to Serial at `921600` baud.
- Output includes `CSI_DATA,...,[raw integers]`, compatible with the MATLAB parser in this repository.

## Build
```powershell
cd firmware/esp32_csi_logger
python -m platformio run
```

## Upload
```powershell
python -m platformio run --target upload --upload-port COMx
```

## Generate CSI Traffic
Connect a phone, laptop, or another ESP32 to `CSI_CAPSTONE_AP`, then generate network traffic such as ping or a web request. CSI appears only when the ESP32 receives Wi-Fi frames.

