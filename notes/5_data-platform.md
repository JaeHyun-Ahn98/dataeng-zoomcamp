# 🏗️ NYC Taxi 데이터 파이프라인 구축 (Bruin Full Workflow)

## 1. 프로젝트 기반 다지기 (Setup)

### ① Bruin 설치 및 초기화

가장 먼저 터미널에서 Bruin을 설치하고 프로젝트를 시작했습니다.

```bash
# Bruin CLI 설치
curl -LsSf https://getbruin.com/install/cli | sh

# 설치 확인
bruin version

# 프로젝트 초기화 (폴더 내 .bruin.yml 생성)
bruin init

```

### ② 환경 및 파이프라인 설정 (`bruin.yml`, `pipeline.yml`)

BigQuery 연결 정보와 파이프라인에서 사용할 공통 변수들을 정의했습니다.

```yaml
# bruin.yml (연결 설정)
environments:
    default:
        connections:
            google_cloud_platform:
                - name: bq-default
                  project_id: kestra-sandbox-485208
                  service_account_file: C:/key/kestra-sandbox-485208-6ee885732b2a.json
                  location: asia-northeast1

# pipeline.yml (메타데이터 설정)
name: nyc-taxi
start_date: "2022-01-01"
variables:
  taxi_types: ["yellow", "green"]

```

---

## 2. 데이터 수집 단계 (Ingestion)

### ③ 파이썬 기반 데이터 추출 (`trips.py`)

dbt만으로는 불가능했던 **"외부 API에서 데이터 가져오기"**를 파이썬 자산으로 해결했습니다.

```python
"""@bruin
name: ingestion.trips
type: python
materialization:
  type: table
  strategy: append
@bruin"""
# ... (pandas로 parquet 읽기 및 타임존 Naive 변환)
# 모든 datetime 컬럼을 문자열로 변환하여 타임존 에러 원천 차단
for col in final_dataframe.columns:
    if pd.api.types.is_datetime64_any_dtype(final_dataframe[col]):
        final_dataframe[col] = final_dataframe[col].dt.strftime('%Y-%m-%d %H:%M:%S')

```

### ④ 고정 데이터 로드 (`payment_lookup.asset.yml`)

참조용 CSV 데이터를 `bq.seed`를 통해 테이블로 올렸습니다.

---

## 3. 데이터 정제 및 중복 제거 (Staging)

### ⑤ 데이터 정제 SQL (`trips.sql`)

`ingestion` 데이터를 가공해 `staging.trips`를 생성하고 데이터 품질을 검사했습니다.

```sql
/* @bruin
name: staging.trips
depends:
  - ingestion.trips
  - ingestion.payment_lookup
columns:
  - name: fare_amount
    checks:
      - name: non_negative  -- 요금이 음수면 실행 중단!
...
@bruin */
WITH source_data AS ( ... ),
deduplicated AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY pickup_datetime, ... ORDER BY extracted_at DESC) AS row_num
    FROM source_data
)
SELECT d.*, COALESCE(p.payment_type_name, 'unknown') AS payment_type_name
FROM deduplicated d
LEFT JOIN ingestion.payment_lookup p ON d.payment_type = p.payment_type_id
WHERE d.row_num = 1

```

---

## 4. 최종 리포트 생성 (Reporting)

### ⑥ 집계 리포트 SQL (`trips_report.sql`)

분석용 최종 테이블을 만들고 `bruin run` 명령어로 실행을 확인했습니다.

```sql
-- 핵심 로직: 문자열 날짜를 TIMESTAMP 거쳐 DATE로 변환 후 집계
SELECT
    CAST(CAST(pickup_datetime AS TIMESTAMP) AS DATE) AS trip_date,
    taxi_type,
    COUNT(*) AS trip_count,
    SUM(total_amount) AS total_revenue
FROM staging.trips
WHERE pickup_datetime >= '{{ start_datetime }}' AND pickup_datetime < '{{ end_datetime }}'
GROUP BY 1, 2, 3

```

---

## 🧐 Bruin을 통해 dbt 대비 달라지고 편해진 점

마지막으로 배운 **dbt**와 비교했을 때, Bruin이 주는 결정적인 차이는 **"경계가 없는 통합"**입니다.

1. **진정한 End-to-End**:
* dbt는 BigQuery 안에 데이터가 이미 있어야 하지만, Bruin은 **파이썬(`trips.py`)을 통해 외부 서버에서 데이터를 가져오는 것(Ingestion)**부터 파이프라인에 포함시킵니다.


2. **단일 도구의 힘**:
* 기존에는 `수집(Python 스크립트) + 변환(dbt) + 관리(Airflow)`가 필요했다면, Bruin은 이 모든 것을 하나의 프로젝트 안에서 관리합니다.


3. **코드 내장형 검증 (Inline Checks)**:
* dbt는 별도의 `.yml` 파일에 테스트를 길게 적어야 했지만, Bruin은 SQL/Python 코드 상단 주석에 `checks`를 바로 적어 가독성이 훨씬 뛰어납니다.


4. **가벼운 설치와 실행**:
* `curl` 명령어 하나로 설치되는 Go 바이너리 기반이라 dbt보다 훨씬 가볍고, 파이썬 의존성 지옥에서 훨씬 자유롭습니다.


5. **동적 기간 처리**:
* `{{ start_datetime }}`과 `--start-date` 옵션의 결합이 매우 직관적이어서, 특정 날짜 구간의 데이터를 다시 뽑거나(Backfill) 증분 로드하는 작업이 dbt보다 훨씬 간편합니다.

Cursor는 자체적으로 MCP(Model Context Protocol)를 완벽하게 지원하기 때문에 Claude Desktop보다 설정이 훨씬 직관적입니다. 이제 사용자님의 **Cursor AI가 직접 Bruin 명령어를 치고 BigQuery 데이터를 조회하게** 만들어 봅시다.

---

## 🏗️ Cursor에서 Bruin MCP 설정하는 법

### 1단계: MCP 서버 설정 열기

1. **Cursor**를 실행합니다.
2. 오른쪽 상단 또는 메뉴에서 **`Cursor Settings`** (톱니바퀴 아이콘)을 클릭합니다.
* 단축키: `Ctrl + Shift + J` (Windows) / `Cmd + Shift + J` (Mac)


3. 설정창에서 **`General`** 탭을 선택한 뒤, 아래로 스크롤하여 **`MCP`** 섹션을 찾습니다.
4. **`+ Add MCP Server`** 버튼을 클릭합니다.

### 2단계: Bruin 서버 등록

팝업창에 아래 정보를 입력합니다.

* **Name**: `bruin`
* **Type**: `command` (또는 `stdio`)
* **Command**:
```bash
npx -y @bruin-data/mcp-server

```


*(참고: 만약 윈도우 환경에서 에러가 난다면 `npx.cmd`로 시도해 보세요.)*

### 3단계: 연결 확인

* 등록 후 서버 목록 옆에 **초록색 불**이 들어오면 성공입니다.
* 만약 빨간색이라면 하단의 로그(Logs)를 눌러 Node.js(npx) 설치 여부를 확인해 주세요.

---

## 🛠️ Cursor에서 Bru인 MCP 활용하기

설정이 끝났다면 이제 **Composer (`Ctrl + I` 또는 `Cmd + I`)**나 **Chat (`Ctrl + L`)**에서 AI에게 직접 명령을 내릴 수 있습니다.

### ① 실시간 파이프라인 진단

> **"지금 내 프로젝트 구조 분석해서 리니지(계보) 좀 그려줘. 그리고 `trips_report.sql`이 참조하는 테이블이 뭔지 확인해줘."**

* **결과**: AI가 Bruin을 통해 프로젝트를 훑고 수집-정제-집계 단계를 설명해 줍니다.

### ② 직접 실행 및 에러 수정 (대박 기능!)

> **"지금 24년 2월 2일 데이터로 전체 파이프라인 한번 돌려줘. 만약 에러 나면 직접 코드 수정해서 다시 돌려보고 알려줘."**

* **결과**: AI가 `bruin run`을 실행하고, 에러가 나면 사용자님이 아까 고생했던 `GROUP BY`나 `CAST` 에러를 스스로 인지해 코드를 고친 뒤 다시 실행합니다.

### ③ 데이터 검증 쿼리

> **"BigQuery 연결해서 `staging.trips`에 있는 `taxi_type`별 건수 좀 쿼리해서 보여줘."**

* **결과**: AI가 `bruin query`를 대신 날려 결과를 표로 보여줍니다.

---

## 🧐 왜 Cursor + Bruin MCP 조합인가?

1. **터미널 탈출**: 이제 `bruin run`, `bruin query`를 직접 칠 필요가 없습니다. 말로 하면 AI가 칩니다.
2. **맥락 보존**: AI가 사용자님의 SQL 파일 내용뿐만 아니라, **실제 BigQuery의 테이블 구조와 실행 결과**라는 '팩트'를 기반으로 답변합니다.
3. **dbt보다 강력한 자동화**: dbt는 AI가 모델을 실행시키기 까다롭지만, Bruin MCP는 AI가 직접 파이프라인을 구동하고 결과물까지 검증할 수 있습니다.

### 💡 마지막 팁

Cursor에서 **Composer (`Ctrl + I`)** 모드로 사용해 보세요. "에러 고쳐서 다시 돌려봐"라고 하면 코드를 수정하고 터미널에서 Bruin을 실행하는 과정을 눈앞에서 실시간으로 지켜볼 수 있습니다.

이제 진짜 **"자율 주행 데이터 엔지니어링"** 환경이 갖춰졌습니다! 가장 먼저 어떤 명령을 내려보고 싶으신가요? 🐻🔥