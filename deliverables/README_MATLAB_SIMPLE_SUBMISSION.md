# MATLAB 간단 제출 코드 설명

PPT는 별도로 준비하고, 조교 확인용 MATLAB 코드는 `matlab_simple` 폴더만 보면 됩니다.

## 실행 파일

```text
matlab_simple/run_csi_capstone_demo.m
```

## 실행 방법

MATLAB에서 프로젝트 루트로 이동한 뒤:

```matlab
addpath(genpath('matlab_simple'));
run('matlab_simple/run_csi_capstone_demo.m');
```

## 코드 흐름

```text
1. ESP32 CSI 로그 읽기
2. 로그가 없으면 mock CSI 생성
3. raw CSI -> complex CSI 변환
4. amplitude 계산
5. smoothing / normalization
6. window feature 추출
7. decision tree로 normal / fall candidate 분류
8. 결과 그래프 저장
```

## 포함 파일

```text
matlab_simple/
  README.md
  run_csi_capstone_demo.m
  load_or_mock_csi.m
  extract_simple_csi_features.m
  realtime_csi_demo_simple.m

simple_results/
  simple_csi_demo_result.png
  simple_csi_features.csv
```

## 주의

`fall_candidate`는 실제 환자 낙상 데이터가 아니라 mock 데이터입니다.  
발표에서는 "정확한 낙상 진단"이 아니라 "낙상 의심 이벤트 후보 감지"라고 설명합니다.

