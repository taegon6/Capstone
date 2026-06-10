# MATLAB Simple Submission Code

이 폴더는 조교/교수님 확인용으로 줄인 MATLAB 코드입니다.  
원래 프로젝트에는 여러 실험 파일이 있지만, 제출용으로는 핵심 흐름만 남겼습니다.

## 파일 구성

```text
run_csi_capstone_demo.m
  메인 실행 파일
  실제 ESP32 로그가 있으면 읽고, 없으면 mock CSI로 실행

load_or_mock_csi.m
  ESP32 CSI 로그 파싱
  raw integer -> complex CSI 변환
  로그가 없을 때 mock CSI 생성

extract_simple_csi_features.m
  amplitude 계산
  smoothing / normalization
  window feature 추출

realtime_csi_demo_simple.m
  ESP32 serial port에서 CSI를 읽는 간단한 실시간 확인용 코드
```

## 실행 방법

MATLAB에서 프로젝트 루트로 이동한 뒤:

```matlab
addpath(genpath('matlab_simple'));
run('matlab_simple/run_csi_capstone_demo.m');
```

ESP32가 연결되어 있을 때만:

```matlab
addpath(genpath('matlab_simple'));
realtime_csi_demo_simple("COM11");
```

COM 포트가 다르면 `"COM11"` 부분만 바꾸면 됩니다.

## 발표에서의 표현

이 코드는 낙상을 정확히 진단하는 코드가 아닙니다.  
CSI 변화 패턴을 이용해서 `normal` / `fall_candidate`를 구분하는 캡스톤 데모입니다.

