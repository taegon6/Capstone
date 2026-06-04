# 보고서 목차

제목: ESP32 Wi-Fi CSI 기반 비접촉 사람 감지 및 카메라 기반 자세 판별 보조 시스템의 구현

1. 연구 배경
2. 시스템 구성
3. ESP32 Wi-Fi CSI 수집 구조
4. MATLAB 기반 CSI 전처리
5. 사람 있음/없음 및 움직임 감지 알고리즘
6. Raspberry Pi 카메라 기반 pose estimation 보조 모듈
7. 통합 실험 시나리오
8. 성능 평가 방법
9. 한계 및 향후 연구

## 부록 후보
- ESP32-S3 CSI logger 펌웨어 구조
- 실제 수집 로그 예시
- HomeHAR 공개 데이터셋 subset 분석 결과
- Python pose/API/dashboard 실행 화면
- 전체 검증 명령 및 테스트 결과

## 성능 평가 예시
- presence detection: 사람 없음/있음 구간별 정확도
- motion detection: 정지/움직임 구간별 정확도
- activity classification: confusion matrix
- pose 보조 모듈: human 판별 threshold 통과율과 posture rule 사례 분석
