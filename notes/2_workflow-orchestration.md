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

## 6. 🐍 Kestra Python 오케스트레이션 실습

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

## 7. 🚀 Kestra 자동화 파이프라인(05_postgres_taxi_scheduled) 핵심 정리

### 7.1 04_postgres_taxi 코드 대비 주요 변경점

| 기능 | 04번 코드 (수동) | 05번 코드 (자동) |
|------|------------------|------------------|
| **날짜 입력** | 사용자가 year, month를 직접 선택 | trigger.date를 통해 시스템이 자동 결정 |
| **실행 방식** | Execute 버튼 클릭 시 1회 실행 | cron 설정에 따라 정해진 시간에 자동 실행 |
| **파일 이름** | 입력값 조합: `{{inputs.year}}-{{inputs.month}}` | 날짜 포맷: `{{trigger.date \| date('yyyy-MM')}}` |
| **동시성 제어** | 없음 (여러 개 동시 실행 가능) | `concurrency: limit: 1` (한 번에 하나만 실행) |

### 7.2 코드별 상세 설명

#### ① 동시성 제한 (concurrency)
```yaml
concurrency:
  limit: 1
```
**설명**: 백필을 돌리면 수십 개의 작업이 한꺼번에 생길 수 있습니다. 이때 DB에 무리가 가지 않도록 한 번에 딱 하나의 작업만 순서대로 처리하게 만드는 안전장치입니다.

#### ② 트리거 기반 변수 설정 (variables)
```yaml
variables:
  file: "{{inputs.taxi}}_tripdata_{{trigger.date | date('yyyy-MM')}}.csv"
```
**설명**: `trigger.date`는 Kestra가 제공하는 마법 같은 변수입니다.
- **정기 실행 시**: "오늘 날짜"가 들어갑니다.
- **백필 실행 시**: "과거의 특정 날짜"가 자동으로 들어갑니다.

따라서 코드 수정 없이도 과거 데이터를 정확히 집어낼 수 있습니다.

#### ③ 트리거 및 스케줄링 (triggers)
```yaml
triggers:
  - id: green_schedule
    type: io.kestra.plugin.core.trigger.Schedule
    cron: "0 9 1 * *" # 매월 1일 오전 9시
    inputs:
      taxi: green
```
**설명**:
- **`cron: "0 9 1 * *"`**: 리눅스 스케줄 방식입니다. (분 시 일 월 요일)
- **`inputs`**: 스케줄이 실행될 때 어떤 택시 타입을 선택할지 미리 지정해 둡니다.

### 7.3 백필(Backfill) 완벽 이해하기

#### ❓ 백필이란?
파이프라인을 오늘 만들었더라도, 어제나 작년의 데이터를 가져오기 위해 과거 날짜로 시뮬레이션 실행을 하는 기능입니다.

#### 🛠️ 백필 실행 방법 (UI)
1. Kestra에서 해당 워크플로우의 **Triggers 탭**으로 이동합니다.
2. `green_schedule` 혹은 `yellow_schedule` 옆의 **Backfill 버튼**을 누릅니다.
3. **Start Date**와 **End Date**를 설정합니다 (예: 2019-01-01 ~ 2020-01-01).
4. **Execute Backfill**을 누르면 Kestra가 해당 범위 내의 모든 "매월 1일"을 찾아내어 작업을 생성합니다.

#### ⚠️ 백필 주의사항 (복습)
- **시간 범위**: 내 스케줄이 09:00이라면, 종료 날짜는 반드시 해당 월의 9시 이후를 포함해야 합니다. (안전하게 다음 날짜로 잡으세요!)
- **레이블 활용**: 백필 실행 시 UI에서 `backfill: true`라는 레이블을 추가하면, 나중에 어떤 데이터가 백필로 들어온 것인지 쉽게 구분할 수 있습니다.

### 7.4 최종 워크플로우 흐름도

```
Trigger: 정해진 시간 혹은 백필 설정에 의해 날짜(trigger.date)가 결정됨
    ↓
Extract: 해당 날짜의 CSV 파일을 인터넷에서 다운로드
    ↓
Staging: 임시 테이블에 원본 데이터 그대로 복사(CopyIn)
    ↓
Upsert (Merge): 중복을 체크하여 최종 테이블에 신규 데이터만 반영
    ↓
Purge: 용량 확보를 위해 사용한 임시 파일 삭제
```

## 8. 🏗️ 생태계별 데이터 레이크 & 웨어하우스 종류

보통 기업이 어떤 클라우드 서비스를 메인으로 쓰느냐에 따라 선택이 갈립니다.

### 8.1 생태계별 서비스 비교

| 분류 | Google Cloud (GCP) | Amazon Web Services (AWS) | Microsoft Azure | 독립형 (Multi-Cloud) |
|------|-------------------|---------------------------|-----------------|---------------------|
| **데이터 레이크 (저장소)** | GCS (Google Cloud Storage) | S3 (Simple Storage Service) | ADLS (Azure Data Lake Storage) | - |
| **데이터 웨어하우스 (분석)** | BigQuery | Redshift | Synapse Analytics | Snowflake |

### 8.2 데이터 레이크 (Data Lake)의 실무 트렌드

실무에서는 **"클라우드 오브젝트 스토리지"**를 데이터 레이크로 씁니다. 무한대에 가까운 확장성과 매우 저렴한 비용 때문입니다.

- **AWS S3**: 전 세계에서 가장 많이 쓰이는 레이크입니다. 거의 모든 데이터 도구와 호환됩니다.
- **GCS**: 구글 클라우드를 쓴다면 무조건 선택합니다. BigQuery와의 연동 속도가 매우 빠릅니다.
- **Hadoop (HDFS)**: 클라우드로 넘어가기 전, 자체 서버(On-premise)를 운영하는 기업들이 전통적으로 쓰던 방식입니다. (요즘은 클라우드로 많이 넘어가는 추세입니다.)

### 8.3 데이터 웨어하우스 (Data Warehouse)의 실무 트렌드

최근 실무에서는 성능만큼이나 **"관리가 편한가(Serverless)"**를 중요하게 봅니다.

- **BigQuery (GCP)**: 인덱스 설정도 필요 없고, 그냥 쿼리만 던지면 구글이 알아서 수천 대의 서버를 돌려 결과를 줍니다. 관리가 가장 편합니다.
- **Snowflake**: 최근 가장 핫한 강자입니다. 특정 클라우드에 종속되지 않고 AWS, GCP 어디서든 쓸 수 있으며 성능과 사용 편의성이 매우 뛰어납니다.
- **AWS Redshift**: AWS 생태계를 이미 깊게 사용 중인 기업에서 많이 씁니다. 설정에 따라 비용 효율이 좋습니다.

### 8.4 요즘 실무의 대세: 데이터 레이크하우스 (Lakehouse)

요즘은 **"레이크의 저렴한 비용 + 웨어하우스의 강력한 분석 성능"**을 합친 데이터 레이크하우스가 대세입니다.

- **Databricks**: Apache Spark를 만든 팀이 세운 회사로, 레이크 위에서 바로 SQL 분석을 할 수 있게 해줍니다.
- **Apache Iceberg / Hudi**: 파일은 레이크(S3, GCS)에 저장되어 있지만, 마치 DB처럼 데이터를 수정(Update/Delete)하고 관리할 수 있게 해주는 기술입니다.

### 8.5 데이터 레이크 vs 데이터 웨어하우스: 핵심 차이점

#### 🎯 저장 방식의 차이
- **데이터 레이크**: **원본 데이터를 통째로 저장** (CSV, JSON, 로그 파일 등)
  - 예: 뉴욕 택시 CSV 파일을 압축 해제해서 통째로 S3/GCS에 넣어놓음
  - **장점**: 모든 원본 데이터를 보존, 향후 다양한 분석 가능성
  - **단점**: 데이터 품질이 일관되지 않을 수 있음

- **데이터 웨어하우스**: **가공된 데이터를 구조화해서 저장**
  - 예: CSV 데이터를 정제해서 테이블 형태로 변환 저장
  - **장점**: 데이터 품질 보장, 빠른 쿼리 성능
  - **단점**: 저장 비용 높음, 유연성 부족

#### 🔗 참조 기반 분석의 장점
데이터 웨어하우스(BigQuery, Snowflake 등)는 **데이터를 직접 저장하지 않고 레이크의 데이터를 참조**하는 방식을 지원합니다:

**외부 테이블 (External Table)**: 레이크의 CSV 파일을 마치 DB 테이블처럼 쿼리
```sql
-- BigQuery에서 GCS의 CSV 파일 직접 쿼리
SELECT *
FROM `project.dataset.external_table`
WHERE pickup_date >= '2024-01-01'
```

**장점:**
- **저장 비용 절감**: 데이터를 중복 저장하지 않음
- **실시간성**: 레이크의 최신 데이터를 바로 분석
- **유연성**: ETL 없이도 빠른 데이터 탐색 가능
- **데이터 governance**: 하나의 데이터 소스로 여러 분석 도구에서 활용

#### 🏗️ 하이브리드 아키텍처의 진화
```
📊 최신 아키텍처:
데이터 레이크 (저장소) ← 외부 테이블 → 데이터 웨어하우스 (분석 엔진)
       ↓
   원본 데이터 (CSV, 로그 등)
```

**실무 적용 예시:**
- **데이터 레이크**: 모든 고객 이벤트 로그, 센서 데이터, 클릭스트림 데이터 저장
- **데이터 웨어하우스**: 레이크의 데이터를 참조하여 실시간 대시보드, BI 분석 수행
- **데이터 레이크하우스**: 하나의 플랫폼에서 저장과 분석을 모두 처리

## 9. 💡 요약 정리

| 구분 | 설명 |
|------|------|
| **정의** | 복잡한 데이터 작업의 순서를 정하고 자동화하는 시스템 |
| **비유** | 수많은 악기를 조율하여 멋진 곡을 만드는 지휘자 |
| **Kestra** | YAML 언어를 사용하여 누구나 쉽게 구축할 수 있는 최신 오케스트레이션 도구 |
| **핵심 기능** | 스케줄링, 실패 시 재시도, 작업 간 데이터 전달, 모니터링 |
| **실행 포트** | 웹 UI: 8080, API: 8081 |
| **접속 정보** | admin@kestra.io / Admin1234 |

### 💡 실무 선택 가이드
| 상황 | 추천 조합 |
|------|-----------|
| **스타트업/신규 프로젝트** | 관리가 편한 GCP (GCS + BigQuery) 혹은 Snowflake |
| **대규모 기존 인프라** | AWS (S3 + Redshift)가 압도적으로 많음 |
| **머신러닝/복잡한 가공 위주** | Databricks를 함께 사용하는 경우가 많음 |

## 10. ☁️ GCP 인프라 자동 구축 실습 (06_gcp_kv + 07_gcp_setup)

### 10.1 GCP 워크플로우 개요

강의의 마지막 부분에서는 **Kestra를 활용해 Google Cloud Platform(GCP) 인프라를 코드로 자동 구축**하는 방법을 실습했습니다.

#### 워크플로우 구성
- **`06_gcp_kv.yaml`**: GCP 설정값들을 Kestra의 Key-Value(KV) 스토어에 저장
- **`07_gcp_setup.yaml`**: KV 스토어의 값들을 활용해 GCP 리소스 자동 생성

### 10.2 Kestra KV 스토어의 역할

#### ❓ KV 스토어란?
Kestra 내부의 **키-값 저장소**로, 워크플로우 간에 데이터를 공유하고 재사용할 수 있게 해줍니다.

#### 📊 실제 활용 예시
```
KV Store 내용:
- GCP_PROJECT_ID: "kestra-sandbox-485208"
- GCP_LOCATION: "asia-northeast1"
- GCP_BUCKET_NAME: "jaehyun-dataeng-kestra-bucket"
- GCP_DATASET: "zoomcamp"
- GCP_CREDS: {서비스 계정 JSON 키}
```

### 10.3 06_gcp_kv.yaml: 설정값 저장 워크플로우

#### 워크플로우 구조
```yaml
id: 06_gcp_kv
namespace: zoomcamp

tasks:
  # GCP 프로젝트 ID 저장
  - id: gcp_project_id
    type: io.kestra.plugin.core.kv.Set
    key: GCP_PROJECT_ID
    value: kestra-sandbox-485208

  # GCP 리전 저장 (한국 사용자용)
  - id: gcp_location
    type: io.kestra.plugin.core.kv.Set
    key: GCP_LOCATION
    value: asia-northeast1

  # GCS 버킷 이름 저장 (전역적으로 고유해야 함)
  - id: gcp_bucket_name
    type: io.kestra.plugin.core.kv.Set
    key: GCP_BUCKET_NAME
    value: jaehyun-dataeng-kestra-bucket

  # BigQuery 데이터셋 이름 저장
  - id: gcp_dataset
    type: io.kestra.plugin.core.kv.Set
    key: GCP_DATASET
    value: zoomcamp

  # GCP 서비스 계정 키 저장 
  - id: set_gcp_creds
    type: io.kestra.plugin.core.kv.Set
    key: GCP_CREDS
    kvType: JSON
    value: "{ google cloud key }"
```

#### 실행 결과
✅ **Kestra KV Store에 GCP 설정값들이 저장됨**
- 프로젝트 ID, 리전, 버킷 이름, 데이터셋 이름, 서비스 계정 키가 모두 저장
- 이후 워크플로우에서 `{{kv('GCP_PROJECT_ID')}}` 등의 형식으로 재사용 가능

### 10.4 07_gcp_setup.yaml: GCP 리소스 생성 워크플로우

#### 워크플로우 구조
```yaml
id: 07_gcp_setup
namespace: zoomcamp

tasks:
  # GCS 버킷 생성
  - id: create_gcs_bucket
    type: io.kestra.plugin.gcp.gcs.CreateBucket
    ifExists: SKIP  # 이미 존재하면 스킵
    storageClass: REGIONAL
    name: "{{kv('GCP_BUCKET_NAME')}}"

  # BigQuery 데이터셋 생성
  - id: create_bq_dataset
    type: io.kestra.plugin.gcp.bigquery.CreateDataset
    name: "{{kv('GCP_DATASET')}}"
    ifExists: SKIP  # 이미 존재하면 스킵

# 플러그인 기본 설정 (모든 GCP 태스크에 적용)
pluginDefaults:
  - type: io.kestra.plugin.gcp
    values:
      serviceAccount: "{{kv('GCP_CREDS')}}"  # KV에서 서비스 계정 가져옴
      projectId: "{{kv('GCP_PROJECT_ID')}}"
      location: "{{kv('GCP_LOCATION')}}"
      bucket: "{{kv('GCP_BUCKET_NAME')}}"
```

#### 실행 결과

### 10.5 Google Cloud Platform 생성 리소스

#### 🗄️ Google Cloud Storage (GCS) 버킷
- **버킷 이름**: `jaehyun-dataeng-kestra-bucket`
- **저장 클래스**: REGIONAL (해당 리전 내 고가용성)
- **위치**: `asia-northeast1` (서울 리전)
- **용도**: 데이터 파일 저장, 백업, 공유 등

#### 📊 BigQuery 데이터셋
- **데이터셋 이름**: `zoomcamp`
- **프로젝트**: `kestra-sandbox-485208`
- **위치**: `asia-northeast1` (서울 리전)
- **용도**: 구조화된 데이터 분석, SQL 쿼리 실행

### 10.6 실제 생성 과정 확인 방법

#### GCP Console에서 확인
1. **Google Cloud Console** 접속 (console.cloud.google.com)
2. **좌측 메뉴** → **Cloud Storage** → **Buckets**
   - `jaehyun-dataeng-kestra-bucket` 버킷 확인
3. **좌측 메뉴** → **BigQuery** → **SQL 작업공간**
   - `zoomcamp` 데이터셋 확인

#### Kestra에서 생성 로그 확인
```yaml
# 성공 로그 예시
INFO  - Task 'create_gcs_bucket' completed successfully
INFO  - Task 'create_bq_dataset' completed successfully

# 이미 존재하는 경우 (SKIP 동작)
INFO  - Bucket 'jaehyun-dataeng-kestra-bucket' already exists, skipping creation
INFO  - Dataset 'zoomcamp' already exists, skipping creation
```

### 10.7 보안 및 설정 관리의 장점

#### 🔐 시크릿 관리
- **환경변수**: 민감한 GCP 서비스 계정 키를 Docker 환경변수로 관리
- **KV 스토어**: 워크플로우 간 설정값 공유 및 재사용
- **접두사 규칙**: `SECRET_*` 환경변수는 자동으로 `secret()` 함수에서 접근 가능

#### 🔄 인프라 as Code
```yaml
# 코드 한 줄로 GCP 인프라 생성
- id: create_gcs_bucket
  type: io.kestra.plugin.gcp.gcs.CreateBucket
  name: "{{kv('GCP_BUCKET_NAME')}}"
```

#### 📈 확장성
- **환경별 설정**: 개발/스테이징/운영 환경별 다른 값 사용 가능
- **재사용성**: 하나의 설정값으로 여러 워크플로우에서 활용
- **버전 관리**: Git으로 인프라 코드 관리 가능

### 10.8 실무 적용 사례

#### 데이터 파이프라인 구축 시나리오
1. **개발 환경**: `dev-bucket`, `dev-dataset` 생성
2. **스테이징 환경**: `staging-bucket`, `staging-dataset` 생성
3. **운영 환경**: `prod-bucket`, `prod-dataset` 생성

#### 코드 예시
```yaml
# 환경별 설정만 변경하면 동일 코드로 다른 환경 구축 가능
variables:
  env: "{{inputs.environment}}"  # dev, staging, prod

tasks:
  - id: set_bucket_name
    type: io.kestra.plugin.core.kv.Set
    key: GCP_BUCKET_NAME
    value: "{{vars.env}}-dataeng-kestra-bucket"

  - id: create_infra
    type: io.kestra.plugin.core.flow.WorkingDirectory
    tasks:
      - id: create_gcs_bucket
        type: io.kestra.plugin.gcp.gcs.CreateBucket
        name: "{{kv('GCP_BUCKET_NAME')}}"
```

### 10.9 배운 점과 실무 활용

#### 💡 핵심 인사이트
- **Infrastructure as Code**: 코드로 클라우드 인프라를 관리하는 현대적 접근법
- **보안과 편의성의 균형**: 민감한 정보는 환경변수로, 설정값은 KV 스토어로 분리 관리
- **워크플로우 체이닝**: 하나의 워크플로우 결과를 다른 워크플로우에서 활용

#### 🏢 실무 적용
- **데이터 레이크 구축**: GCS 버킷을 데이터 레이크로 활용
- **데이터 웨어하우스 구축**: BigQuery 데이터셋을 분석용 웨어하우스로 활용
- **CI/CD 파이프라인**: 코드 변경 시 자동으로 인프라 재구축
- **멀티 환경 관리**: 개발/테스트/운영 환경을 코드로 일관성 있게 관리

이 실습을 통해 **"코드로 클라우드 인프라를 자동 구축하고 관리하는 능력"**을 갖추게 되었습니다. 이제 데이터 엔지니어링의 전 과정을 Kestra로 자동화할 수 있는 기반이 마련되었습니다! 🎉

## 11. 🗂️ 완전한 ELT 파이프라인 구축 (08_gcp_taxi)

### 11.1 08_gcp_taxi 워크플로우 개요

강의의 **마지막 실습**에서는 Kestra를 활용해 **완전한 ELT(Extract-Load-Transform) 파이프라인**을 구축했습니다. 외부 데이터를 가져와서 GCP에 저장하고 분석 가능한 형태로 변환하는 전 과정을 자동화했습니다.

#### 워크플로우의 핵심 기능
- **Extract**: 뉴욕 택시 데이터를 외부 소스에서 다운로드
- **Load**: 다운로드된 데이터를 GCS 버킷에 저장
- **Transform**: BigQuery에서 데이터를 변환하고 분석용 테이블 생성
- **중복 방지**: 해시 기반 unique_row_id로 데이터 품질 보장

### 11.2 데이터 흐름도

```
외부 데이터 소스 → Kestra 워크플로우 → GCS 버킷 → BigQuery 테이블
    ↓                    ↓                ↓              ↓
GitHub Releases → CSV 다운로드 → 파일 업로드 → 외부 테이블 → 임시 테이블 → 메인 테이블
```

### 11.3 Extract 단계: 데이터 수집

#### 외부 데이터 소스 다운로드
```yaml
- id: extract
  type: io.kestra.plugin.scripts.shell.Commands
  commands:
    - wget -qO- https://github.com/DataTalksClub/nyc-tlc-data/releases/download/{{inputs.taxi}}/{{render(vars.file)}}.gz | gunzip > {{render(vars.file)}}
```

**실행 결과:**
- GitHub에서 압축된 CSV 파일 다운로드
- 로컬 파일 시스템에 압축 해제하여 저장
- 예: `green_tripdata_2019-01.csv` 파일 생성

### 11.4 Load 단계: 데이터 저장

#### GCS 버킷에 파일 업로드
```yaml
- id: upload_to_gcs
  type: io.kestra.plugin.gcp.gcs.Upload
  from: "{{render(vars.data)}}"
  to: "{{render(vars.gcs_file)}}"
```

**실행 결과:**
- 로컬 CSV 파일을 GCS 버킷으로 업로드
- 경로: `gs://jaehyun-dataeng-kestra-bucket/green_tripdata_2019-01.csv`
- **데이터 레이크**로서의 GCS 역할 수행

### 11.5 Transform 단계: 데이터 변환

#### 11.5.1 외부 테이블 생성
```yaml
CREATE OR REPLACE EXTERNAL TABLE `project.dataset.table_ext`
OPTIONS (
    format = 'CSV',
    uris = ['gs://bucket/file.csv'],
    skip_leading_rows = 1
);
```

**실행 결과:**
- GCS의 CSV 파일을 직접 참조하는 가상 테이블 생성
- BigQuery가 GCS 파일을 마치 데이터베이스 테이블처럼 쿼리 가능
- **외부 테이블**: `zoomcamp.green_tripdata_2019_01_ext`

#### 11.5.2 임시 테이블 생성 (데이터 변환)
```yaml
CREATE OR REPLACE TABLE `project.dataset.table` AS
SELECT
  MD5(CONCAT(VendorID, pickup_datetime, ...)) AS unique_row_id,
  "filename.csv" AS filename,
  *
FROM `project.dataset.table_ext`;
```

**실행 결과:**
- 외부 테이블의 데이터를 변환하여 저장
- **unique_row_id**: 주요 필드들의 해시로 중복 방지
- **filename**: 데이터 출처 추적을 위한 메타데이터 추가
- **임시 테이블**: `zoomcamp.green_tripdata_2019_01`

#### 11.5.3 메인 테이블로 데이터 병합
```yaml
MERGE INTO `project.dataset.main_table` T
USING `project.dataset.temp_table` S
ON T.unique_row_id = S.unique_row_id
WHEN NOT MATCHED THEN INSERT (...);
```

**실행 결과:**
- 임시 테이블의 데이터를 메인 테이블로 병합
- **중복 데이터 방지**: 동일한 unique_row_id는 삽입되지 않음
- **증분 업데이트**: 신규 데이터만 추가
- **메인 테이블**: `zoomcamp.green_tripdata` 또는 `zoomcamp.yellow_tripdata`

### 11.6 Google Cloud Platform 최종 결과

#### 11.6.1 Google Cloud Storage (GCS)
- **버킷**: `jaehyun-dataeng-kestra-bucket`
- **저장된 파일들**:
  - `green_tripdata_2019-01.csv`
  - `yellow_tripdata_2019-01.csv`
  - 기타 실행한 모든 택시 데이터 파일들

#### 11.6.2 BigQuery 데이터셋
- **데이터셋**: `zoomcamp`
- **테이블들**:
  - `green_tripdata` - 그린 택시 데이터 (lpep_pickup_datetime으로 파티셔닝)
  - `yellow_tripdata` - 옐로 택시 데이터 (tpep_pickup_datetime으로 파티셔닝)
  - 임시 외부 테이블들 (워크플로우 실행 시 자동 생성/삭제)

### 11.7 데이터 품질 및 신뢰성 보장

#### Unique Row ID 생성 로직
```sql
MD5(CONCAT(
  COALESCE(CAST(VendorID AS STRING), ""),
  COALESCE(CAST(pickup_datetime AS STRING), ""),
  COALESCE(CAST(dropoff_datetime AS STRING), ""),
  COALESCE(CAST(PULocationID AS STRING), ""),
  COALESCE(CAST(DOLocationID AS STRING), "")
))
```

**장점:**
- **중복 방지**: 동일한 택시 기록이 중복 삽입되지 않음
- **데이터 무결성**: NULL 값 처리로 안정성 보장
- **재현성**: 동일한 입력이면 항상 동일한 ID 생성

#### Filename 메타데이터
```sql
"green_tripdata_2019-01.csv" AS filename
```

**장점:**
- **데이터 출처 추적**: 어떤 파일에서 왔는지 확인 가능
- **디버깅 용이**: 문제가 발생한 경우 원본 파일 식별 가능
- **감사(Audit) 가능**: 데이터 파이프라인의 투명성 확보

### 11.8 조건분기 처리: Yellow vs Green 택시

#### 택시 타입별 다른 스키마 처리
```yaml
- id: if_yellow_taxi
  condition: "{{inputs.taxi == 'yellow'}}"
  then: [yellow 전용 태스크들]

- id: if_green_taxi
  condition: "{{inputs.taxi == 'green'}}"
  then: [green 전용 태스크들]
```

**차이점:**
- **Yellow Taxi**: `tpep_pickup_datetime`, 더 많은 필드
- **Green Taxi**: `lpep_pickup_datetime`, `ehail_fee`, `trip_type` 등 추가 필드

### 11.9 BigQuery 고급 기능 활용

#### 파티셔닝 (Partitioning)
```sql
PARTITION BY DATE(tpep_pickup_datetime)  -- Yellow
PARTITION BY DATE(lpep_pickup_datetime)  -- Green
```

**장점:**
- **쿼리 성능 향상**: 날짜 필터링 시 파티션 프루닝
- **비용 절감**: 스캔하는 데이터 양 감소
- **관리 편의성**: 시간 기반 데이터 관리

#### 외부 테이블 (External Table)
```sql
OPTIONS (
    format = 'CSV',
    uris = ['gs://bucket/file.csv'],
    skip_leading_rows = 1,
    ignore_unknown_values = TRUE
)
```

**장점:**
- **저장 비용 절감**: 데이터를 중복 저장하지 않음
- **실시간성**: GCS 파일 변경 즉시 반영
- **유연성**: 다양한 파일 포맷 지원

### 11.10 실행 결과 확인 방법

#### Kestra UI에서 확인
1. **Executions 탭**에서 워크플로우 실행 기록 확인
2. **Logs 탭**에서 각 단계별 실행 로그 확인
3. **Outputs 탭**에서 생성된 파일 경로 확인

#### GCP Console에서 확인
1. **Cloud Storage** → 버킷에서 업로드된 CSV 파일 확인
2. **BigQuery** → 데이터셋에서 생성된 테이블 및 데이터 확인
3. **SQL 쿼리**로 데이터 샘플링:
   ```sql
   SELECT COUNT(*) FROM `zoomcamp.green_tripdata`;
   SELECT * FROM `zoomcamp.green_tripdata` LIMIT 10;
   ```

### 11.11 실무적 의의와 활용

#### 데이터 엔지니어링 파이프라인의 완성
이 워크플로우는 **현대적 데이터 엔지니어링의 핵심 패턴**을 모두 구현했습니다:

- **데이터 레이크**: GCS에 원본 데이터 저장
- **데이터 웨어하우스**: BigQuery에 구조화된 데이터 저장
- **ELT 패턴**: Extract → Load → Transform 순서
- **중복 방지**: 해시 기반 ID로 데이터 품질 보장
- **메타데이터 관리**: filename 등 추적 정보 추가

#### 확장 가능성
- **파라미터화**: year, month, taxi 타입으로 다양한 데이터 처리 가능
- **재사용성**: 동일한 구조로 다른 데이터 소스 적용 가능
- **모니터링**: Kestra UI에서 파이프라인 상태 실시간 모니터링
- **에러 처리**: 실패 시 자동 재시도 및 알림 가능

#### 클라우드 네이티브 아키텍처
- **Serverless**: BigQuery의 자동 확장 활용
- **객체 스토리지**: GCS의 무제한 확장성 활용
- **관리형 서비스**: 인프라 관리 부담 최소화


---

## 12. 📅 자동화된 스케줄링 파이프라인 (09_gcp_taxi_scheduled)

### 12.1 09_gcp_taxi_scheduled 워크플로우 개요

강의의 **최종 실습**에서는 **완전히 자동화된 ELT 파이프라인**을 구축했습니다. 수동 실행이 아닌 **스케줄러에 의해 매월 자동 실행**되는 진정한 운영 환경의 데이터 파이프라인입니다.

#### 08번 vs 09번 워크플로우 비교

| 기능 | 08_gcp_taxi (수동) | 09_gcp_taxi_scheduled (자동) |
| --- | --- | --- |
| **실행 방식** | 수동 실행 버튼 클릭 | 매월 1일 자동 실행 |
| **날짜 지정** | 사용자가 year/month 선택 | trigger.date로 자동 결정 |
| **입력 파라미터** | taxi, year, month | taxi 타입만 선택 |
| **트리거** | 없음 | Schedule 트리거 2개 |
| **변수 사용** | inputs.year, inputs.month | trigger.date |
| **실행 주기** | 수시 | 매월 정기적 |

### 12.2 Trigger.date의 마법: 동적 날짜 처리

#### ❓ trigger.date란?

Kestra의 **스케줄링 트리거**가 제공하는 특별한 변수로, 실행 시점의 날짜 정보를 담고 있습니다.

```yaml
# 스케줄링 실행 시 자동으로 설정되는 값들
trigger.date = "2024-01-01T09:00:00.000Z"  # Green 택시 실행 시점
trigger.date = "2024-01-01T10:00:00.000Z"  # Yellow 택시 실행 시점

```

#### 📅 동적 변수 생성

```yaml
variables:
  # 실행 시점의 날짜를 사용하여 파일명 생성
  file: "{{inputs.taxi}}_tripdata_{{trigger.date | date('yyyy-MM')}}.csv"
  # 예: "green_tripdata_2024-01.csv" (1월 실행 시)
  # 예: "yellow_tripdata_2024-02.csv" (2월 실행 시)

  # BigQuery 테이블명도 동적 생성
  table: "{{kv('GCP_DATASET')}}.{{inputs.taxi}}_tripdata_{{trigger.date | date('yyyy_MM')}}"
  # 예: "zoomcamp.green_tripdata_2024_01"

```

### 12.3 스케줄링 설정: 매월 자동 실행

#### 트리거 구성

```yaml
triggers:
  # Green 택시: 매월 1일 오전 9시
  - id: green_schedule
    type: io.kestra.plugin.core.trigger.Schedule
    cron: "0 9 1 * *"    # cron 표현식
    inputs:
      taxi: green        # 실행 시 자동으로 입력값 설정

  # Yellow 택시: 매월 1일 오전 10시
  - id: yellow_schedule
    type: io.kestra.plugin.core.trigger.Schedule
    cron: "0 10 1 * *"   # 1시간 차이로 순차 실행
    inputs:
      taxi: yellow

```

#### 🕐 Cron 표현식 이해

```
* * * * *
│ │ │ │ │
│ │ │ │ └─ 요일 (0-6, 0=일요일)
│ │ │ └─── 월 (1-12)
│ │ └───── 일 (1-31)
│ └─────── 시 (0-23)
└───────── 분 (0-59)

"0 9 1 * *" = 매월 1일 09:00
"0 10 1 * *" = 매월 1일 10:00

```

### 12.4 백필(Backfill) 기능: 과거 데이터 일괄 처리

#### ❓ 백필이란?

**과거 데이터를 소급하여 파이프라인을 실행**하는 기능입니다. 예를 들어, 파이프라인을 2024년 6월에 만들었더라도 2023년 데이터까지 소급해서 처리할 수 있습니다.

#### 🔄 백필 실행 방법

1. **Kestra UI → 해당 워크플로우 → Triggers 탭**
2. **Backfill 버튼 클릭**
3. **날짜 범위 설정**:
* Start Date: `2023-01-01`
* End Date: `2024-12-01`


4. **Execute Backfill** 클릭

#### 📊 백필 결과

* **2023-01-01**: Green 택시 데이터 (09:00)
* **2023-01-01**: Yellow 택시 데이터 (10:00)
* **2023-02-01**: Green 택시 데이터 (09:00)
* **...계속**

---

## 13. 🛠️ Kestra AI Copilot 설정 및 성능 비교

### 13.1 AI Copilot 설정 가이드

1. **Gemini API 키 발급**: [Google AI Studio](https://aistudio.google.com/app/apikey)에서 키를 생성합니다.
2. **docker-compose.yml 수정**: 환경 변수에 API 키 정보를 추가합니다.

```yaml
environment:
  KESTRA_CONFIGURATION: |
    kestra:
      ai:
        type: gemini
        gemini:
          model-name: gemini-1.5-flash
          api-key: ${GEMINI_API_KEY}

```

### 13.2 실습: ChatGPT vs AI Copilot 비교

* **프롬프트**: "Create a Kestra flow that loads NYC taxi data from a CSV file to BigQuery. The flow should extract data, upload to GCS, and load to BigQuery."

#### ❌ 실험 A: 일반 ChatGPT 결과 (컨텍스트 부재)

* **주요 결함**: 구형 문법 사용 및 잘못된 속성 참조

```yaml
- id: upload_to_gcs
  type: io.kestra.plugin.gcp.gcs.Upload
  from: "{{ outputs.download_csv.file }}" # ❌ 오류: 현재 버전은 .uri 사용

```

#### ✅ 실험 B: AI Copilot 결과 (최신 컨텍스트 활용)

* **주요 장점**: 실행 가능한 최신 구문 및 실무 옵션 포함

```yaml
- id: upload_to_gcs
  type: io.kestra.plugin.gcp.gcs.Upload
  from: "{{ outputs.download_taxi_data.uri }}" # ✅ 정확: 최신 속성 사용

```

### 13.3 분석: 왜 차이가 발생하는가?

| 결함 유형 | 상세 설명 | 원인 |
| --- | --- | --- |
| **구식 구문** | 이름이 변경되거나 통합된 이전 버전 사용 | 신규 릴리스 정보 부재 |
| **잘못된 속성 이름** | 존재하지 않는 속성(.file) 임의 사용 | API 변경 사항 학습 미흡 |
| **환각 (Hallucination)** | 존재하지 않는 작업을 생성 | 과거 정보에만 의존 |

### 13.4 핵심 교훈: 맥락(Context)이 모든 것이다

> **💡 최종 요약**: LLM은 지식 차단 시점이 존재하므로, 최신 도구를 다룰 때는 **공식 문서의 사양을 직접 포함(Context Engineering)**하거나 **전용 Copilot을 활용**하는 것이 필수적입니다.

### 13.5 실습 보충: Kestra KV Store를 이용한 API 키 관리

워크플로우 코드 내에서 `{{ kv('GEMINI_API_KEY') }}` 문법을 사용하여 보안을 유지하며 키를 호출하는 방법입니다.

#### 🔐 KV Store 설정 방법

1. Kestra UI 왼쪽 메뉴의 **KV Store** 선택
2. **Create** 버튼 클릭 (Key: `GEMINI_API_KEY`, Value: 실제 키 입력)

> **Tip**: 이렇게 설정하면 YAML 코드에 노출하지 않고도 안전하게 AI 기능을 사용할 수 있습니다.

---

## 14. 📚 보너스: 검색 증강 생성 (RAG) 이해 및 실습

### 14.1 RAG(Retrieval Augmented Generation)란?

* **개념**: AI가 자신의 학습 데이터 외에 **외부의 신뢰할 수 있는 지식 베이스를 참고**하여 답변을 생성하는 기술입니다.
* **비유**: 암기한 지식으로만 답하던 학생이 **'전공 서적을 보면서 답하는 오픈북 테스트'**를 치르는 것과 같습니다.

### 14.2 실습 비교: RAG 미적용 vs RAG 적용

#### ❌ 실험 C: RAG 미적용 결과 (10_chat_without_rag.yaml)

* **로그 분석 (환각 사례)**: "Kestra 1.1은 2021년 말에 출시됨" (실제 2025년)
* **결론**: 최신 정보가 없는 AI는 과거 지식을 짜깁기하여 그럴듯한 거짓말을 생성함.

#### ✅ 실험 D: RAG 적용 결과 (11_chat_with_rag.yaml)

* **로그 분석 (정확한 답변)**: New Filters, No-Code Dashboard Editor 등 최신 기능을 정확히 나열.
* **결론**: 실제 문서를 근거(Grounded)로 답변하기 때문에 구체적이고 신뢰할 수 있는 정보를 제공함.

### 14.3 Kestra에서의 RAG 작동 과정 (Workflow)

1. **문서 수집**: 외부 URL에서 최신 릴리스 노트를 읽어옵니다.
2. **임베딩 생성**: `gemini-embedding-001` 모델을 사용하여 텍스트를 벡터 데이터로 변환합니다.
3. **지식 저장**: 변환된 데이터를 Kestra 내장 저장소(KV Store)에 보관합니다.
4. **컨텍스트 쿼리**: 질문 시 저장된 지식을 찾아 AI 프롬프트에 '참고 자료'로 넣어줍니다.

---

## 15. 🎯 최종 결론

* **LLM**은 강력한 엔진이지만, **Context(맥락)**라는 연료가 없으면 잘못된 길로 갈 수 있습니다.
* **Kestra AI Copilot**과 **RAG 기술**을 활용하면 최신 기술 문서를 실시간으로 반영하는 **지능형 워크플로우**를 구축할 수 있습니다.

---

## 16. ☁️ 클라우드 배포: GCP VM에 Kestra 본부 구축하기

### 16.1 GCP 인프라 및 네트워크 준비

1. **GCP 프로젝트 설정**: Compute Engine API 활성화.
2. **VM 인스턴스 생성**: `e2-standard-2`, `Ubuntu 22.04 LTS`.
3. **방화벽 규칙 개방**: TCP **8080(UI)** 및 **8081(관리용)** 포트 개방.

### 16.2 서비스 계정 및 GCS 인증 준비

1. **GCS 버킷 생성**: (예: `kestra-gcs-example0127`)
2. **서비스 계정(SA) 발급**: **Storage Admin** 역할 부여 후 JSON 키 다운로드.
3. **서버에 인증 파일 배치**:

```bash
# 인증 파일을 보관할 디렉토리 생성
mkdir -p /home/jaehyen07/kestra/secrets
# (gcp-sa.json을 위 경로에 저장)

```

### 16.3 서버 환경 구축 (Docker 설치)

```bash
# 1. 시스템 업데이트 및 Docker 설치
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 2. Kestra 작업 디렉토리 생성
mkdir -p ~/kestra && cd ~/kestra

```

---

## 17. 🛠️ 최종 성공 설정 및 가동 (실전 명령어)

### 17.1 최적화된 `docker-compose.yml` 작성

```yaml
volumes:
  postgres-data:
  kestra-data:

services:
  kestra:
    image: kestra/kestra:latest
    container_name: kestra-server
    user: "root"
    command: server standalone
    restart: unless-stopped
    ports:
      - "8080:8080"
      - "8081:8081"
    volumes:
      - kestra-data:/app/storage
      - /var/run/docker.sock:/var/run/docker.sock
      - /tmp/kestra-wd:/tmp/kestra-wd
      - /home/jaehyen07/kestra/secrets/gcp-sa.json:/secrets/gcp-sa.json:ro
    environment:
      GOOGLE_APPLICATION_CREDENTIALS: /secrets/gcp-sa.json
      KESTRA_CONFIGURATION: |
        datasources:
          postgres:
            url: jdbc:postgresql://10.106.112.3:5432/postgres
            username: kestra
            password: Kestra1234!
        kestra:
          server:
            basic-auth:
              enabled: true
              username: admin@kestra.io
              password: Admin1234!
          storage:
            type: gcs
            gcs:
              bucket: kestra-gcs-example0127
              projectId: kestra-sandbox-485208

```

### 17.2 서비스 실행 및 로그 확인

```bash
sudo docker compose up -d
sudo docker compose logs -f kestra-server

```

---

## 18. ⚠️ 트러블슈팅: GCS 연동 시 주의사항

1. **인증 파일 마운트**: 호스트 서버의 JSON 파일 경로와 컨테이너 내부 경로를 정확히 일치시켜야 합니다.
2. **권한 문제**: `user: "root"` 설정을 통해 Docker 소켓 접근 권한을 확보했습니다.
3. **JSON 형식 보존**: 텍스트 복사가 아닌 **파일 단위 업로드**를 권장합니다.

---

## 19. 🏁 요약: 지능형 클라우드 데이터 본부 완성

이로써 **GCP 인프라**, **GCS 저장소**, **PostgreSQL**, 그리고 **RAG 기술**이 결합된 자동화 본부를 구축했습니다. 이제 안정적인 클라우드 환경에서 지능형 데이터 파이프라인을 운영할 수 있습니다.

---

# 📝 Kestra 과제: 데이터 파이프라인 자동화 및 트러블슈팅 노트

이 문서는 **2021년 상반기 NYC 택시 데이터 적재**를 자동화하고, 실행 과정에서 발생한 에러를 해결한 과정을 기록합니다.

---

## 1. 메인 워크플로우 설계 (Orchestrator)

**목표**: 택시 종류(2종)와 기간(7개월)을 조합하여 총 14번의 작업을 한 번에 실행.

### **[작성 코드: `taxi_challenge_loop.yaml`]**

```yaml
id: taxi_challenge_loop
namespace: zoomcamp
tasks:
  - id: taxi_loop
    type: io.kestra.plugin.core.flow.ForEach
    values: ["yellow", "green"]
    tasks:
      - id: month_loop
        type: io.kestra.plugin.core.flow.ForEach
        values: ["2021-01-01", "2021-02-01", "2021-03-01", "2021-04-01", "2021-05-01", "2021-06-01", "2021-07-01"]
        tasks:
          - id: call_subflow
            type: io.kestra.plugin.core.flow.Subflow
            flowId: 09_gcp_taxi_scheduled
            inputs:
              taxi: "{{ parent.taskrun.value }}" # 상위 루프의 택시 종류 전달
              date: "{{ taskrun.value }}"        # 현재 루프의 날짜 전달

```

---

## 2. 서브플로우 수정 내역 (Worker: 09번 파일)

루프에서 호출될 때 발생한 에러를 해결하기 위해 `09_gcp_taxi_scheduled` 파일의 `inputs`와 `variables`를 수정했습니다.

### **[수정 내역 1: 입력값(Inputs) 확장]**

Subflow가 날짜를 넘겨줄 수 있도록 `date` 입력을 추가했습니다.

```yaml
inputs:
  - id: taxi
    type: SELECT
    values: [yellow, green]
    defaults: green
  - id: date    # 챌린지 루프에서 'date' 인풋을 받기 위해 필수 추가
    type: DATE
    defaults: "{{ now() | date('yyyy-MM-dd') }}"

```

### **[수정 내역 2: 변수(Variables) 로직 개선]**

스케줄러와 수동 호출 모두 대응하도록 `??` 연산자를 쓰고, 파싱 에러 방지를 위해 `render`를 적용했습니다.

```yaml
variables:
  # trigger.date(스케줄)가 없으면 inputs.date(수동/루프)를 사용
  target_date: "{{ render(trigger.date ?? inputs.date) }}"
  
  # 파일명 및 GCS 경로 생성 시 render를 사용하여 템플릿 중복 해석 방지
  file: "{{inputs.taxi}}_tripdata_{{ render(vars.target_date) | date('yyyy-MM') }}.csv"
  gcs_file: "gs://{{kv('GCP_BUCKET_NAME')}}/{{render(vars.file)}}"
  table: "{{kv('GCP_DATASET')}}.{{inputs.taxi}}_tripdata_{{ render(vars.target_date) | date('yyyy_MM') }}"

```

---

## 3. 트러블슈팅 (Troubleshooting)

실행 중 마주친 에러들과 그 해결책입니다.

| 발생 에러 | 원인 분석 | 해결 방법 |
| --- | --- | --- |
| **PebbleException** (date 찾지 못함) | Subflow 실행 시 `trigger` 객체가 없어 `trigger.date`를 참조할 수 없음. | `trigger.date ?? inputs.date` 문법으로 대체값 설정. |
| **Parsing Error** (index 0 실패) | 변수가 값으로 치환되지 않고 `{{...}}` 텍스트 그대로 전달되어 날짜 형식이 깨짐. | 모든 변수 참조 지점에 **`render()`** 함수를 감싸서 강제 치환. |

---

## 4. 최종 파이프라인 구조 요약

1. **Extract**: GitHub에서 월별 택시 CSV 데이터 다운로드 (`wget`).
2. **Load**: 다운로드된 파일을 Google Cloud Storage(GCS)로 전송.
3. **Transform & Merge**:
* BigQuery 외부 테이블 생성.
* `MD5` 해시로 고유 ID 생성 후 임시 테이블 구축.
* `MERGE` 구문을 통해 최종 테이블에 중복 없이 삽입.


4. **Cleanup**: 실행이 끝난 로컬 파일 삭제 (`Purge`).

---

## 5. 학습 포인트

* **오케스트레이션**: 중첩 루프를 통해 대량의 백필(Backfill) 작업을 자동화하는 법.
* **유연한 설계**: `??`(Null Coalescing) 연산자로 스케줄/수동 실행 통합 관리.
* **디버깅**: 에러 로그를 분석하여 변수 렌더링 시점의 문제를 파악하고 해결.

---
