# Python 3.13.11이 설치된 가벼운 리눅스 이미지를 기반으로 시작합니다.
FROM python:3.13.11-slim 
# ghcr.io/astral-sh/uv 이미지에서 'uv' 실행 파일을 가져와 현재 이미지의 /bin/ 폴더에 복사합니다. (멀티스테이지 빌드)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/ 

# 컨테이너 내부의 작업 디렉토리를 /code로 설정합니다. 이후 명령들은 이 경로를 기준으로 실행됩니다.
WORKDIR /code 

# PATH 환경 변수를 수정하여 가상 환경의 실행 파일들을 먼저 찾도록 합니다.
# 이를 통해 ENTRYPOINT에서 'uv run'을 생략하고 바로 가상 환경의 'python'을 실행할 수 있게 됩니다.
ENV PATH="/code/.venv/bin:$PATH"

# 호스트의 pyproject.toml, .python-version, uv.lock 파일을 컨테이너의 현재 작업 디렉토리(/code)로 복사합니다.
# 이 파일들은 'uv'가 프로젝트 의존성을 관리하는 데 필요합니다.
COPY pyproject.toml .python-version uv.lock ./ 

# 'uv'를 실행하여 pyproject.toml에 정의된 의존성들을 uv.lock에 명시된 정확한 버전으로 설치합니다.
# 이를 통해 개발 환경 간의 의존성 일관성을 보장합니다.
RUN uv sync --locked 

# 호스트의 pipeline.py 파일을 컨테이너의 현재 작업 디렉토리(/code)로 복사합니다.
COPY pipeline.py . 

# 컨테이너가 시작될 때 항상 'python pipeline.py' 명령을 실행하도록 지정합니다.
# PATH 환경 변수에 가상 환경 경로가 추가되었으므로, 'uv run' 없이도 가상 환경의 파이썬이 실행됩니다.
# 'docker run' 뒤에 오는 인자들은 이 ENTRYPOINT 명령의 추가 인자로 전달됩니다.
ENTRYPOINT ["python", "pipeline.py"] 