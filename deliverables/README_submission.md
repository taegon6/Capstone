# 제출 자료 설명

프로젝트명:

```text
Wi-Fi CSI 기반 비접촉 환자 이상 이벤트 감지 시스템
```

## 1. 제출물 구성

```text
WiFi_CSI_patient_monitoring_capstone.pptx
MATLAB구현/
결과자료/
README_submission.md
```

## 2. 발표 PPT

파일:

```text
WiFi_CSI_patient_monitoring_capstone.pptx
```

내용:

- 문제 정의
- Wi-Fi CSI 원리
- ESP32-S3 + MATLAB 시스템 구조
- CSI 전처리 및 feature extraction
- 실제 수집 CSI 결과
- 활동 분류 및 실시간 모델
- 낙상 의심 이벤트 후보 감지
- 한계 및 향후 연구

## 3. MATLAB 실행 방법

MATLAB에서 프로젝트 루트로 이동한 뒤 실행한다.

```matlab
addpath(genpath('matlab'));
run('matlab/examples/run_offline_csi_demo.m');
```

실제 수집 데이터 비교:

```matlab
addpath(genpath('matlab'));
run('matlab/examples/run_phone_csi_dataset_comparison.m');
```

활동 분류 데모:

```matlab
addpath(genpath('matlab'));
run('matlab/examples/run_phone_motion_ai_demo.m');
```

낙상 의심 이벤트 후보 데모:

```matlab
addpath(genpath('matlab'));
run('matlab/examples/run_emergency_fall_ai_demo.m');
```

실시간 대시보드:

```matlab
addpath(genpath('matlab'));
run('matlab/examples/run_realtime_csi_dashboard_demo.m');
```

주의:

- 실시간 대시보드는 ESP32가 연결되어 있고 COM port가 맞아야 실행된다.
- 현재 기본 port는 `COM11` 기준으로 작성되어 있다.
- port가 다르면 `matlab/examples/run_realtime_csi_dashboard_demo.m`에서 port 값을 수정한다.

## 4. 발표 시 표현 주의

본 프로젝트는 캡스톤 데모이므로 다음처럼 설명한다.

```text
낙상 진단이 아니라 낙상 의심 이벤트 후보 감지
비영상 기반 모니터링 가능성 검증
소규모 실제 수집 데이터 및 mock emergency 데이터 기반 데모
```

다음 표현은 사용하지 않는다.

```text
정확한 낙상 진단
의료기기 수준 판정
심박수 안정 측정
3D 자세 추정
벽 너머 자세 인식
```

## 5. 핵심 차별점

- 고가 장비가 아니라 ESP32-S3 기반으로 구현
- 카메라 없이 CSI-only 구조로 프라이버시 부담 감소
- MATLAB 신호처리 파이프라인을 직접 구현
- mock data, 실제 수집 log, 공개 CSI 데이터, 실시간 dashboard까지 연결

