# 제출 패키지 안내

제출 조건:

```text
발표 ppt, 매트랩 구현 파일(코드, 앱디자이너, 피팅툴 등)
압축하여 1개의 파일로 제출
파일명: 조 이름.zip
```

본 프로젝트 제출물은 다음 기준으로 구성한다.

## 포함 파일

- `WiFi_CSI_patient_monitoring_capstone.pptx`
  - 발표용 PPT
  - MATLAB 결과 이미지와 구현 흐름 포함

- `matlab/`
  - CSI parsing, preprocessing, feature extraction, detection, activity/emergency demo 코드
  - 주요 함수에 입력/출력/처리 흐름 주석 추가

- `data/ppt_assets/`
  - PPT에 사용한 MATLAB export 이미지

- `data/results/`
  - MATLAB 분석 결과 CSV/PNG

- `README_submission.md`
  - 제출 파일 실행 순서와 발표 시 주의할 표현 정리

## 발표에서 강조할 점

- 카메라 없이 CSI-only로 구성한 비영상 기반 모니터링 데모
- ESP32-S3와 MATLAB만으로 구현 가능한 저비용 캡스톤 시스템
- 낙상은 진단이 아니라 "낙상 의심 이벤트 후보"로 표현
- 실제 임상 검증이나 의료기기 수준 성능 주장은 하지 않음

## 제출 전 실행 명령

```matlab
addpath(genpath('matlab'));
run('matlab/examples/export_ppt_assets.m');
```

```powershell
powershell -ExecutionPolicy Bypass -File scripts/create_submission_ppt.ps1
```

압축 파일은 `deliverables/CSI_환자감지_조.zip` 위치에 만든다.
