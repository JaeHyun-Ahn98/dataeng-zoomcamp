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

## 🚀 Kestra란 무엇인가요?

Kestra는 최근 데이터 엔지니어링 커뮤니티에서 주목받는 오픈소스 워크플로우 오케스트레이터입니다. 이전에 유명했던 Airflow 같은 도구보다 배우기 쉽고 강력하다는 평을 듣습니다.

### 1. Kestra의 주요 특징

**YAML 기반 설정**: 복잡한 코딩 없이 YAML이라는 간단한 설정 파일만 작성하면 파이프라인이 만들어집니다.

**이벤트 기반 (Event-driven)**: 단순히 정해진 시간에 실행하는 것뿐만 아니라, "새로운 파일이 업로드되었을 때" 같은 특정 이벤트에 반응해 실행할 수 있습니다.

**풍부한 플러그인**: GCP(BigQuery, GCS), Postgres, Docker, Python 등 수많은 도구와 이미 연결될 준비가 되어 있습니다.

**직관적인 UI**: 웹 브라우저에서 파이프라인 구조를 그래프로 보며 직접 수정하고 실행 결과를 확인할 수 있습니다.

### 2. Kestra가 데이터를 다루는 방식 (ETL)

강의에서 실습할 내용은 다음과 같습니다.

**Extract (추출)**: Kestra가 외부 API(뉴욕 택시 데이터 등)에서 데이터를 가져옵니다.

**Transform (변환)**: 가져온 데이터를 Python이나 SQL을 이용해 가공합니다.

**Load (적재)**: 깨끗해진 데이터를 구글 빅쿼리(BigQuery)나 로컬 DB에 저장합니다.

## 3. Kestra 설치 및 실행 실습

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

## 💡 요약 정리

| 구분 | 설명 |
|------|------|
| **정의** | 복잡한 데이터 작업의 순서를 정하고 자동화하는 시스템 |
| **비유** | 수많은 악기를 조율하여 멋진 곡을 만드는 지휘자 |
| **Kestra** | YAML 언어를 사용하여 누구나 쉽게 구축할 수 있는 최신 오케스트레이션 도구 |
| **핵심 기능** | 스케줄링, 실패 시 재시도, 작업 간 데이터 전달, 모니터링 |
| **실행 포트** | 웹 UI: 8080, API: 8081 |
| **접속 정보** | admin@kestra.io / Admin1234 |