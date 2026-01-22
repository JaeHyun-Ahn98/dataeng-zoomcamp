# 📝 Kestra 파이썬 오케스트레이션 트러블슈팅

## 1. 문제 상황 및 에러 로그 분석

실행 과정에서 총 세 가지 주요 에러를 만났습니다.

### ① 권한 에러 (OS Error 13)
**증상:** Permission denied (os error 13) 발생.

**원인:** Kestra의 기본 패키지 매니저인 **uv**가 파이썬 환경을 새로 구축하려고 컨테이너 내부의 /tmp 디렉토리에 파일을 쓰고 실행하려 했으나, Docker 보안 설정으로 인해 실행 권한이 거부됨.

### ② 필드 인식 에러 (Validation Error)
**증상:** Unrecognized field "pythonInterpreter" 발생.

**원인:** Kestra 버전에 따라 허용되는 속성 이름이 다름. 해당 버전에서는 pythonInterpreter 대신 interpreter를 사용해야 했음.

### ③ 실행 경로 에러 (Exit Code 2)
**증상:** python3: can't open file 'set -e...' 발생.

**원인:** interpreter 필드를 수동으로 설정하는 과정에서 Kestra가 내부적으로 생성하는 실행 명령어와 충돌이 발생하여, 파이썬 파일의 경로를 비정상적으로 인식함.

## 2. 해결 과정 (Step-by-Step)

**패키지 매니저 변경:** 권한 문제가 까다로운 uv 대신, 좀 더 표준적이고 단순한 **PIP**로 변경하여 권한 충돌을 피함.

**환경 고정:** Kestra가 파이썬을 새로 설치하지 않도록 containerImage를 명시하고, 이미 설치된 파이썬을 쓰도록 유도함.

**명령어 최적화:** 수동으로 설정했던 interpreter 필드를 제거하여 Kestra 엔진이 컨테이너 환경에 맞는 최적화된 실행 명령어를 자동으로 생성하게 함.

## 3. 최종 해결 코드 (Success Code)

이 코드가 성공한 이유는 **"권한 문제는 PIP로 피하고, 실행 방식은 Kestra의 기본 로직에 맡겼기 때문"**입니다.

```yaml
id: 02_python
namespace: zoomcamp

tasks:
  - id: collect_stats
    type: io.kestra.plugin.scripts.python.Script
    taskRunner:
      type: io.kestra.plugin.scripts.runner.docker.Docker
    containerImage: python:3.11-slim

    # [핵심 해결책]
    # uv 대신 pip를 사용하여 /tmp 권한 문제를 우회함
    packageManager: PIP

    dependencies:
      - requests
      - kestra
    script: |
      from kestra import Kestra
      import requests

      def get_docker_image_downloads(image_name: str = "kestra/kestra"):
          url = f"https://hub.docker.com/v2/repositories/{image_name}/"
          response = requests.get(url)
          data = response.json()
          downloads = data.get('pull_count', 'Not available')
          return downloads

      downloads = get_docker_image_downloads()
      # 결과를 Kestra UI의 Outputs 탭으로 전달
      Kestra.outputs({'downloads': downloads})
```

## 4. 학습 포인트

**Docker 기반 실행:** 파이썬 코드는 로컬 컴퓨터가 아닌 독립된 도커 컨테이너에서 돌아가므로, dependencies에 적은 라이브러리는 매번 새로 설치됩니다.

**Outputs 활용:** Kestra.outputs()를 통해 파이썬 내부의 데이터를 Kestra 워크플로우 변수로 변환할 수 있습니다.