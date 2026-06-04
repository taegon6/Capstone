# GPT Pro PPT 제작 프롬프트

아래 내용을 GPT Pro 또는 PPT 생성 기능에 그대로 붙여넣어 발표 자료를 만든다.  
목표는 연구 논문급 성능 주장보다, 실제 ESP32와 MATLAB으로 구현한 캡스톤 데모를 과장 없이 설득력 있게 보여주는 것이다.

---

## 1. GPT Pro에 넣을 전체 프롬프트

너는 공학 캡스톤 발표용 PPT를 만드는 전문 발표 디자이너다.

다음 프로젝트를 바탕으로 5분 발표용 한국어 PPT를 만들어라.

프로젝트 제목:
`Wi-Fi CSI 기반 프라이버시 보호형 비접촉 환자 이상 이벤트 감지 시스템`

부제:
`ESP32-S3와 MATLAB을 이용한 CSI-only 사람 감지, 움직임 분석, 낙상 의심 이벤트 데모`

중요한 방향:
- 이 발표는 카메라를 사용하지 않는 CSI-only 시스템으로 구성한다.
- 3D DensePose, 벽 너머 3D 자세 추정, 심박수 정확 추정은 구현했다고 말하지 않는다.
- 낙상은 "정확한 낙상 진단"이 아니라 "낙상 의심 이벤트 후보 감지"로 표현한다.
- 환자 진단, 의료기기 수준 정확도, 임상 검증 완료 같은 표현은 금지한다.
- 발표의 핵심은 "저가 ESP32 Wi-Fi CSI로 비영상 기반 모니터링 가능성을 구현했다"는 것이다.

PPT 스타일:
- 총 8장 내외
- 5분 발표 기준
- 공학 캡스톤 발표 느낌
- 너무 화려한 광고형 디자인보다, 깔끔한 기술 보고서형 디자인
- 색상은 흰색/짙은 남색/청록색/회색 중심
- 각 슬라이드는 제목이 명확해야 한다.
- 한 슬라이드에 글을 너무 많이 넣지 말고, 도식과 결과 이미지를 적극 활용한다.
- 발표자가 읽을 수 있는 speaker notes를 각 슬라이드마다 3~5문장으로 작성한다.

프로젝트 구현 내용:
1. ESP32-S3를 이용해 Wi-Fi CSI 로그를 수집한다.
2. CSI raw integer 데이터를 MATLAB에서 complex CSI로 변환한다.
3. amplitude, phase, unwrap, smoothing, z-score normalization으로 전처리한다.
4. sliding window별 mean, variance, energy, temporal difference energy, dominant frequency, PCA 기반 feature를 추출한다.
5. threshold 기반 presence/motion 감지와 MATLAB classical ML 기반 activity classification을 수행한다.
6. 환자 모니터링 데모에서는 normal과 emergency_fall 후보를 구분하는 mock CSI 데모를 구현했다.
7. real-time dashboard는 serial CSI를 읽어 현재 상태, diff energy, prediction history를 보여준다.

발표에서 사용할 실제 구현 결과:
- 실제 ESP32-S3 CSI 로그 수집 성공
- 스마트폰 핫스팟 연결 상태에서 empty/static_person/moving_person CSI 로그 수집
- phone CSI dataset summary:
  - empty_phone: 358 packets, mean_diff_energy 0.301150, moving_windows 2/12
  - static_person_phone: 604 packets, mean_diff_energy 0.070751, moving_windows 3/22
  - moving_person_phone: 576 packets, mean_diff_energy 0.169049, moving_windows 7/21
- phone motion AI demo:
  - fitcecoc, accuracy 0.6842, 55 windows, 3 classes
  - 단, 소규모 발표용 데이터이므로 일반화 성능으로 과장하지 않는다.
- realtime model demo:
  - fitcecoc, accuracy 0.7857, 55 windows, targetSubcarriers 192
  - 실시간 추론 파이프라인 검증용 결과로 표현한다.
- mock emergency fall demo:
  - fitcecoc, accuracy 1.0, 200 windows, 2 classes
  - 반드시 "mock CSI only, not clinical validation"이라고 명시한다.
- public HomeHAR subset demo:
  - fitcecoc, accuracy 0.75, 80 windows, 4 classes
  - 외부 공개 CSI 데이터에서도 파이프라인이 동작함을 보여주는 보조 검증으로 표현한다.

사용할 이미지 자료:
- `data/ppt_assets/01_system_architecture_ppt.png`
- `data/ppt_assets/02_phone_csi_summary_ppt.png`
- `data/ppt_assets/03_phone_motion_feature_scatter_ppt.png`
- `data/ppt_assets/04_emergency_feature_scatter_ppt.png`
- `data/ppt_assets/05_realtime_dashboard_preview_ppt.png`
- `data/ppt_assets/06_phone_csi_dataset_comparison.png`
- `data/ppt_assets/07_phone_motion_ai_confusion.png`
- `data/ppt_assets/08_phone_realtime_model_confusion.png`
- `data/ppt_assets/09_mock_emergency_fall_ai_confusion.png`
- `data/ppt_assets/10_public_homehar_activity_ai_confusion.png`
- `data/ppt_assets/11_public_homehar_summary.png`

슬라이드 구성:

1. 제목 슬라이드
   - 제목: Wi-Fi CSI 기반 프라이버시 보호형 비접촉 환자 이상 이벤트 감지 시스템
   - 부제: ESP32-S3 + MATLAB 기반 CSI-only 캡스톤 데모
   - 핵심 문장: 카메라 없이 Wi-Fi 신호 변화로 사람 존재, 움직임, 이상 이벤트 후보를 감지한다.

2. 문제 정의
   - 병실/실내 환자 모니터링에서 카메라는 프라이버시 부담이 크다.
   - 웨어러블은 착용 거부, 배터리, 착용 누락 문제가 있다.
   - 목표: 저가 Wi-Fi CSI 장비로 비접촉 이상 이벤트 감지 가능성을 검증한다.

3. 왜 Wi-Fi CSI인가
   - Wi-Fi 신호는 사람의 존재와 움직임에 따라 다중경로 특성이 변한다.
   - CSI는 subcarrier별 신호 변화 정보를 담는다.
   - ESP32-S3는 저가로 CSI 로그 수집이 가능하다.
   - 이미지는 얻지 않으므로 프라이버시 부담이 낮다.

4. 시스템 구조
   - ESP32-S3 CSI logger
   - Serial log / CSV
   - MATLAB CSI parser
   - preprocessing
   - feature extraction
   - presence/motion/activity/emergency candidate decision
   - dashboard
   - `01_system_architecture_ppt.png`를 넣는다.

5. MATLAB CSI 처리 파이프라인
   - raw CSI integer vector
   - complex CSI 변환
   - amplitude/phase
   - unwrap/smoothing/z-score
   - sliding window feature
   - threshold + classical ML
   - `02_phone_csi_summary_ppt.png` 또는 `06_phone_csi_dataset_comparison.png`를 넣는다.

6. 실제 수집 데이터 및 동작 분류 결과
   - empty/static_person/moving_person 데이터 수집 결과
   - phone motion AI accuracy 0.6842
   - realtime model accuracy 0.7857
   - `03_phone_motion_feature_scatter_ppt.png`, `07_phone_motion_ai_confusion.png`, `08_phone_realtime_model_confusion.png` 중 1~2개를 넣는다.
   - 작은 데이터셋 기반 데모 결과임을 명확히 표시한다.

7. 환자 이상 이벤트 데모
   - 정상 움직임과 낙상 의심 이벤트 후보를 CSI feature 패턴으로 구분하는 mock demo
   - 급격한 변화 + 이후 정적 상태를 fall-like candidate로 본다.
   - `04_emergency_feature_scatter_ppt.png`와 `09_mock_emergency_fall_ai_confusion.png`를 넣는다.
   - "임상 검증이 아닌 발표용 mock CSI 검증"이라고 표기한다.

8. 데모 시나리오와 결론
   - 1단계: ESP32 연결 및 CSI log 확인
   - 2단계: MATLAB offline 분석으로 presence/motion/activity 확인
   - 3단계: realtime dashboard로 상태 표시
   - `05_realtime_dashboard_preview_ppt.png`를 넣는다.
   - 기대효과: 저비용, 비영상, 비접촉 모니터링 가능성
   - 한계: 데이터셋 작음, 환경 변화 민감, 낙상/환자 상태의 실제 검증 필요
   - 향후 연구: 실제 환자 시나리오 데이터 수집, threshold 보정, 모델 일반화, Raspberry Pi edge server

반드시 포함할 표현:
- "비영상 기반 모니터링 가능성 검증"
- "낙상 의심 이벤트 후보"
- "소규모 캡스톤 데모 데이터"
- "임상 검증 또는 의료기기 수준 판정은 아님"
- "CSI-only 구조로 프라이버시 부담을 낮춤"

금지 표현:
- "정확한 낙상 진단"
- "환자 상태를 완벽하게 판별"
- "심박수 측정 성공"
- "3D 자세 추정 구현"
- "벽 너머 자세 인식"
- "의료기기로 즉시 사용 가능"

출력 형식:
- 슬라이드별 제목
- 슬라이드 본문 bullet
- 넣을 그림/도식 안내
- speaker notes
- 마지막에 5분 발표 대본 요약

---

## 2. 더 짧은 프롬프트

아래 프로젝트로 5분 캡스톤 발표용 PPT 8장을 만들어줘.  
주제는 `Wi-Fi CSI 기반 프라이버시 보호형 비접촉 환자 이상 이벤트 감지 시스템`이고, 카메라 없이 ESP32-S3 Wi-Fi CSI와 MATLAB만 사용한 CSI-only 데모야.  

핵심은 사람 있음/없음, 정지/움직임, 간단한 활동 분류, 낙상 의심 이벤트 후보 감지야. 3D 자세 추정, 심박수 정확 추정, 의료 진단은 구현 목표가 아니므로 절대 과장하지 마.  

실제 구현 결과로 ESP32 CSI 로그 수집, MATLAB 전처리/feature extraction, phone CSI activity demo accuracy 0.6842, realtime model demo accuracy 0.7857, mock emergency fall demo accuracy 1.0, public HomeHAR subset demo accuracy 0.75가 있어. 단, accuracy는 소규모 데모 또는 mock 데이터 기준이라고 명확히 표시해.  

슬라이드는 문제 정의, Wi-Fi CSI 원리, 시스템 구조, MATLAB 처리 파이프라인, 실제 수집 결과, 환자 이상 이벤트 데모, 실시간 대시보드, 한계 및 향후 연구 순서로 구성해.  

각 슬라이드마다 제목, 짧은 bullet, 넣을 그림 안내, speaker notes를 작성해줘. 발표 톤은 공학 캡스톤 발표답게 현실적이고 과장 없는 기술 발표로 만들어줘.
