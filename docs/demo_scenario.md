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

