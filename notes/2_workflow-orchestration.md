# 🛠️ 워크플로우 오케스트레이션 (Workflow Orchestration)

데이터 엔지니어링에서 오케스트레이션은 여러 개의 독립된 작업(Task)을 정해진 순서와 조건에 따라 자동으로 실행되도록 관리하는 것을 말합니다.

## 1. 🎼 음악 오케스트라 비유 (영상 내용)

**악기 (도구)**: Python 스크립트, SQL 쿼리, API 호출, 테라폼 등 각자의 역할을 가진 도구들입니다.

**지휘자 (오케스트레이터)**: 각 도구가 언제 시작하고, 앞의 작업이 끝나면 다음은 무엇을 할지 지시하는 사람입니다.

**결과 (워크플로우)**: 지휘자의 통제에 따라 모든 악기가 조화롭게 연주되어 완성된 음악(성공적인 데이터 파이프라인)이 나옵니다.

## 2. 🤔 왜 필요한가요?

데이터 파이프라인이 복잡해지면 다음과 같은 문제가 생기는데, 이를 해결해 줍니다.

### 의존성 관리
"A가 성공해야만 B를 실행해라" 같은 순서를 보장합니다.

### 실패 대응
작업이 실패하면 자동으로 다시 시도(Retry)하거나 나에게 알림을 보냅니다.

### 모니터링
어떤 단계에서 시간이 오래 걸리는지, 어디서 에러가 났는지 한눈에 보여줍니다.

## 3. 🚀 Kestra 소개

Kestra는 최근 데이터 엔지니어링 커뮤니티에서 주목받는 오픈소스 워크플로우 오케스트레이터입니다. 이전에 유명했던 Airflow 같은 도구보다 배우기 쉽고 강력하다는 평을 듣습니다.

### 3.1 Kestra의 주요 특징

**YAML 기반 설정**: 복잡한 코딩 없이 YAML이라는 간단한 설정 파일만 작성하면 파이프라인이 만들어집니다.

**이벤트 기반 (Event-driven)**: 단순히 정해진 시간에 실행하는 것뿐만 아니라, "새로운 파일이 업로드되었을 때" 같은 특정 이벤트에 반응해 실행할 수 있습니다.

**풍부한 플러그인**: GCP(BigQuery, GCS), Postgres, Docker, Python 등 수많은 도구와 이미 연결될 준비가 되어 있습니다.

**직관적인 UI**: 웹 브라우저에서 파이프라인 구조를 그래프로 보며 직접 수정하고 실행 결과를 확인할 수 있습니다.

### 3.2 Kestra가 데이터를 다루는 방식 (ETL)

강의에서 실습할 내용은 다음과 같습니다.

**Extract (추출)**: Kestra가 외부 API(뉴욕 택시 데이터 등)에서 데이터를 가져옵니다.

**Transform (변환)**: 가져온 데이터를 Python이나 SQL을 이용해 가공합니다.

**Load (적재)**: 깨끗해진 데이터를 구글 빅쿼리(BigQuery)나 로컬 DB에 저장합니다.

## 4. Kestra 설치 및 실행 실습

### 📁 Docker Compose 파일 설정

**파일 위치:** `02-workflow-orchestration/docker-compose.yaml`

#### 추가된 볼륨 (Volumes):
```yaml
volumes:
  ny_taxi_postgres_data:    # 뉴욕 택시 데이터용 PostgreSQL 데이터 저장
    driver: local
  pgadmin_data:             # pgAdmin 설정 저장
    driver: local
  kestra_postgres_data:     # Kestra용 PostgreSQL 데이터 저장
    driver: local
  kestra_data:              # Kestra 워크플로우 및 파일 저장
    driver: local
```

#### 추가된 서비스들:

**1. kestra_postgres** (Kestra 전용 PostgreSQL)
```yaml
kestra_postgres:
  image: postgres:18
  environment:
    POSTGRES_DB: kestra
    POSTGRES_USER: kestra
    POSTGRES_PASSWORD: k3str4
  volumes:
    - kestra_postgres_data:/var/lib/postgresql
  # 헬스체크로 DB 준비 상태 확인
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -d $${POSTGRES_DB} -U $${POSTGRES_USER}"]
    interval: 30s
    timeout: 10s
    retries: 10
```

**2. kestra** (메인 오케스트레이션 서버)
```yaml
kestra:
  image: kestra/kestra:v1.1
  user: "root"  # 개발용 루트 사용자
  command: server standalone
  ports:
    - "8080:8080"  # 웹 UI
    - "8081:8081"  # API
  volumes:
    - kestra_data:/app/storage
    - /var/run/docker.sock:/var/run/docker.sock  # Docker 컨테이너 실행용
    - /tmp/kestra-wd:/tmp/kestra-wd
  environment:
    KESTRA_CONFIGURATION: |
      datasources:
        postgres:
          url: jdbc:postgresql://kestra_postgres:5432/kestra
          driverClassName: org.postgresql.Driver
          username: kestra
          password: k3str4
      kestra:
        server:
          basicAuth:
            username: "admin@kestra.io"
            password: Admin1234
        repository:
          type: postgres
        storage:
          type: local
          local:
            basePath: "/app/storage"
        queue:
          type: postgres
        tasks:
          tmpDir:
            path: /tmp/kestra-wd/tmp
        url: http://localhost:8080/
  depends_on:
    kestra_postgres:
      condition: service_started
```

### 🚀 실행 방법

**1. 터미널에서 실행:**
```bash
cd 02-workflow-orchestration
docker-compose up -d
```

**2. 실행되는 서비스들:**
- ✅ **pgdatabase**: 뉴욕 택시 데이터 저장용 PostgreSQL (포트 5432)
- ✅ **pgadmin**: 데이터베이스 관리 웹 UI (포트 8085)
- ✅ **kestra_postgres**: Kestra 메타데이터 저장용 PostgreSQL
- ✅ **kestra**: 메인 Kestra 오케스트레이션 서버 (포트 8080, 8081)

### 🌐 Kestra 접속 및 사용

**웹 UI 접속:**
- **URL:** http://localhost:8080
- **로그인 정보:**
  - **Username:** admin@kestra.io
  - **Password:** Admin1234

**접속 확인:**
1. 브라우저에서 http://localhost:8080 열기
2. 위 로그인 정보로 접속
3. 대시보드에서 워크플로우 생성 및 모니터링 가능

### 📋 실행 상태 확인

```bash
# 실행 중인 컨테이너 확인
docker-compose ps

# 로그 확인
docker-compose logs kestra

# 중지
docker-compose down
```

## 5. 🚀 Kestra 핵심 개념 정리

Kestra 워크플로우를 구성하는 주요 요소들을 예제 코드와 함께 설명합니다.

### 5.1 워크플로우 기본 정보

모든 흐름의 시작은 고유한 식별자에서 시작됩니다.

**ID & Namespace**: 워크플로우의 주민번호와 주소 같은 역할을 합니다. 한 번 저장하면 변경할 수 없으므로 주의해야 합니다.

```yaml
id: 01_hello_world  # 워크플로우 고유 ID
namespace: zoomcamp # 워크플로우가 속한 그룹(폴더)
```

#### 5.1.1 워크플로우 생성 실습

Kestra UI에서 처음 워크플로우를 만드는 방법입니다.

**단계별 과정:**
1. **Flows 메뉴 접속**: Kestra UI 왼쪽 사이드바에서 **Flows** 메뉴를 클릭합니다.
2. **Create 버튼**: 우측 상단의 핑크색 **Create** 버튼을 누릅니다.
3. **코드 작성**: 아래의 YAML 코드를 편집기 창에 복사해서 붙여넣습니다.
4. **저장(Save)**: 하단의 **Save** 버튼을 누릅니다.
   > ⚠️ **주의**: 저장 후에는 `id`와 `namespace`를 수정할 수 없으므로 오타가 없는지 확인하세요!
5. **Topology 확인**: 저장 후 상단의 **Topology** 탭을 누르면 내가 짠 코드의 흐름이 그래프로 시각화됩니다.

### 5.2 입력 및 변수 (Inputs & Variables)

데이터를 동적으로 처리하게 해주는 핵심 요소입니다.

**Inputs**: 실행 시 사용자가 직접 입력하는 값입니다. 파일 업로드나 날짜 선택 등 다양한 타입을 지원합니다.

**Variables**: 내부에서 재사용하기 위해 정의한 키-값 쌍입니다.

**Render**: 변수 안에 또 다른 변수나 입력값이 있을 때 이를 끝까지 계산해서 보여주는 함수입니다.

```yaml
inputs:
  - id: name
    type: STRING
    defaults: Will  # 기본값 설정

variables:
  welcome_message: "Hello, {{ inputs.name }}!" # 입력값을 변수에 활용
```

### 5.3 태스크와 출력값 (Tasks & Outputs)

워크플로우가 실제로 수행하는 작업들입니다.

**Tasks**: 각 단계(Step)를 의미하며, 로그 출력, 대기, 데이터 생성 등 다양한 기능을 수행합니다.

**Outputs**: 태스크가 완료된 후 다음 태스크로 넘겨주는 결과물입니다.

```yaml
tasks:
  - id: hello_message
    type: io.kestra.plugin.core.log.Log
    message: "{{ render(vars.welcome_message) }}" # 변수 렌더링 후 로그 출력

  - id: generate_output
    type: io.kestra.plugin.core.debug.Return
    format: I was generated during this workflow. # 출력값 생성

  - id: log_output
    type: io.kestra.plugin.core.log.Log
    message: "This is an output: {{ outputs.generate_output.value }}" # 앞선 태스크의 결과 사용
```

### 5.4 제어 및 자동화 (Concurrency, Defaults, Triggers)

운영 효율을 높여주는 고급 설정들입니다.

**Concurrency**: 동시에 실행될 수 있는 플로우 개수를 제한합니다. 데이터베이스 충돌 등을 방지할 때 매우 유용합니다.

**Plugin Defaults**: 동일한 타입의 태스크에 공통 설정을 한 번에 적용합니다.

**Triggers**: 특정 시간(Cron)이나 이벤트에 따라 플로우를 자동 시작합니다.

```yaml
concurrency:
  behavior: FAIL # 꽉 찼을 때 실패 처리
  limit: 2       # 동시에 2개만 실행 가능

pluginDefaults:
  - type: io.kestra.plugin.core.log.Log
    values:
      level: ERROR # 모든 로그 태스크를 ERROR 레벨로 설정

triggers:
  - id: schedule
    type: io.kestra.plugin.core.trigger.Schedule
    cron: "0 10 * * *" # 매일 오전 10시 실행
    disabled: true      # 자동 실행 방지를 위해 비활성화 상태
```

### 5.5 실행 결과 확인 방법

Kestra UI에서 다음 항목들을 통해 워크플로우를 모니터링할 수 있습니다.

**Gantt Chart**: 태스크별 소요 시간 시각화 (예: sleep 태스크가 가장 길게 표시됨).

**Logs**: 실제 실행된 메시지 및 오류 확인.

**Outputs**: 생성된 데이터가 올바르게 다음 단계로 전달되었는지 확인.

**Topology**: 전체 파이프라인의 구조와 흐름을 시각적으로 파악.

> 💡 **팁**: 강의에서는 concurrency를 테스트하기 위해 일부러 sleep 태스크(15초)를 넣어 실행 시간을 끌고, 그 사이 실행 버튼을 여러 번 눌러 실패하는 모습을 보여줍니다.

## 7. 🐍 Kestra Python 오케스트레이션 실습

### 7.1 성공한 워크플로우 코드 분석

이 코드는 Kestra가 Docker 컨테이너를 띄워 파이썬을 실행하고, 그 결과를 다시 Kestra로 가져오는 과정을 담고 있습니다.

```yaml
id: 02_python
namespace: zoomcamp

tasks:
  - id: collect_stats
    type: io.kestra.plugin.scripts.python.Script
    taskRunner:
      type: io.kestra.plugin.scripts.runner.docker.Docker # 도커 컨테이너에서 실행
    containerImage: python:3.11-slim # 사용할 파이썬 이미지

    # [트러블슈팅의 핵심] 권한 에러를 피하기 위해 uv 대신 pip 사용 
    # - (/Issue/2026-01-22-Kestra Python 오케스트레이션 트러블슈팅.md 참고)
    packageManager: PIP

    dependencies: # 파이썬 실행에 필요한 외부 라이브러리
      - requests
      - kestra

    script: | # 실제 실행될 파이썬 코드
      from kestra import Kestra
      import requests

      def get_docker_image_downloads(image_name: str = "kestra/kestra"):
          # Docker Hub API에서 이미지 다운로드 횟수 데이터를 가져옴
          url = f"https://hub.docker.com/v2/repositories/{image_name}/"
          response = requests.get(url)
          data = response.json()
          downloads = data.get('pull_count', 'Not available')
          return downloads

      # 함수 실행 후 결과를 Kestra 출력값으로 설정
      downloads = get_docker_image_downloads()
      Kestra.outputs({'downloads': downloads})
```

### 7.2 코드의 작동 원리 (내부 과정)

**컨테이너 준비**: Kestra가 python:3.11-slim 이미지를 내려받아 독립된 가상 공간(Docker)을 만듭니다.

**라이브러리 설치**: packageManager: PIP 설정을 통해 컨테이너 안에 requests와 kestra 라이브러리를 설치합니다.

**코드 실행**: 작성한 파이썬 스크립트가 컨테이너 내부에서 실행되어 Docker Hub의 데이터를 조회합니다.

**데이터 반환**: Kestra.outputs 함수를 통해 파이썬 내부의 변수(downloads)를 Kestra 워크플로우 시스템으로 전달합니다.

**종료**: 작업이 끝나면 사용된 컨테이너는 자동으로 삭제되어 깔끔하게 정리됩니다.

### 7.3 최종 결과물 확인 방법

실행이 끝난 후, 내가 가져온 데이터가 어디 있는지 확인하는 방법입니다.

**Executions 메뉴**: 왼쪽 메뉴에서 Executions를 누르고 방금 성공한 항목(초록색 체크)을 클릭합니다.

**Outputs 탭 클릭**: 화면 상단 탭 중에서 Outputs를 클릭합니다.

**데이터 확인**: collect_stats 항목 아래에 downloads라는 키값과 함께 **현재 Kestra 이미지의 총 다운로드 횟수(숫자)**가 찍혀 있는 것을 볼 수 있습니다.

**Logs 탭 확인**: 만약 과정이 궁금하다면 Logs 탭에서 파이썬 라이브러리가 설치되고 스크립트가 실행된 상세 기록을 볼 수 있습니다.

### 7.4 배운 점

데이터 엔지니어링에서 **오케스트레이션(Orchestration)**은 단순히 코드를 실행하는 것을 넘어, **"격리된 환경(Docker)에서 안전하게 실행하고, 그 결과를 다음 단계로 전달하는 흐름"**을 만드는 것. 이제 이 다운로드 횟수 데이터를 다음 태스크에서 데이터베이스에 저장하거나 슬랙 메시지로 보낼 수 있는 기초를 다지게 되었습니다.

### 7.5 ETL vs ELT 파이프라인 비교

**ETL**과 **ELT**는 모두 데이터 파이프라인 패턴이지만, 데이터 처리 순서와 방식이 다릅니다.

#### ETL (Extract-Transform-Load) - 전통적 방식
```
Raw Data → Transform → Clean Data → Load to DB
```
- **Extract**: 외부에서 데이터 가져오기
- **Transform**: 데이터를 변환/가공 (Python, SQL 등)
- **Load**: 변환된 데이터를 저장소에 저장
- **장점**: 데이터 품질 보장, 저장 공간 절약
- **단점**: 변환 과정이 복잡하고 오래 걸림

#### ELT (Extract-Load-Transform) - 현대적 방식
```
Raw Data → Load to DB → Transform in DB → Clean Data
```
- **Extract**: 외부에서 데이터 가져오기
- **Load**: 원본 데이터를 그대로 저장소에 저장
- **Transform**: 저장된 데이터에서 필요한 부분만 변환
- **장점**: 빠른 데이터 적재, DB 성능 활용, 유연한 변환
- **단점**: 저장 공간 더 필요, DB 부하 증가 가능

#### 왜 ELT가 현대적일까?
- **데이터 레이크 시대**: 원본 데이터 보존으로 다양한 분석 재사용 가능
- **스키마 온 리드**: 저장시 스키마 강제 X, 읽을 때 변환
- **클라우드 최적화**: BigQuery, Snowflake 등 현대적 데이터 웨어하우스에 적합

### 7.6 태스크 ID와 실제 역할의 차이

**태스크 ID는 개발자가 붙이는 이름일 뿐**, 실제 ETL/ELT 단계는 각 태스크가 수행하는 작업 내용에 따라 결정됩니다.

#### 태스크 ID ≠ 데이터 처리 단계

| 태스크 ID | 실제 역할 | ETL 단계 |
|-----------|-----------|----------|
| `extract` | CSV 파일 다운로드 | **E**xtract |
| `yellow_copy_in_to_staging_table` | CSV → 임시 테이블 저장 | **L**oad |
| `yellow_merge_data` | 임시 → 메인 테이블 변환 | **T**ransform |

#### 실무에서 태스크 ID로 역할 파악하기

**네이밍 컨벤션 (명명 규칙)**을 통해 태스크 ID만 보고도 역할을 파악할 수 있습니다:

```yaml
# Extract 단계
- id: extract_customer_data_from_api
- id: download_sales_csv_from_s3

# Load 단계
- id: load_customers_to_postgres
- id: insert_sales_to_bigquery

# Transform 단계
- id: clean_customer_data
- id: aggregate_sales_by_region
```

### 7.7 실습 워크플로우 분석

#### 7.7.1 03_getting_started_data_pipeline.yaml

이 워크플로우는 **기본적인 ETL 파이프라인**의 예시입니다.

**워크플로우 구조:**
- **Inputs**: 유지할 컬럼 선택 (brand, price)
- **Tasks**: Extract → Transform → Query (3단계)

**각 단계 역할:**
```yaml
# Extract: 외부 API에서 제품 데이터 가져오기
- id: extract
  type: io.kestra.plugin.core.http.Download
  uri: https://dummyjson.com/products

# Transform: Python으로 필요한 컬럼만 필터링
- id: transform
  type: io.kestra.plugin.scripts.python.Script
  # JSON 데이터 → 필터링된 JSON 데이터

# Query: DuckDB로 브랜드별 평균 가격 분석
- id: query
  type: io.kestra.plugin.jdbc.duckdb.Queries
  # 브랜드별 평균 가격 계산
```

**특징:**
- **완전한 ETL 흐름**: Extract → Transform → Load (Query)
- **유연한 입력**: 실행 시 컬럼 선택 가능
- **다중 처리**: HTTP + Python + SQL 조합

#### 7.7.2 04_postgres_taxi.yaml

이 워크플로우는 **실전 ELT 파이프라인**의 예시로, 뉴욕 택시 데이터를 PostgreSQL에 적재합니다.

**워크플로우 구조:**
- **Inputs**: 택시 타입, 연도, 월 선택
- **Variables**: 동적 파일명/테이블명 생성
- **Tasks**: Extract → 조건분기 → Load/Transform (복합 단계)

##### 전체 워크플로우 진행 순서

**Phase 1: 준비 및 다운로드**
```yaml
# 라벨 설정: 실행 추적용 메타데이터 추가
- id: set_label
  type: io.kestra.plugin.core.execution.Labels
  labels:
    file: "{{render(vars.file)}}"  # 처리할 파일명
    taxi: "{{inputs.taxi}}"        # 택시 타입

# 데이터 다운로드: 뉴욕 택시 CSV 파일 가져오기
- id: extract
  type: io.kestra.plugin.scripts.shell.Commands
  commands:
    - wget -qO- https://github.com/.../{{render(vars.file)}}.gz | gunzip > {{render(vars.file)}}
```

**Phase 2: 조건분기 - Yellow Taxi 처리**
```yaml
# 조건문: 택시 타입이 yellow인 경우에만 실행
- id: if_yellow_taxi
  type: io.kestra.plugin.core.flow.If
  condition: "{{inputs.taxi == 'yellow'}}"
  then:
    # 2.1 메인 테이블 생성
    - id: yellow_create_table
      # CREATE TABLE IF NOT EXISTS yellow_tripdata (...)

    # 2.2 스테이징 테이블 생성
    - id: yellow_create_staging_table
      # CREATE TABLE IF NOT EXISTS yellow_tripdata_staging (...)

    - id: yellow_truncate_staging_table
      # TRUNCATE TABLE yellow_tripdata_staging

    # 2.3 CSV 데이터 로드 (데이터 있지만 unique_row_id, filename은 null)
    - id: yellow_copy_in_to_staging_table
      type: io.kestra.plugin.jdbc.postgresql.CopyIn
      # CSV → PostgreSQL staging 테이블

    # 2.4 메타데이터 추가 (고유 ID 및 파일명 생성)
    - id: yellow_add_unique_id_and_filename
      # UPDATE yellow_tripdata_staging SET unique_row_id = md5(...)

    # 2.5 데이터 병합 (staging → main 테이블)
    - id: yellow_merge_data
      type: io.kestra.plugin.jdbc.postgresql.Queries
      # MERGE INTO yellow_tripdata AS T USING yellow_tripdata_staging AS S
```

**Phase 3: 조건분기 - Green Taxi 처리**
```yaml
# 조건문: 택시 타입이 green인 경우에만 실행
- id: if_green_taxi
  type: io.kestra.plugin.core.flow.If
  condition: "{{inputs.taxi == 'green'}}"
  then:
    # 3.1 메인 테이블 생성
    - id: green_create_table
      # CREATE TABLE IF NOT EXISTS green_tripdata (...)

    # 3.2 스테이징 테이블 생성
    - id: green_create_staging_table
      # CREATE TABLE IF NOT EXISTS green_tripdata_staging (...)

    - id: green_truncate_staging_table
      # TRUNCATE TABLE green_tripdata_staging

    # 3.3 CSV 데이터 로드 (데이터 있지만 unique_row_id, filename은 null)
    - id: green_copy_in_to_staging_table
      type: io.kestra.plugin.jdbc.postgresql.CopyIn
      # CSV → PostgreSQL staging 테이블

    # 3.4 메타데이터 추가 (고유 ID 및 파일명 생성)
    - id: green_add_unique_id_and_filename
      # UPDATE green_tripdata_staging SET unique_row_id = md5(...)

    # 3.5 데이터 병합 (staging → main 테이블)
    - id: green_merge_data
      type: io.kestra.plugin.jdbc.postgresql.Queries
      # MERGE INTO green_tripdata AS T USING green_tripdata_staging AS S
```

**Phase 4: 정리**
```yaml
# 파일 정리: 실행에 사용된 임시 파일들 삭제
- id: purge_files
  type: io.kestra.plugin.core.storage.PurgeCurrentExecutionFiles
```

**특징:**
- **ELT 구조**: Extract → Load → Transform
- **조건분기**: Yellow/Green 택시별 다른 스키마 처리
- **데이터 품질**: MD5 해시로 중복 데이터 방지
- **확장성**: 입력 파라미터로 다양한 데이터 처리 가능
- **단계적 구축**: 강의에서 점진적으로 코드 추가하며 실행

## 8. 💡 요약 정리

| 구분 | 설명 |
|------|------|
| **정의** | 복잡한 데이터 작업의 순서를 정하고 자동화하는 시스템 |
| **비유** | 수많은 악기를 조율하여 멋진 곡을 만드는 지휘자 |
| **Kestra** | YAML 언어를 사용하여 누구나 쉽게 구축할 수 있는 최신 오케스트레이션 도구 |
| **핵심 기능** | 스케줄링, 실패 시 재시도, 작업 간 데이터 전달, 모니터링 |
| **실행 포트** | 웹 UI: 8080, API: 8081 |
| **접속 정보** | admin@kestra.io / Admin1234 |