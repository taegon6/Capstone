# ESP32 Wi-Fi CSI 기반 비접촉 사람 감지 및 Raspberry Pi 카메라 기반 사람/자세 판별 통합 시스템

## 프로젝트 개요
이 프로젝트는 ESP32-S3 Wi-Fi CSI(Channel State Information)를 이용해 사람 있음/없음, 정지/움직임, 간단한 활동 상태를 감지하고, Raspberry Pi 또는 노트북 카메라의 pose estimation 결과를 보조 기준으로 함께 보여주는 캡스톤 시연용 시스템입니다.

목표는 논문급 3D DensePose가 아니라 실제 보유 또는 구매 가능한 장비로 발표장에서 동작하는 통합 데모입니다. 실제 ESP32 데이터가 없어도 MATLAB mock CSI 데모가 실행되고, 카메라가 없어도 Python mock pose 데모가 실행됩니다.

## 범위 조정 이유
Wi-Fi CSI만으로 벽 너머 3D 자세나 DensePose를 안정적으로 복원하려면 다중 안테나, 동기화된 수집 장비, 대규모 라벨 데이터, 복잡한 딥러닝 모델이 필요합니다. 캡스톤 일정과 예산에서는 과장 없이 구현 가능한 범위인 presence, motion, simple activity classification으로 낮추고, 카메라 pose 결과를 비교 기준 또는 ground-truth 보조 모듈로 사용합니다.

심박수 추정은 구현하지 않습니다. 호흡 BPM 추정은 정지 상태의 mock/CSI amplitude에서 0.1~0.5 Hz 대역의 dominant frequency를 찾는 확장 기능으로만 제공합니다.

## 하드웨어
필수 또는 보유 예정:
- ESP32-S3-DevKitC-1 2개
- 기존 공유기 또는 스마트폰 핫스팟
- MATLAB 사용 가능 PC
- Python 사용 가능 PC

선택:
- Raspberry Pi 5
- Raspberry Pi Camera Module 또는 USB 웹캠
- 거치대 또는 삼각대

공유기는 별도 구매하지 않아도 됩니다. 기존 Wi-Fi AP나 스마트폰 핫스팟으로 ESP32 송수신 환경을 구성할 수 있습니다.

## MATLAB 데모 실행법
MATLAB에서 프로젝트 루트로 이동한 뒤:

```matlab
addpath(genpath("matlab"));
run("matlab/examples/run_offline_csi_demo.m");
run("matlab/examples/run_respiration_demo.m");
run("matlab/examples/run_activity_classifier_demo.m");
```

MATLAB 테스트:

```matlab
addpath(genpath("matlab"));
results = runtests("matlab/tests");
table(results)
```

## 실제 ESP32 CSI 로그 수집
ESP32-S3에 `firmware/esp32_csi_logger` 펌웨어를 업로드한 뒤 Serial 포트를 확인합니다.

```powershell
python -m serial.tools.list_ports -v
```

예를 들어 `COM11`이면 10초 샘플 수집:

```powershell
python scripts/capture_csi_serial.py --port COM11 --seconds 10 --label live_sample --echo
```

발표용 최소 데이터셋은 다음처럼 수집합니다.

```powershell
.\scripts\capture_csi_dataset.ps1 -Port COM11 -Seconds 30
```

수집 후 MATLAB 실제 로그 분석:

```matlab
run("matlab/examples/run_real_csi_log_demo.m");
```

## 공개 CSI 데이터셋 subset 데모
실제 수집 데이터가 약하거나 추가 비교 자료가 필요하면 HomeHAR 공개 ESP32 CSI 데이터셋의 작은 subset을 받을 수 있습니다.

```powershell
python scripts/download_public_csi_subset.py --rows 800
```

MATLAB 분석:

```matlab
run("matlab/examples/run_public_homehar_demo.m");
```

이 데이터는 외부 공개 데이터셋이므로 “우리 장비로 수집한 데이터”라고 주장하지 말고, 기존 연구 데이터 기반 파이프라인 검증용으로만 설명합니다.

MATLAB AI 분류 데모:

```matlab
run("matlab/examples/run_public_homehar_activity_ai_demo.m");
run("matlab/examples/run_phone_motion_ai_demo.m");
```

첫 번째는 HomeHAR 공개 데이터 subset의 activity label을 window feature로 학습/평가하고, 두 번째는 직접 수집한 `empty/static_person/moving_person` phone-connected 로그를 MATLAB 분류기로 학습/평가합니다.

현재 검증된 예시 결과:
- HomeHAR subset 4-class activity classifier: 약 75% accuracy
- 직접 수집한 phone-connected 3-class motion classifier: 약 68% accuracy

두 결과는 작은 데모 데이터 기준이므로 최종 성능 지표가 아니라 MATLAB AI 분류 파이프라인 검증 결과로 설명합니다.

## Python 카메라/Mock 데모 실행법
Windows PowerShell 예시:

```powershell
cd python
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python mock_pose_demo.py
pytest
```

웹캠이 있으면:

```powershell
python webcam_demo.py
```

API 서버:

```powershell
uvicorn api_server:app --reload --port 8000
```

대시보드:

```powershell
python dashboard_app.py
```

Raspberry Pi에서는 `opencv-python` 설치가 환경에 따라 무거울 수 있습니다. 설치가 실패하면 OS 패키지의 OpenCV(`python3-opencv`) 또는 headless 환경용 패키지를 검토하세요.

## 실제 ESP32 CSI 데이터 연결
1. ESP32-S3 두 대를 준비합니다. 한 대는 AP/송신 역할, 한 대는 수신 및 CSI 로그 출력 역할로 구성합니다.
2. 기존 공유기 또는 스마트폰 핫스팟을 사용해 같은 Wi-Fi 환경에 연결합니다.
3. ESP32-CSI-Tool 스타일로 `CSI_DATA,[...]`가 포함된 Serial 로그를 출력합니다.
4. MATLAB에서 `run("matlab/examples/run_realtime_serial_demo.m")`의 포트명을 실제 포트로 수정하거나 `realtimeSerialMonitor("COM3", 921600)`처럼 직접 호출합니다.
5. 저장된 CSV가 있으면 `loadCsiCsv`와 offline pipeline으로 분석합니다.

## 구현된 기능
- ESP32-CSI-Tool 스타일 CSI line 파싱
- raw integer CSI vector의 complex 변환
- amplitude/phase 추출, unwrap, 이상치 완화, smoothing, z-score 정규화
- sliding window 기반 CSI feature 추출
- threshold 기반 presence/motion detection
- mock activity dataset 기반 simple classifier demo
- 정지 구간 호흡 BPM 추정 demo
- MediaPipe Pose 기반 human 판별
- landmark rule 기반 standing/sitting/lying/possible_fall 분류
- FastAPI 통합 status 서버
- 콘솔 기반 dashboard polling

## 한계
- 실제 환경의 Wi-Fi multipath, AP/기기 배치, 사람 위치, 샘플링 안정성에 따라 CSI 품질이 크게 달라집니다.
- activity classification은 mock 또는 소규모 데이터 기준이며, 실제 발표 전 현장 데이터로 threshold를 보정해야 합니다.
- 호흡 BPM은 정지 상태에서만 확장 기능으로 다룹니다.
- 3D DensePose, 벽 너머 3D 자세 추정, 안정적인 심박수 추정은 구현 범위가 아닙니다.

## 향후 연구
- 실제 ESP32 CSI 데이터셋 수집 및 라벨링
- Raspberry Pi 24/7 edge server화
- camera pose 결과를 이용한 CSI label 자동 생성
- 환경별 threshold calibration
- Obsidian/API/외부 LLM 연동은 캡스톤 본 구현과 분리된 확장 서버 설계로 검토
