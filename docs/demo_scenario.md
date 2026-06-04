# 캡스톤 데모 시나리오

## 1단계: MATLAB mock CSI 데모
1. `run_offline_csi_demo.m` 실행
2. 사람이 없는 구간, 정지 구간, 움직임 구간이 섞인 mock CSI 생성
3. amplitude heatmap, 전처리 결과, presence/motion 판정 그래프 표시
4. 실제 ESP32가 없어도 Wi-Fi CSI 분석 흐름을 설명

## 2단계: Python webcam pose 데모
1. 카메라가 있으면 `webcam_demo.py` 실행
2. 화면에 human/not human, posture, confidence 표시
3. 카메라가 없으면 `mock_pose_demo.py`로 동일한 판별 로직 시연

## 3단계: 통합 대시보드
1. `uvicorn api_server:app --reload --port 8000` 실행
2. CSI 결과와 pose 결과를 `/csi_result`, `/pose_result`로 전송
3. `dashboard_app.py`에서 최신 통합 상태 표시
4. CSI 결과와 카메라 결과가 같은 상황을 어떻게 보완적으로 설명하는지 발표

## 보강 데모: 실제 ESP32 + 공개 데이터셋
1. `capture_csi_dataset.ps1`로 empty/static/moving 실제 로그를 수집한다.
2. `run_real_csi_dataset_comparison.m`으로 실제 데이터의 heatmap과 feature 요약을 보여준다.
3. `download_public_csi_subset.py`로 HomeHAR 공개 ESP32 CSI subset을 다운로드한다.
4. `run_public_homehar_demo.m`으로 외부 데이터셋에도 파서/전처리/feature 추출이 적용됨을 보여준다.
5. 공개 데이터는 검증용 reference이며, 본 프로젝트 장비로 수집한 데이터라고 설명하지 않는다.
