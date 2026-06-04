# PPT 제작용 자료 정리

이 문서는 GPT Pro로 PPT를 만들 때 같이 제공할 프로젝트 자료 요약이다.

## 발표 방향

- 최종 발표 방향: CSI-only 환자 이상 이벤트 감지 보조 시스템
- 사용 장비: ESP32-S3-DevKitC-1, 노트북, MATLAB
- 카메라: 이번 발표 방향에서는 사용하지 않음
- 핵심 메시지: 카메라 없이 Wi-Fi CSI 변화만으로 사람 존재, 움직임, 낙상 의심 이벤트 후보를 감지하는 캡스톤 데모

## 한 문장 소개

ESP32-S3에서 수집한 Wi-Fi CSI를 MATLAB에서 전처리하고 feature를 추출해, 사람 존재/움직임/간단한 활동 상태와 낙상 의심 이벤트 후보를 비영상 방식으로 표시하는 시스템이다.

## 발표에 넣기 좋은 핵심 수치

| 항목 | 결과 | 발표용 해석 |
|---|---:|---|
| phone CSI activity demo | accuracy 0.6842 | 소규모 실제 수집 CSI로 분류 파이프라인 검증 |
| realtime CSI model demo | accuracy 0.7857 | 실시간 추론용 모델 구성 가능성 확인 |
| mock emergency fall demo | accuracy 1.0000 | 낙상 의심 이벤트 로직의 mock 검증 |
| public HomeHAR subset demo | accuracy 0.7500 | 외부 공개 CSI 데이터에서도 pipeline 동작 확인 |

주의: 위 수치는 캡스톤 데모 범위의 결과이며, 임상 성능이나 일반화 성능으로 주장하지 않는다.

## 실제 수집 phone CSI 요약

| label | packets | mean_diff_energy | moving_windows / total_windows |
|---|---:|---:|---:|
| empty_phone | 358 | 0.301150 | 2 / 12 |
| static_person_phone | 604 | 0.070751 | 3 / 22 |
| moving_person_phone | 576 | 0.169049 | 7 / 21 |

발표 해석:
- 사람/움직임 조건에 따라 CSI amplitude와 window feature가 달라진다.
- 단일 수치 하나로 완벽히 구분하는 것이 아니라 여러 feature와 window 기반 판단을 사용한다.

## 사용 가능한 그림 자료

| 파일 | 용도 |
|---|---|
| `data/results/phone_csi_dataset_comparison.png` | 실제 수집 CSI 조건별 비교 |
| `data/results/phone_motion_ai_confusion.png` | phone motion AI 분류 결과 |
| `data/results/phone_realtime_model_confusion.png` | 실시간 모델 학습 결과 |
| `data/results/mock_emergency_fall_ai_confusion.png` | 낙상 의심 이벤트 mock 분류 결과 |
| `data/results/public_homehar_summary.png` | 공개 CSI 데이터 summary |
| `data/results/public_homehar_activity_ai_confusion.png` | 공개 CSI 데이터 activity classification 결과 |

## 슬라이드별 추천 자료

1. 제목
   - CSI-only, privacy-preserving, non-contact patient monitoring 키워드

2. 문제 정의
   - 카메라: 프라이버시 부담
   - 웨어러블: 착용 불편, 배터리, 착용 누락
   - LiDAR/고가 센서: 비용 부담
   - Wi-Fi CSI: 저비용, 비영상, 비접촉

3. Wi-Fi CSI 원리
   - 사람이 움직이면 Wi-Fi 다중경로가 변함
   - CSI는 subcarrier별 신호 변화 기록
   - amplitude/phase 변화에서 activity clue를 얻음

4. 시스템 구조
   - ESP32-S3 CSI logger
   - Serial/CSV
   - MATLAB preprocessing
   - feature extraction
   - classifier / rule
   - dashboard

5. MATLAB pipeline
   - parse CSI line
   - raw integer to complex CSI
   - amplitude/phase
   - unwrap, smoothing, z-score
   - sliding window features
   - threshold / fitcecoc classifier
   - 추천 이미지: `phone_csi_dataset_comparison.png`

6. 실제 데이터 결과
   - empty/static/moving 조건 비교
   - phone motion AI accuracy 0.6842
   - realtime model accuracy 0.7857
   - 추천 이미지: `phone_motion_ai_confusion.png`, `phone_realtime_model_confusion.png`

7. 환자 이상 이벤트 mock demo
   - 정상 활동과 fall-like event를 mock CSI로 합성
   - 급격한 변화 후 정적 상태를 낙상 의심 후보로 판단
   - 추천 이미지: `mock_emergency_fall_ai_confusion.png`

8. 결론 및 한계
   - 구현 완료: ESP32 CSI 수집, MATLAB 분석, real-time dashboard
   - 한계: 데이터 수 부족, 환경 변화 민감, 환자 실제 데이터 미검증
   - 향후: 실제 시나리오 데이터 수집, 모델 보정, Raspberry Pi edge server

## 발표에서 쓰면 좋은 문장

- 본 프로젝트는 카메라 없이 Wi-Fi CSI만으로 비영상 기반 모니터링 가능성을 검증하는 캡스톤 데모입니다.
- CSI는 사람의 존재와 움직임에 의해 달라지는 Wi-Fi 다중경로 변화를 subcarrier 단위로 기록합니다.
- 낙상은 의료 진단으로 판정하지 않고, 급격한 CSI 변화와 이후 정적 상태를 이용해 낙상 의심 이벤트 후보로 표시합니다.
- 현재 결과는 소규모 실제 수집 데이터와 mock emergency 데이터 기반이므로, 임상 검증이나 일반화 성능으로 해석하지 않습니다.
- 향후 실제 환자 시나리오 데이터를 확보하면 threshold 보정과 모델 일반화 검증이 가능합니다.

## 발표에서 피해야 할 문장

- 낙상을 정확히 진단할 수 있다.
- 환자 상태를 완벽히 판별한다.
- 심박수를 안정적으로 측정했다.
- 3D 자세를 복원했다.
- 벽 너머로 자세를 인식한다.
- 의료기기로 바로 사용할 수 있다.

## 데모 설명 순서

1. ESP32-S3가 CSI 로그를 serial로 출력한다.
2. MATLAB이 CSI_DATA line을 파싱한다.
3. raw integer vector를 complex CSI로 변환한다.
4. amplitude/phase를 전처리한다.
5. sliding window feature를 추출한다.
6. classifier 또는 rule이 상태를 판정한다.
7. dashboard가 현재 상태와 feature 변화를 표시한다.

## 참고 자료

- 프로젝트 GitHub: `https://github.com/taegon6/Capstone`
- 공개 CSI 데이터 보조 검증: `https://huggingface.co/datasets/gadgadgad/HomeHAR`

