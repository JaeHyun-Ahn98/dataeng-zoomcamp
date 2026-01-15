# 🚀 TIL: Docker 볼륨 마운트 & Git Bash 경로 변환 오류 해결

## ❌ 발생한 문제
- **상황**: Git Bash(MINGW64)에서 아래 명령 실행 후 컨테이너 안에서 `/app` 디렉토리가 보이지 않음.
  - `docker run -it --entrypoint=bash -v $(pwd)/test:/app/test python:3.13.11-slim`
- **증상**:
  - 컨테이너 내부 `ls` 결과에 `/app` 대신 `'\Program Files\Git\app\test'` 같은 이상한 디렉토리가 보임.
  - 호스트(윈도우) 쪽에서도 `test;C/` 같은 이상한 폴더가 생성됨.

## 🛠️ 원인 & 해결 과정
1. **원인 파악**
   - 환경이 **Windows + Git Bash(MINGW64)** 인 상태에서 `-v` 옵션을 사용.
   - Git Bash는 `/c/...` 같은 경로를 Docker에 넘길 때, 자동으로 `C:\...` 형태의 윈도우 경로로 바꾸려고 함(**경로 자동 변환, path conversion**).
   - 이 변환이 `$(pwd)/test:/app/test` 에도 적용되면서, Docker가 의도와 다르게
     - 호스트: 이상한 변환 경로
     - 컨테이너: `\Program Files\Git\app\test` 같은 깨진 경로
     로 인식하게 되었고, 그 결과 **`/app/test` 마운트가 제대로 설정되지 않음**.

2. **왜 `MSYS_NO_PATHCONV=1` 로 해결했는가**
   - Git Bash의 path conversion 문제를 없애려면, **“경로를 건드리지 말고 내가 적은 문자열 그대로 Docker에 보내라”**고 지시해야 함.
   - `MSYS_NO_PATHCONV=1` 은 Git Bash에게:
     - “이 명령 실행할 때는 **경로 자동 변환 기능을 끄라**”
     라는 의미의 환경 변수.
   - 따라서 아래처럼 실행하면,
     - `$(pwd)/test:/app/test` 가 **아무 변형 없이 그대로** Docker에 전달됨:
       - `MSYS_NO_PATHCONV=1 docker run -it --entrypoint=bash -v "$(pwd)/test:/app/test" python:3.13.11-slim`
   - 이렇게 하자 컨테이너 안에서 `/app` 과 `/app/test` 가 정상적으로 보이고,
     - `/app/test` 안에 호스트 `test` 폴더의 파일이 그대로 나타나는 것을 확인.

3. **검증 과정**
   - 컨테이너 내부에서:
     - `ls /app`
     - `ls /app/test`
   - 위 명령으로 디렉토리 존재 및 파일 목록을 확인하여, **마운트가 의도대로 되었는지** 검증.

4. **정리 작업**
   - 이전에 깨진 경로로 인해 호스트에 생겼던 이상한 폴더(`test;C` 등)를 수동으로 삭제해서 디렉토리 정리.

## 💡 배운 점
- Docker 볼륨 마운트의 기본 형태는 `-v 호스트경로:컨테이너경로` 이고, 두 경로가 **어떤 문자열로 Docker에 전달되는지**가 매우 중요하다.
- Windows + Git Bash 환경에서는 Git Bash가 `-v` 안의 경로를 자동 변환할 수 있어, **의도와 다르게 마운트 경로가 깨지는 문제**가 발생할 수 있다.
- 이때 `MSYS_NO_PATHCONV=1` 을 사용하면 Git Bash의 자동 변환을 끄고, **내가 쓴 경로 그대로 Docker에 전달**할 수 있다.
- 컨테이너 관련 문제를 디버깅할 때는 항상 **“호스트에서 보이는 경로”와 “컨테이너 안에서 보이는 경로”를 분리해서 생각하고**, 이상한 디렉토리 이름이 보이면 **쉘이 경로를 어떻게 변환했는지**를 의심해 보는 습관이 중요하다.