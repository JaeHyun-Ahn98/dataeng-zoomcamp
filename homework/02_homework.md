# 📝 모듈 2 숙제: 워크플로우 오케스트레이션 (Kestra)

이번 과제에서는 Kestra를 사용하여 데이터 파이프라인을 오케스트레이션하고, 과거 데이터를 처리하는 백필(Backfill) 및 루프 작업을 실습합니다.

## 제출 요구사항

* 과제 제출 시 **GitHub 저장소** 또는 기타 공개 코드 호스팅 사이트 링크를 포함해야 합니다.
* 저장소에는 숙제 풀이에 사용한 코드가 포함되어야 합니다.
* 파일 형태가 아닌 코드(예: Kestra YAML 설정 등)는 저장소의 **README 파일**에 직접 작성해 주세요.

---

## 과제 (Assignment)

지금까지 강좌에서는 2019년과 2020년 데이터를 처리했습니다. 여러분의 과제는 기존 플로우를 확장하여 **2021년 데이터**를 포함시키는 것입니다.

**힌트 (Kestra 활용법):**

* **백필(Backfill) 기능 활용**: `scheduled flow`에서 백필 기능을 사용하여 2021년 데이터를 처리하세요. 데이터가 존재하는 기간인 **2021-01-01부터 2021-07-31까지**를 선택해야 합니다. `yellow`와 `green` 택시 데이터 모두에 대해 수행하세요.
* **수동 실행**: 또는 2021년의 7개월치 데이터를 `yellow` 및 `green` 각각 수동으로 실행하세요.
* **챌린지 과제**: `ForEach` 태스크를 사용하여 연도-월 조합과 택시 종류를 반복(Loop)하고, `Subflow` 태스크를 통해 각 조합에 대한 플로우를 실행해 보세요.(README.md)참고

---

# 🚀 Kestra Challenge: 2021년 택시 데이터 자동 적재 (ForEach & Subflow)

## 1. 과제 목표

* 2021년 1월부터 7월까지의 **Yellow** 및 **Green** 택시 데이터를 자동으로 적재.
* `ForEach` 태스크를 중첩하여 사용하고, `Subflow` 태스크를 통해 기존의 적재 플로우를 호출하는 방식으로 자동화 구현.

---

## 2. 메인 오케스트레이터 코드 (Main Flow)

두 종류의 택시와 7개월의 기간을 조합하여 총 14번의 하위 플로우를 호출합니다.

```yaml
id: taxi_challenge_loop
namespace: zoomcamp

tasks:
  - id: taxi_loop
    type: io.kestra.plugin.core.flow.ForEach
    values: ["yellow", "green"] # 1단계: 택시 종류 반복
    tasks:
      - id: month_loop
        type: io.kestra.plugin.core.flow.ForEach
        # 2단계: 2021년 1월부터 7월까지 날짜 리스트 반복
        values: ["2021-01-01", "2021-02-01", "2021-03-01", "2021-04-01", "2021-05-01", "2021-06-01", "2021-07-01"]
        tasks:
          - id: call_subflow
            type: io.kestra.plugin.core.flow.Subflow
            flowId: 09_gcp_taxi_scheduled # 실제 데이터 적재를 담당하는 일꾼 Flow
            namespace: zoomcamp
            wait: true # 이전 작업이 끝날 때까지 대기
            transmitFailed: true # 하위 플로우 실패 시 메인 플로우도 실패 처리
            inputs:
              taxi: "{{ parent.taskrun.value }}" # taxi_loop에서 받은 값 (yellow/green)
              date: "{{ taskrun.value }}"        # month_loop에서 받은 날짜 값

```

---

## 3. 수정된 일꾼 플로우 코드 (Subflow: 09번 파일)

루프에서 호출될 때 날짜 변수가 누락되거나 템플릿 해석 오류가 발생하지 않도록 핵심 로직을 수정했습니다.

### **[핵심 수정 부분]**

* **Inputs**: 수동/Subflow 실행을 위한 `date` 입력창 추가.
* **Variables**: `trigger.date`가 없을 경우 `inputs.date`를 사용하도록 설정하고, 파싱 에러 방지를 위해 `render` 함수 적용.

```yaml
id: 09_gcp_taxi_scheduled
namespace: zoomcamp

inputs:
  - id: taxi
    type: SELECT
    values: [yellow, green]
  - id: date
    type: DATE
    defaults: "{{ now() | date('yyyy-MM-dd') }}"

variables:
  # 스케줄러 실행 시 trigger.date 사용, 루프 실행 시 inputs.date 사용 (에러 해결 포인트)
  target_date: "{{ render(trigger.date ?? inputs.date) }}"
  file: "{{inputs.taxi}}_tripdata_{{ render(vars.target_date) | date('yyyy-MM') }}.csv"
  gcs_file: "gs://{{kv('GCP_BUCKET_NAME')}}/{{render(vars.file)}}"
  table: "{{kv('GCP_DATASET')}}.{{inputs.taxi}}_tripdata_{{ render(vars.target_date) | date('yyyy_MM') }}"

tasks:
  - id: extract
    type: io.kestra.plugin.scripts.shell.Commands
    commands:
      - wget -qO- https://github.com/DataTalksClub/nyc-tlc-data/releases/download/{{inputs.taxi}}/{{render(vars.file)}}.gz | gunzip > {{render(vars.file)}}
  
  # ... (이후 GCS 업로드 및 BigQuery Merge 로직 동일)

```

---

## 퀴즈 질문 (Quiz Questions)

워크플로우 오케스트레이션, Kestra 및 ETL 파이프라인에 대한 이해도를 테스트하는 6개 질문입니다.

요청하신 내용을 깔끔한 마크다운 형식으로 정리해 드립니다. GitHub README나 과제 제출용으로 바로 복사해서 사용하세요.

---

# 🚀 모듈 2 숙제: 워크플로우 오케스트레이션 (Kestra)

## 질문 1. 파일 크기 확인

2020년 12월 **Yellow Taxi** 데이터 실행 시, `extract` 태스크의 결과물인 압축 해제된 파일(`yellow_tripdata_2020-12.csv`)의 크기는 얼마입니까?

* 128.3 MiB
* ✅ **134.5 MiB**
* 364.7 MiB
* 692.6 MiB


---

## 질문 2. 변수 렌더링 이해

입력값 `taxi`가 **green**, `year`가 **2020**, `month`가 **04**일 때, 변수 `file`의 최종 렌더링된 값은 무엇입니까?

* `{{inputs.taxi}}_tripdata_{{inputs.year}}-{{inputs.month}}.csv`
* ✅ **green_tripdata_2020-04.csv**
* `green_tripdata_04_2020.csv`
* `green_tripdata_2020.csv`

---

## 질문 3. Yellow Taxi 행 수 (2020년 전체)

2020년 한 해 동안의 모든 **Yellow Taxi** CSV 파일에 포함된 전체 행(Rows) 수는 몇 개입니까?

* 13,537,299
* ✅ **24,648,499**
* 18,324,219
* 29,430,127

**SQL 쿼리:**

```sql
SELECT SUM(row_count) AS total_2020_rows
FROM `zoomcamp.__TABLES__`
WHERE table_id LIKE 'yellow_tripdata_2020_%'
  AND table_id NOT LIKE '%_ext';

```

---

## 질문 4. Green Taxi 행 수 (2020년 전체)

2020년 한 해 동안의 모든 **Green Taxi** CSV 파일에 포함된 전체 행(Rows) 수는 몇 개입니까?

* 5,327,301
* 936,199
* ✅ **1,734,051**
* 1,342,034

**SQL 쿼리:**

```sql
SELECT SUM(row_count) AS total_2020_rows
FROM `zoomcamp.__TABLES__`
WHERE table_id LIKE 'green_tripdata_2020_%'
  AND table_id NOT LIKE '%_ext';

```

---

## 질문 5. Yellow Taxi 행 수 (2021년 3월)

2021년 3월 **Yellow Taxi** CSV 파일에 포함된 행(Rows) 수는 몇 개입니까?

* 1,428,092
* 706,911
* ✅ **1,925,152**
* 2,561,031

**SQL 쿼리:**

```sql
SELECT COUNT(*)
FROM `zoomcamp.yellow_tripdata_2021_03`;

```

---

## 질문 6. 스케줄 트리거 시간대 설정

`Schedule` 트리거에서 시간대를 뉴욕(New York)으로 설정하는 올바른 방법은 무엇입니까?

* `Schedule` 설정에 `timezone` 속성을 `EST`로 추가한다.
* ✅ **`Schedule` 설정에 `timezone` 속성을 `America/New_York`으로 추가한다.**
* `Schedule` 설정에 `timezone` 속성을 `UTC-5`로 추가한다.
* `Schedule` 설정에 `location` 속성을 `New_York`으로 추가한다.

---

## 솔루션 제출

* **과제 제출 양식**: [https://courses.datatalks.club/de-zoomcamp-2026/homework/hw2](https://courses.datatalks.club/de-zoomcamp-2026/homework/hw2)

---
