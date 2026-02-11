# 🚀 모듈 4: 애널리틱스 엔지니어링 (Analytics Engineering) 가이드

분석 엔지니어링의 목표는 데이터 웨어하우스(BigQuery)에 적재된 가공되지 않은 데이터를 분석하기 좋은 구조(View/Table)로 변환하는 것입니다. 이를 위해 **dbt(Data Build Tool)**를 활용합니다.

---

## 📂 1. 핵심 개념 이해

### 애널리틱스 엔지니어(AE)란?

* **역할:** 데이터 엔지니어(인프라 구축)와 데이터 분석가(비즈니스 통찰력) 사이의 가교 역할입니다.
* **핵심:** 소프트웨어 엔지니어링의 베스트 프랙티스(버전 관리, 테스트, CI/CD)를 데이터 변환 과정에 도입합니다.

### dbt Cloud vs dbt Core

* **dbt Core:** 오픈 소스 CLI 도구입니다. 로컬 환경에서 무료로 실행할 수 있으며 원리를 파악하기에 좋습니다.
* **dbt Cloud:** dbt Labs에서 제공하는 SaaS 플랫폼입니다. 웹 IDE, 스케줄러, 문서 자동화 기능을 제공하여 협업과 배포가 편리합니다.

---

## 🛠️ 2. 환경 설정 (BigQuery + dbt Cloud)

### 필수 조건 확인

* **BigQuery 데이터:** 2019-2020년 뉴욕 택시 데이터(`yellow`, `green`)가 BigQuery 데이터셋(`nytaxi`)에 로드되어 있어야 합니다.
* **서비스 계정:** 다음 권한을 가진 GCP 서비스 계정의 **JSON 키**가 필요합니다.
* BigQuery Data Editor, BigQuery Job User, BigQuery User.



### dbt Cloud 연결 단계

1. **프로젝트 생성:** dbt Cloud에서 `taxi_rides_ny` 프로젝트를 생성합니다.
2. **연결 구성:** BigQuery를 선택하고 준비한 **JSON 키 파일을 업로드**합니다.
3. **데이터셋 설정:** 기본 데이터셋을 `dbt_prod`로 설정하고, 위치를 모듈 3의 데이터셋과 동일하게 맞춥니다.
4. **저장소(Git) 설정:** GitHub 저장소를 연결하거나 dbt Managed 저장소를 선택합니다.

---

## 📂 3. dbt 프로젝트 구조 및 역할

### 핵심 설정 파일

* **`dbt_project.yml`**: 프로젝트에서 가장 중요한 파일입니다. 프로젝트 이름, 프로필 설정, 변수 정의, 모델의 기본 구체화(Materialization) 방식 등을 dbt에 알려주는 컨트롤 타워 역할을 합니다. dbt 명령어를 실행할 때마다 이 파일이 있는지 확인하며, 없으면 실행되지 않습니다.

### 주요 폴더 및 역할

* **`models/`**: 실제 데이터 변환 로직(SQL)이 들어가는 핵심 폴더입니다. dbt는 다음 세 가지 단계를 권장합니다.
  * **Staging**: 원본 데이터를 1:1로 가져와 컬럼명 변경, 데이터 타입 변환 등 최소한의 정제만 수행합니다.
  * **Intermediate**: 복잡한 Join이나 대규모 정제 로직이 들어가는 중간 단계입니다.
  * **Marts**: 최종 사용자가 분석이나 대시보드에 즉시 사용할 수 있는 완성된 데이터 모델(Star Schema 등)이 위치합니다.

* **`seeds/`**: CSV 같은 정적 파일을 데이터베이스에 테이블로 로드할 때 사용합니다. 국가 코드나 매핑 테이블 같은 변경이 적은 데이터를 관리하기에 적합합니다.

* **`snapshots/`**: 시간에 따라 변하는 데이터의 이력을 기록(SCD Type 2)할 때 사용합니다. 예를 들어, 주문 상태가 '결제 완료'에서 '배송 중'으로 바뀔 때 이전 상태를 덮어쓰지 않고 기록을 보존합니다.

* **`macros/`**: SQL에서 반복되는 로직을 재사용 가능한 함수(Jinja 템플릿 사용)로 만듭니다. Python 함수와 유사하며, 한 곳에서 수정한 내용이 모든 모델에 반영되게 할 수 있습니다.

* **`tests/`**: 데이터의 품질을 검증하는 SQL 파일이 들어갑니다. 특정 쿼리의 결과가 0개 이상이면 테스트 실패로 간주하여 데이터 오류를 사전에 방지합니다.

* **`analysis/`**: 공유할 필요는 없지만 데이터 품질 체크나 관리 작업을 위해 작성한 SQL 스크립트를 보관하는 장소입니다.

### 기타 구성 요소

* **`README.md`**: 프로젝트 설치 방법, 연락처, 실행 가이드 등 프로젝트에 대한 전반적인 문서를 작성하는 곳입니다.

---

## 🔄 4. 환경(Environment)의 종류

| 구분 | 개발 환경 (Development) | 배포 환경 (Deployment/Prod) |
| --- | --- | --- |
| **목적** | 모델 구축 및 개인 테스트 | 실제 운영 및 정기 스케줄링 |
| **자격 증명** | 개인 Google 계정 (OAuth) 또는 서비스 계정 | 서비스 계정 JSON 키 |
| **스키마** | `dbt_<your_name>` (격리된 공간) | `dbt_prod` (공식 공간) |

---

## 📂 5. dbt Sources 설정 및 Staging 모델 구축 정리

### 1. dbt Sources란?

데이터 웨어하우스(BigQuery)에 있는 원본 데이터의 위치를 dbt에게 알려주는 **'지도'** 역할을 합니다.

* **설정 파일**: `models/staging` 폴더 내에 `sources.yml` (또는 `.yaml`) 파일을 생성합니다.
* **주요 설정 항목**:
  * `name`: dbt 코드 내에서 호출할 소스 그룹의 이름 (예: `raw_data`)
  * `database`: GCP 프로젝트 ID (`kestra-sandbox-xxxx`)
  * `schema`: BigQuery 데이터셋 이름 (`zoomcamp`)
  * `tables`: 실제 참조할 테이블 리스트 (`green_tripdata`, `yellow_tripdata`)

### 2. Staging 모델 생성 규칙

원본 데이터를 가공하기 전, 가장 먼저 만드는 **첫 번째 레이어**입니다.

* **파일명 규칙**: 원본 테이블 이름 앞에 `stg_` 접두사를 붙여 생성합니다. (예: `stg_green_tripdata.sql`)
* **데이터 참조 방식**: `FROM` 절에 직접 테이블명을 쓰지 않고, `{{ source('소스명', '테이블명') }}` 문법을 사용합니다.
  * *장점*: 원본 테이블 위치가 바뀌어도 `yml` 파일 한 곳만 수정하면 모든 모델에 자동 반영됩니다.

### 3. Staging 모델에서의 주요 작업 (정제)

데이터 분석을 본격적으로 하기 전에 데이터를 "예쁘게" 만드는 과정입니다.

* **컬럼명 변경 (Aliasing)**: 모호한 이름을 직관적으로 변경 (예: `vendorid` → `vendor_id`)
* **데이터 타입 변환 (Casting)**:
  * 숫자 계산을 위해 문자열을 숫자형으로 변환 (`CAST(... AS integer)`)
  * 소수점 계산을 위해 `float64` 또는 `numeric`으로 변환 (BigQuery 기준)
  * 날짜/시간 데이터 타입 지정 (`CAST(... AS timestamp)`)

* **기초 필터링**: `WHERE` 절을 사용해 비정상적인 데이터(예: `vendorid`가 NULL인 경우)를 미리 걸러냅니다.

### 4. 실습 팁 및 도구 활용

* **Preview**: 쿼리를 실행하기 전, 하단 결과 창을 통해 데이터가 올바르게 변환되는지 실시간으로 확인합니다.
* **Compile**: Jinja 문법(`{{ ... }}`)이 실제 SQL 쿼리로 어떻게 바뀌는지 확인하여 문법 오류를 방지합니다.
* **재사용성**: 한 번 스테이징 모델을 잘 만들어두면, 이후에는 `{{ ref('stg_green_tripdata') }}`를 통해 정제된 데이터를 편하게 불러올 수 있습니다.

---

## 💡 실습 팁 (Best Practices)

* **`ref()` 함수 사용:** 테이블 이름을 직접 쓰지 말고 `ref('model_name')`를 사용하세요. dbt가 데이터 간의 선후 관계(Lineage)를 자동으로 관리해 줍니다.
* **버전 관리:** 모든 변경 사항은 새 브랜치를 만들어 작업하고, 완료 후 `main` 브랜치로 **Pull Request(PR)**를 보내 병합하세요.
* **테스트:** 데이터 무결성을 위해 `tests/` 폴더를 활용하여 비즈니스 로직과 데이터 품질을 지속적으로 검증하세요.

---

## 📂 6. Intermediate 모델: 데이터 통합 (Union)

Staging 레이어에서 정제된 개별 소스들을 하나로 결합하여 분석을 위한 단일 통합 데이터셋을 구축하는 단계입니다.

### 1. 실습 목적: 데이터 통합 (Data Integration)

* **목적:** 분리된 Green 및 Yellow 택시 데이터를 통합하여 전체 산업에 대한 통찰력을 확보합니다.
* **효과:** 파편화된 소스를 동일한 규격으로 맞춘 '단일 진실 공급원(Single Source of Truth)'을 생성합니다.

### 2. 주요 실습 과정 및 코드 (int_trips_unioned.sql)

직접적인 테이블 참조 대신 `ref()` 함수를 사용하여 모델 간 의존성을 연결하고 수직 결합(`UNION ALL`)을 수행했습니다.

```sql
with green_tripdata as (
    select * from {{ ref('stg_green_tripdata') }}
),
yellow_tripdata_partitioned as (
    select * from {{ ref('stg_yellow_tripdata') }}
),
trips_unioned as (
    select * from green_tripdata
    union all
    select * from yellow_tripdata_partitioned
)
select * from trips_unioned

```

### 3. 핵심 비즈니스 로직 적용 (Staging 레이어 정제)

통합 모델(`int`)이 정상적으로 동작하도록 각 스테이징 모델에서 데이터 규격을 맞추는 작업을 수행했습니다.

* **상숫값 생성 및 순서 동기화 (Yellow 데이터):**
Green 데이터에는 있고 Yellow에는 없는 컬럼을 상숫값(`1`, `0`)으로 생성하여 컬럼 개수와 순서를 맞췄습니다.
```sql
-- stg_yellow_tripdata.sql 예시
1 as trip_type,  -- yellow taxis can only be street-hail
0 as ehail_fee   -- yellow taxis do not have ehail fees

```


* **데이터 타입 통일 (Casting):**
`UNION ALL`의 필수 조건인 데이터 타입 일치를 위해 모든 핵심 컬럼에 `CAST` 문법을 적용했습니다.
```sql
-- 공통 적용 예시
CAST(store_and_fwd_flag as string) as store_and_fwd_flag,
CAST(fare_amount as numeric) as fare_amount

```



---

## 💡 분석 엔지니어링 핵심 포인트 (Key Takeaways)

### 1. 계층형 모델링 (Layered Modeling)

* **역할 분리:** 데이터 정제는 **Staging**에서, 통합 및 비즈니스 결합은 **Intermediate**에서 담당하여 코드의 가독성과 재사용성을 높입니다.

### 2. 의존성 관리와 계보 (Lineage)

* `ref()` 함수를 사용하면 dbt가 데이터 흐름을 시각화(Lineage Graph)할 수 있게 도와주며, 상위 모델이 변경될 때 하위 모델이 안전하게 업데이트되도록 보장합니다.

### 3. 방어적 SQL 작성 (Defensive Coding)

* 소스 데이터의 스키마는 언제든 변할 수 있습니다. 실습에서 경험한 타입 불일치 에러를 방지하기 위해, 명시적으로 타입을 지정(`CAST`)하는 습관이 파이프라인의 안정성을 결정합니다.

---

## 🛠️ 실전 트러블슈팅 요약

* **Location 관리:** BigQuery 데이터셋 위치(`asia-northeast1`)와 dbt Cloud 설정을 일치시켜 리전 에러를 해결했습니다.
* **명명 규칙(Naming):** 계산된 컬럼이나 변환된 데이터에는 반드시 별칭(`AS [이름]`)을 부여해야 데이터베이스가 컬럼명을 정확히 인식합니다.

---

## 📂 7. dbt Seed & Macro 활용 및 최종 Fact 모델 구축

### 1. 정적 데이터 추가 (dbt Seed)

데이터 분석의 기준이 되는 외부 참조 데이터를 프로젝트에 이식하는 단계입니다.

* **대상 파일**: `taxi_zone_lookup.csv` (위치 ID별 구역명 매칭 데이터)
* **수행 작업**: `seeds/` 디렉토리에 CSV 파일 배치 후 터미널에서 `dbt seed` 명령어 실행
* **결과**: 데이터베이스 내에 `taxi_zone_lookup` 테이블이 생성되어 `ref()` 함수로 어디서든 호출할 수 있는 상태가 됨

---

### 2. Seed 참조 및 데이터 정제 (`dim_zones`)

생성된 Seed 테이블을 SQL 모델에서 어떻게 불러와서 사용하는지 익히는 단계입니다.

* **수행 작업**: `ref('taxi_zone_lookup')`를 사용하여 시드 데이터를 참조하는 모델 작성
* **결과 코드 (`dim_zones.sql`)**:

```sql
with taxi_zone_lookup as (
    -- dbt seed로 생성된 테이블을 참조
    select * from {{ ref('taxi_zone_lookup') }}
),
renamed as (
    select
        locationid as location_id,
        borough,
        zone,
        service_zone
    from taxi_zone_lookup
)
select * from renamed

```

---

### 3. 매크로 정의 및 활용 (`dim_vendors` & `fct_trips`)

반복되는 로직을 모듈화하여 자바의 함수처럼 사용하는 방법을 익히는 단계입니다.

* **수행 작업 1 (매크로 생성)**: `macros/` 폴더에 각각의 `.sql` 파일 작성
* **매크로 코드 1 (`get_vendor_names.sql`)**:

```sql
{% macro get_vendor_names(vendor_id) -%}
case
    when {{ vendor_id }} = 1 then 'Creative Mobile Technologies, LLC'
    when {{ vendor_id }} = 2 then 'VeriFone Inc'
    when {{ vendor_id }} = 4 then 'Unknown Vendor'
end 
{%- endmacro %}

```

* **매크로 코드 2 (`get_payment_type_description.sql`)**:

```sql
{% macro get_payment_type_description(payment_type) -%}
    case {{ payment_type }}
        when 1 then 'Credit card'
        when 2 then 'Cash'
        when 3 then 'No charge'
        when 4 then 'Dispute'
        when 5 then 'Unknown'
        when 6 then 'Voided trip'
        else 'EMPTY'
    end
{%- endmacro %}

```

* **수행 작업 2 (매크로 적용)**: `dim_vendors.sql` 또는 `fct_trips.sql`에서 위 매크로들을 호출해 데이터 변환

---

### 4. 최종 모델 통합 (`fct_trips`)

앞서 만든 모든 부품(Seed, Macro, Join)을 결합하여 분석용 최종 Fact 테이블을 완성하는 단계입니다.

* **대상 작업**: 고유 PK 생성(Hashing), 결제 수단 매크로 적용, 장소 정보 2중 JOIN
* **결과 코드 (`fct_trips.sql`)**:

```sql
with trips_unioned as (
    select * from {{ ref('int_trips_unioned') }}
), 
taxi_zone_lookup as (
    select * from {{ ref('taxi_zone_lookup') }}
)
select 
    -- 1. 직접 만든 PK (MD5 해싱을 이용한 고유 지문 생성)
    to_hex(md5(cast(concat(coalesce(cast(t.vendor_id as string), ''), '-', coalesce(cast(t.pickup_datetime as string), '')) as string))) as tripid,
    
    -- 2. 결제 수단 변환 매크로 적용 (정의한 매크로 호출)
    {{ get_payment_type_description('t.payment_type') }} as payment_type_description,
    
    -- 3. 장소 정보 조인 (승차/하차 각 1회씩 총 2회)
    pickup_zone.borough as pickup_borough, 
    pickup_zone.zone as pickup_zone, 
    dropoff_zone.borough as dropoff_borough, 
    dropoff_zone.zone as dropoff_zone,
    
    t.pickup_datetime, t.dropoff_datetime, t.fare_amount, t.total_amount
from trips_unioned t
inner join taxi_zone_lookup as pickup_zone on t.pickup_location_id = pickup_zone.locationid
inner join taxi_zone_lookup as dropoff_zone on t.dropoff_location_id = dropoff_zone.locationid

```

---

### 5. 패키지 설치 및 활용 (`dbt_utils`)

직접 짠 복잡한 SQL 로직을 표준화된 외부 패키지로 대체하여 생산성을 높이는 단계입니다.

* **대상 패키지**: `dbt-labs/dbt_utils`
* **수행 작업**:
1. 프로젝트 루트에 `packages.yml` 파일 생성 및 패키지 정보 작성
2. 터미널에서 `dbt deps` 명령어를 입력하여 필요한 라이브러리 다운로드


* **결과**: 직접 구현한 해시 PK 생성 로직을 `generate_surrogate_key` 함수 하나로 대체 가능함

#### 패키지 적용 예시 (PK 생성)

```sql
-- packages.yml 예시
packages:
  - package: dbt-labs/dbt_utils
    version: 1.1.1

-- fct_trips.sql 적용 예시 (패키지 함수 사용 시)
{{ dbt_utils.generate_surrogate_key(['t.vendor_id', 't.pickup_datetime']) }} as tripid

```

---

## 📂 8. dbt Tests: 데이터 품질 테스트

데이터 엔지니어링에서 가장 위험한 것은 "잘못된 데이터가 조용히 대시보드에 올라가는 것"입니다. dbt는 이를 방지하기 위한 강력한 테스트 환경을 제공합니다.

### 1. 범용 테스트 (Generic Tests)

`schema.yml` 또는 `sources.yml`에 설정만 하면 dbt가 자동으로 수행하는 검증입니다.

* **`unique`**: 중복 값 체크
* **`not_null`**: 빈 값(NULL) 체크
* **`accepted_values`**: 지정된 값 리스트에 포함되는지 확인
* **`relationships`**: 참조 무결성 확인

### 2. 단별/단위 테스트 (Singular & Unit Tests)

* **Singular Test**: `tests/` 폴더에 직접 SQL을 작성하여, 쿼리 결과가 **1건이라도 나오면 실패**로 처리합니다.
* **Unit Test**: 가상의 데이터(Fixture)를 넣어 SQL 로직이 수학적으로 맞는지 미리 검증합니다.

---

## 📂 9. dbt Documentation: 자동화된 데이터 설명서

dbt docs는 분석가와 협업하기 위한 **최종 명세서**입니다. YAML 파일에 적힌 설명이 웹 브라우저 화면으로 자동 변환됩니다.

### 1. 소스 및 모델 문서화 코드 예시

**① `models/staging/sources.yml` (원본 데이터 정의)**

```yaml
version: 2

sources:
  - name: raw_data
    description: "Raw data sources for NYC taxi rides"
    database: kestra-sandbox-485208 # Project ID
    schema: zoomcamp                 # Dataset Name
    tables: 
      - name: green_tripdata
        description: Raw green taxi trip data
        columns:
          - name: vendorid
            description: |
              A code indicating the provider associated with the trip record.
                  1: 'Creative Mobile Technologies',
                  2: 'VeriFone Inc.',
                  3: 'Unknown/Other '
            data_type: integer
            meta:
              pii: false
              ownership: data_team
              importance: high
      - name: yellow_tripdata_partitioned
        description: Raw yellow taxi trip data

```

**② `models/schema.yml` (가공된 모델 정의)**

```yaml
version: 2

models:
  - name: dim_vendors
    description: "This table contains vendor information."
    columns:
      - name: vendor_id
        description: "The unique identifier for each vendor."
      - name: vendor_name
        description: "The name of the vendor."
      - name: vendor_address
        description: "The address of the vendor."
      - name: vendor_phone
        description: "The contact phone number for the vendor."
      - name: created_at
        description: "The timestamp when the vendor record was created."
      - name: updated_at
        description: "The timestamp when the vendor record was last updated."

```

### 2. dbt Cloud에서 문서 확인하기

* **명령어**: 터미널에 `dbt docs generate` 입력
* **확인**: IDE 상단 또는 하단 결과창의 **[View Docs]** 버튼 클릭
* **핵심 기능**:
* **Lineage Graph**: 데이터가 소스부터 마트까지 흐르는 계보를 시각화합니다.
* **Compiled SQL**: 실제 BigQuery에서 실행되는 순수 SQL을 확인할 수 있습니다.



---

## 📂 10. dbt Packages: 검증된 라이브러리 활용

직접 복잡한 SQL을 짜지 않고, 전 세계 데이터 엔지니어들이 공유한 패키지를 가져와 생산성을 높입니다.

### 1. 패키지 설치 (`packages.yml`)

프로젝트 루트 폴더에 파일을 만들고 아래 내용을 작성합니다.

```yaml
packages:
  - package: dbt-labs/dbt_utils
    version: 1.3.3

```

* **설치 명령어**: `dbt deps`
* **결과**: `packages-lock.yml` 파일이 생성되며 패키지 의존성이 고정됩니다.

### 2. 패키지 활용 예시: `dbt_utils`를 이용한 고도화

`int_trips.sql` 모델에서 패키지를 활용해 PK 생성(Surrogate Key) 및 데이터 풍부화를 수행하는 코드입니다.

```sql
-- Enrich and deduplicate trip data
-- Demonstrates enrichment and surrogate key generation

with unioned as (
    select * from {{ ref('int_trips_unioned') }}
),

payment_types as (
    select * from {{ ref('payment_type_lookup') }}
),

cleaned_and_enriched as (
    select
        -- 1. dbt_utils 패키지로 고유 Surrogate Key 생성 (MD5 해싱 자동화)
        {{ dbt_utils.generate_surrogate_key(['u.vendor_id', 'u.pickup_datetime', 'u.pickup_location_id', 'u.service_type']) }} as trip_id,

        -- Identifiers
        u.vendor_id,
        u.service_type,
        u.rate_code_id,

        -- Location IDs
        u.pickup_location_id,
        u.dropoff_location_id,

        -- Timestamps
        u.pickup_datetime,
        u.dropoff_datetime,

        -- Trip details
        u.store_and_fwd_flag,
        u.passenger_count,
        u.trip_distance,
        u.trip_type,

        -- Payment breakdown
        u.fare_amount,
        u.extra,
        u.mta_tax,
        u.tip_amount,
        u.tolls_amount,
        u.ehail_fee,
        u.improvement_surcharge,
        u.total_amount,

        -- 2. 외부 테이블과 Join하여 정보 풍부화
        coalesce(u.payment_type, 0) as payment_type,
        coalesce(pt.description, 'Unknown') as payment_type_description

    from unioned u
    left join payment_types pt
        on coalesce(u.payment_type, 0) = pt.payment_type
)

select * from cleaned_and_enriched

-- 3. 중복 데이터 제거 (Deduplication)
qualify row_number() over(
    partition by vendor_id, pickup_datetime, pickup_location_id, service_type
    order by dropoff_datetime
) = 1

```

---

## 💡 종합 요약

| 단계 | 역할 | 핵심 도구 |
| --- | --- | --- |
| **테스트 (Test)** | 데이터 무결성 및 품질 보증 | `schema.yml`, `tests/` |
| **문서화 (Docs)** | 협업을 위한 데이터 명세서/지도 생성 | `dbt docs generate`, Lineage |
| **패키지 (Package)** | 표준화된 로직 재사용 (PK 생성 등) | `dbt_utils`, `dbt deps` |


---

## 📂 11. dbt Commands & Flags: 효율적인 프로젝트 운영

dbt는 명령어를 통해 데이터 변환의 전 과정을 제어합니다. 각 명령어의 특성을 이해하면 개발 속도와 운영 안정성을 크게 높일 수 있습니다.

### 1. dbt 핵심 명령어 (Commands)

* **`dbt init`**: **프로젝트 초기화**
새로운 dbt 프로젝트를 시작할 때 실행합니다. 모델(models), 테스트(tests), 시드(seeds) 등을 저장할 표준 디렉토리 구조를 자동으로 생성하고 기초 설정을 도와줍니다.
* **`dbt debug`**: **연결 상태 점검**
프로젝트 설정 파일(`dbt_project.yml`)과 데이터베이스 접속 정보(`profiles.yml`)가 올바른지 확인합니다. "왜 연결이 안 되지?" 싶을 때 가장 먼저 입력해야 하는 진단 명령어입니다.
* **`dbt seed`**: **정적 데이터 로드**
`seeds/` 폴더에 저장된 CSV 파일을 데이터베이스의 테이블로 업로드합니다. 주로 국가 코드, 결제 수단 리스트처럼 자주 변하지 않는 참조 데이터를 관리할 때 사용합니다.
* **`dbt run`**: **모델 실행 및 구체화**
작성한 SQL 모델들을 실행하여 실제 데이터베이스에 View나 Table을 생성합니다. dbt의 가장 기본적인 실행 단위입니다.
* **`dbt test`**: **데이터 품질 검증**
YAML에 정의한 데이터 제약 조건(unique, not null 등)과 직접 짠 테스트 쿼리를 실행합니다. 데이터에 결함이 없는지 배포 전 최종적으로 확인하는 단계입니다.
* **`dbt build`**: **올인원 실행 (실무 권장)**
`seed` -> `run` -> `test` -> `snapshot`을 한 번에 실행합니다. 가장 큰 장점은 **의존성 순서대로** 진행하되, 특정 모델에서 테스트가 실패하면 그 모델을 참조하는 하위 모델의 실행을 자동으로 중단시켜 잘못된 데이터 적재를 막아줍니다.
* **`dbt retry`**: **실패 지점부터 재시작**
직전 실행에서 오류가 발생했을 때, 처음부터 다시 돌릴 필요 없이 **실패한 모델부터** 다시 실행합니다. 대규모 프로젝트에서 시간을 획기적으로 아껴줍니다.
* **`dbt compile`**: **SQL 미리보기**
Jinja 문법(`ref`, `source` 등)이 적용된 코드를 실제 DB용 SQL로 변환만 합니다. 실제 데이터를 건드리지 않고 문법 오류가 없는지 빠르게 검토하고 싶을 때 유용합니다.
* **`dbt clean`**: **임시 파일 삭제**
컴파일 결과가 담긴 `target/` 폴더와 설치된 패키지 파일을 삭제합니다. 설정 변경 후 이전 결과물이 꼬여서 예상치 못한 에러가 날 때 깨끗이 비우는 용도로 씁니다.

---

### 2. 주요 플래그 및 옵션 (Flags)

명령어 뒤에 붙여 세부적인 동작을 제어하는 옵션들입니다.

* **`--full-refresh`**: **완전 새로고침**
증분(Incremental) 모델은 보통 변경된 데이터만 추가하지만, 이 옵션을 주면 기존 데이터를 다 지우고 처음부터 다시 빌드합니다. 테이블 구조를 변경했거나 과거 데이터를 대폭 수정했을 때 필수입니다.
* **`-s` 또는 `--select**`: **특정 모델 선택**
전체 프로젝트가 아닌 원하는 부분만 실행합니다.
* `dbt run -s my_model`: 딱 해당 모델만 실행
* `dbt run -s +my_model`: 해당 모델과 그 **앞단(상위)** 모델들을 모두 실행
* `dbt run -s my_model+`: 해당 모델과 그 **뒷단(하위)** 모델들을 모두 실행


* **`-t` 또는 `--target**`: **실행 환경 지정**
개발 환경(`dev`)에서 테스트할지, 실제 운영 환경(`prod`)에 반영할지 결정합니다. 환경에 따라 데이터베이스 위치나 권한을 다르게 적용할 수 있습니다.
* **`--fail-fast`**: **즉시 중단**
빌드나 테스트 중 단 하나의 에러라도 발견되는 즉시 전체 프로세스를 멈춥니다. 수백 개의 모델을 돌릴 때 초반에 에러가 났다면 끝까지 기다릴 필요 없이 바로 수정할 수 있게 해줍니다.
* **`state:modified`**: **변경된 모델만 실행**
이전 빌드 상태와 비교하여 **수정된 파일만** 찾아내어 빌드합니다. dbt Cloud 배포 환경에서 실행 시간을 단축하기 위해 아주 많이 활용되는 고급 옵션입니다.

---

### 3. 기타 도구

* **`dbt deps`**: `packages.yml`에 작성된 외부 패키지(`dbt-utils` 등)를 다운로드하여 내 프로젝트에 장착합니다.
* **`dbt docs generate`**: 프로젝트의 모든 메타데이터를 분석하여 웹 기반의 문서 사이트 데이터를 생성합니다.

---

## 📂 12. 실전 프로젝트: NYC FHV 데이터 파이프라인 구축 사례

GitHub의 원본 데이터를 GCS로 적재하고, BigQuery와 dbt를 활용하여 분석용 스테이징 테이블을 생성하는 **ELT(Extract-Load-Transform)** 전체 공정 기록입니다.

### 1단계: 데이터 수집 및 GCS 적재 (Extract & Load)

Cloud Shell에서 `curl`과 `gsutil`을 사용하여 외부 소스 데이터를 내 컴퓨터를 거치지 않고 GCS 버킷으로 직접 전송했습니다.

* **Cloud Shell 실행 명령어:**
```bash
# 1. 환경 변수 설정
export BUCKET_NAME="jaehyun-dataeng-kestra-bucket"

# 2. 2019년 1월~12월 데이터 반복 전송 (누락 시 특정 달만 지정 가능)
for month in {01..12}; do
  URL="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/fhv/fhv_tripdata_2019-${month}.csv.gz"
  echo "전송 중: 2019-${month} ..."
  curl -L $URL | gsutil cp - gs://${BUCKET_NAME}/raw/fhv/fhv_tripdata_2019-${month}.csv.gz
done

```



### 2단계: BigQuery 외부 테이블 생성 (Raw Layer)

GCS에 저장된 `.csv.gz` 파일들을 물리적 복사 없이 BigQuery에서 즉시 조회 가능하도록 연결했습니다.

* **BigQuery 외부 테이블 생성 쿼리:**
```sql
CREATE OR REPLACE EXTERNAL TABLE `kestra-sandbox-485208.zoomcamp.stg_fhv_tripdata_ext`
(
  dispatching_base_num STRING,
  pickup_datetime TIMESTAMP,
  dropoff_datetime TIMESTAMP,
  PULocationID STRING,
  DOLocationID STRING,
  SR_Flag STRING,
  Affiliated_base_number STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://jaehyun-dataeng-kestra-bucket/raw/fhv/fhv_tripdata_2019-*.csv.gz'],
  skip_leading_rows = 1
);

```



### 3단계: dbt 환경 설정 및 모델링 (Transform Layer)

dbt를 사용하여 소스 데이터를 정의하고, 비즈니스 로직(필터링 및 타입 변환)을 적용했습니다.

* **`models/staging/sources.yml` 설정:**
```yaml
version: 2
sources:
  - name: raw_data
    database: kestra-sandbox-485208
    schema: zoomcamp
    tables: 
      - name: green_tripdata
      - name: yellow_tripdata_partitioned
      - name: stg_fhv_tripdata_ext   # 생성한 외부 테이블 연결

```


* **`models/staging/stg_fhv_tripdata.sql` 개발:**
```sql
{{ config(materialized='view') }}

select 
    CAST(dispatching_base_num as string) as dispatching_base_num,
    CAST(pickup_datetime as timestamp) as pickup_datetime,
    CAST(dropOff_datetime as timestamp) as dropoff_datetime,
    CAST(PUlocationID as integer) as pickup_location_id,
    CAST(DOlocationID as integer) as dropoff_location_id,
    CAST(SR_Flag as string) as sr_flag,
    CAST(Affiliated_base_number as string) as affiliated_base_number
from {{ source('raw_data', 'stg_fhv_tripdata_ext') }}
where dispatching_base_num IS NOT NULL  -- 유효 데이터 필터링

```



### 4단계: 실행 및 최종 검증

최종적으로 dbt 모델을 빌드하고 데이터 정합성을 확인했습니다.

* **실행 명령어:** `dbt run -s stg_fhv_tripdata`
* **검증 결과:** BigQuery에서 카운트 쿼리 실행 시 총 **43,244,693** 건 확인 (2019년 전체 데이터 적재 성공)

---


## 📂 13. dbt 도입 전후 비교: 파이프라인의 진화 (Before & After)

데이터 오케스트레이터(Kestra)만 사용하던 **'전통적 방식'**에서 변환 전문 도구(dbt)를 결합한 **'현대적 방식'**으로의 전환 과정을 상세히 비교 분석합니다.

---

### 1️⃣ 아키텍처의 변화: "관심사의 분리"

과거에는 Kestra라는 하나의 도구가 모든 책임을 졌다면, 현재는 각 도구가 가장 잘하는 일에 집중합니다.

* **[Before] Kestra 중심 (Monolithic)**: 파일 전송, GCS 업로드, 스키마 정의, 데이터 정제(SQL)를 하나의 YAML 파일에서 처리. 코드가 길어지고 유지보수가 매우 어려움.
* **[After] Kestra + dbt (Modular)**:
* **Kestra**: 데이터 수집 및 적재(Inbound)와 스케줄링 총괄.
* **dbt**: 적재된 데이터를 분석 가능한 형태로 변환(Transformation)하고 품질 테스트 및 문서화 전담.



---

### 2️⃣ 코드 레벨 비교: "노가다 SQL" vs "데이터 모델링"

실제 Yellow/Green 택시 코드(과거)와 FHV 택시 코드(현재)를 통해 코드의 질적 변화를 체감할 수 있습니다.

#### ❌ [과거] 수동 조립 방식 (Manual Raw SQL)

테이블 하나를 만들 때마다 수백 줄의 **DDL(정의)**과 **DML(조작)**을 직접 작성해야 했습니다.

```sql
-- 1. 지루한 스키마 정의 (수십 개의 컬럼 타입 직접 지정)
CREATE TABLE IF NOT EXISTS `project.dataset.yellow_tripdata` (
    VendorID STRING,
    tpep_pickup_datetime TIMESTAMP,
    ... -- (중략) --
    congestion_surcharge NUMERIC
);

-- 2. 복잡한 중복 제거 로직 (해시 생성)
MD5(CONCAT(COALESCE(CAST(VendorID AS STRING), ""), ...))

-- 3. 고난도 병합 로직 (MERGE 문 직접 작성)
MERGE INTO `target_table` T 
USING `source_table` S ON T.id = S.id
WHEN NOT MATCHED THEN INSERT (...) VALUES (...);

```

> **문제점**: "어떻게(How)" 데이터를 넣을지에만 집중하느라 정작 데이터의 비즈니스 의미를 파악하기 힘듦.

#### ✅ [현재] 설계도 기반 방식 (dbt Declarative SQL)

dbt가 모든 인프라 제어(Create, Merge 등)를 대신하므로, 개발자는 **핵심 비즈니스 로직**에만 집중합니다.

```sql
{{ config(materialized='view') }}

SELECT 
    CAST(dispatching_base_num AS STRING) AS dispatching_base_num,
    CAST(pickup_datetime AS TIMESTAMP) AS pickup_datetime,
    ...
FROM {{ source('raw_data', 'stg_fhv_tripdata_ext') }}
WHERE dispatching_base_num IS NOT NULL -- 숙제 핵심 조건

```

> **개선점**: "무엇을(What)" 변환할지만 명시. 나머지는 dbt가 환경(Dev/Prod)에 맞춰 자동으로 SQL을 생성함.

---

### 3️⃣ 주요 변화 및 영향도 (Impact Analysis)

| 비교 항목 | dbt 도입 전 (Only Kestra) | dbt 도입 후 (With dbt) | 영향 및 효과 |
| --- | --- | --- | --- |
| **코드 가독성** | 수백 줄의 스파게티 코드 | 10~20줄 내외의 클린 코드 | **유지보수 시간 80% 단축** |
| **데이터 신뢰도** | 수동 쿼리로 육안 확인 | `dbt test` 통한 자동 검증 | **데이터 품질 보장** |
| **운영 방식** | Kestra UI에서 직접 수정 | Git에 Push하면 자동 반영 | **Git-Ops 기반의 협업** 가능 |
| **문서화** | 별도 문서 없으면 파악 불가 | `dbt docs`로 계보 자동 생성 | **데이터 거버넌스** 확립 |

---

### 4️⃣ 기술적 성장의 결론: "엔지니어링의 추상화"

* **생산성 극대화**: 과거 Yellow Taxi 워크플로우를 짤 때 들었던 시간의 1/10만으로도 FHV 파이프라인을 구축.
* **안정성 확보**: `MERGE` 문 실수로 데이터를 날려먹을 걱정 없이, dbt가 검증한 최적의 패턴으로 데이터를 적재합니다.
* **확장성**: 이제 데이터 종류가 100개로 늘어나도 dbt의 **모듈화(Ref, Source)** 기능을 통해 일관된 품질로 관리.

---
