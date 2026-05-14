# Raspberry Pi 24/7 개인 서버 확장 설계

이 문서는 캡스톤 본 구현과 분리된 향후 확장안이다.

## 가능한 역할
- CSI/pose demo 로그 저장
- Obsidian vault sync 보조 서버
- 간단한 API gateway skeleton
- 외부 LLM API 호출 실험

## API key 관리
외부 LLM API를 연동할 경우 API key는 코드에 하드코딩하지 않는다.

예:
```bash
export OPENAI_API_KEY="..."
```

Python에서는 `os.environ.get("OPENAI_API_KEY")`처럼 환경변수에서 읽는다.

## Obsidian vault sync
- Syncthing, Git, 클라우드 드라이브 중 하나를 선택한다.
- 캡스톤 결과 문서와 실험 로그를 Markdown으로 정리한다.
- 자동 요약이나 LLM 연동은 별도 스크립트로 분리한다.

## 로컬 모델 구동 한계
Raspberry Pi는 저전력 edge server로는 적합하지만 대형 LLM이나 무거운 vision model을 직접 구동하기에는 제한적이다. 작은 모델 또는 API gateway 용도로 사용하는 편이 현실적이다.

## 미니PC와 비교
미니PC는 서버, 로컬 모델, 데이터 저장 측면에서 더 적합할 수 있다. 다만 본 프로젝트 예산안은 ESP32, Raspberry Pi, 카메라 중심으로 구성하므로 미니PC는 제외한다.

