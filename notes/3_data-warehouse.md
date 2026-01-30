# 🗄️ Data Warehouse (데이터 웨어하우스)

---

## 📚 목차 (Index)

- **OLAP vs OLTP**
- **Data Warehouse란 무엇인가**
- **BigQuery 소개 및 비용**
- **Partitions(파티션)과 Clustering(클러스터링)**
- **Best Practices (권장 사례)**
- **BigQuery ML (머신러닝)**

---

### 1. 📈 OLAP vs OLTP 비교

| 구분 | **OLTP** (Online Transaction Processing) | **OLAP** (Online Analytical Processing) |
| --- | --- | --- |
| **목적** | 실시간 비즈니스 운영 관리 및 트랜잭션 처리 | 계획 수립, 문제 해결, 의사결정 지원, 분석/리포팅 |
| **데이터 업데이트** | 짧고 빈번한 트랜잭션(사용자 주도) | 예약된 대규모 배치 처리(주기적 갱신) |
| **디자인** | 정규화(Normalized) — 저장 효율/무결성 우선 | 비정규화(Denormalized) — 분석 성능/읽기 최적화 |
| **공간** | 비교적 작음(과거 아카이빙 제외) | 대규모 데이터셋—집계/히스토리 보관으로 큼 |
| **사용자** | 고객 접점 앱, 운영 직원 | 데이터 분석가, BI 담당자, 경영진 |

---

### 2. 🧩 Data Warehouse(데이터 웨어하우스)란?

- **OLAP 솔루션**: 분석·리포팅을 목적으로 설계된 시스템입니다.
- **목적**: 대규모 데이터 집계, 복잡한 쿼리, BI 대시보드, 의사결정 지원.

---

### 3. ☁️ BigQuery 개요 및 비용

- **Serverless(서버리스)**: 인프라 관리 불필요 — 설치나 운영 서버 없음.
- **확장성/고가용성**: 자동 스케일링 및 분산 처리 제공.
- **기능**: BigQuery ML, 지리공간(GEOSPATIAL) 분석, BI 통합 기능 등.
- **아키텍처**: Compute(쿼리 엔진)와 Storage(저장소)가 분리된 구조.
- **비용 모델**:
	- **On-demand**: 처리한 스캔량 기준 (예: 1TB당 $5 — 참고용). 
	- **Flat-rate**: 슬롯(slot) 예약 기반 고정 요금(대규모/주기적 쿼리에 유리).

---

### 4. 🧭 Partitioning(파티션) vs Clustering(클러스터링)

- **Partition (파티션)**
	- 시간(날짜/시간) 컬럼, 삽입 시간 또는 정수 범위로 데이터를 분할.
	- 일별/시간별/월별/연별 파티션 설정 가능. (파티션 수 제한 있음 — 예: 최대 4,000)
	- 파티션 컬럼을 쿼리 필터에 사용하면 스캔량(비용) 크게 감소.

- **Clustering (클러스터링)**
	- 지정한 컬럼들로 물리적으로 정렬하여 관련 행을 가깝게 보관.
	- 필터링/집계 쿼리 성능 향상. 최대 4개 컬럼 지정 가능.
	- 파티션으로는 충분치 않은 세분화가 필요할 때 권장.

- **권장 사용법**: 큰 시간 기반 테이블은 파티셔닝 → 자주 필터링/그룹핑하는 컬럼은 클러스터링.

---

### 5. ✅ BigQuery 권장 사례 (Best Practices)

- **비용 절감**:
	- **`SELECT *` 금지** — 필요한 컬럼만 선택 조회.
	- 쿼리 실행 전 예상 스캔량(비용)을 확인.
	- 파티셔닝/클러스터링된 테이블 사용.

- **성능 최적화**:
	- 파티션 컬럼으로 반드시 필터링하여 파티션 프루닝을 유도.
	- 가능한 경우 데이터 비정규화(Denormalize) 및 중첩(Nested)/반복(Repeated) 필드 활용.
	- JOIN 전에 각 테이블을 먼저 필터링하여 데이터 크기를 줄이기.
	- JOIN 순서: 가장 큰(스캔량 많은) 테이블을 먼저 배치하는 것이 유리한 경우가 있음.

- **데이터 설계**:
	- 외부 테이블(External Table)을 활용해 레이크(GCS)의 파일을 직접 쿼리 가능.
	- 증분 로딩 시에는 `MERGE`와 고유 ID(unique_row_id) 전략 사용.

---

### 6. 🤖 BigQuery ML (머신러닝)

- **대상**: 데이터 분석가 및 엔지니어.
- **장점**: SQL 기반으로 모델을 학습/평가/예측 가능 — 별도 Python 환경 없이 사용.
- **비용 및 무료티어**: 매월 제공되는 무료 저장소/쿼리 한도(예: 10GB 저장, 1TB 쿼리 무료 티어 등 — 변경 가능).

---

### 7. 📝 Partitioning의 중요성: 예제 쿼리 분석

아래는 BigQuery에서 파티셔닝과 클러스터링의 중요성을 보여주는 예제 쿼리들입니다. 각 쿼리의 목적과 결과를 간단히 설명합니다.

---

#### 7.1 🚲 CitiBike 데이터 조회
```sql
-- 공개 데이터셋에서 CitiBike 스테이션 정보 조회
SELECT station_id, name FROM
    bigquery-public-data.new_york_citibike.citibike_stations
LIMIT 100;
```
- **설명**: 뉴욕 CitiBike의 스테이션 ID와 이름을 조회합니다. 공개 데이터셋을 활용한 간단한 예제입니다.

---

#### 7.2 🗂️ 외부 테이블 생성
```sql
-- GCS 경로를 참조하는 외부 테이블 생성
CREATE OR REPLACE EXTERNAL TABLE `taxi-rides-ny.nytaxi.external_yellow_tripdata`
OPTIONS (
  format = 'CSV',
  uris = ['gs://nyc-tl-data/trip data/yellow_tripdata_2019-*.csv', 'gs://nyc-tl-data/trip data/yellow_tripdata_2020-*.csv']
);
```
- **설명**: GCS에 저장된 CSV 파일을 참조하는 외부 테이블을 생성합니다. 데이터를 BigQuery로 로드하지 않고도 쿼리할 수 있습니다.

---

#### 7.3 🚖 외부 테이블 데이터 확인
```sql
-- 외부 테이블에서 데이터 샘플 조회
SELECT * FROM taxi-rides-ny.nytaxi.external_yellow_tripdata
LIMIT 10;
```
- **설명**: 외부 테이블의 데이터를 미리 확인하여 스키마와 내용을 검증합니다.

---

#### 7.4 🛠️ 비파티션 테이블 생성
```sql
-- 외부 테이블 데이터를 기반으로 비파티션 테이블 생성
CREATE OR REPLACE TABLE taxi-rides-ny.nytaxi.yellow_tripdata_non_partitioned AS
SELECT * FROM taxi-rides-ny.nytaxi.external_yellow_tripdata;
```
- **설명**: 파티셔닝 없이 데이터를 로드한 테이블입니다. 대규모 데이터 스캔 시 비효율적일 수 있습니다.

---

#### 7.5 📅 파티션 테이블 생성
```sql
-- 외부 테이블 데이터를 기반으로 파티션 테이블 생성
CREATE OR REPLACE TABLE taxi-rides-ny.nytaxi.yellow_tripdata_partitioned
PARTITION BY
  DATE(tpep_pickup_datetime) AS
SELECT * FROM taxi-rides-ny.nytaxi.external_yellow_tripdata;
```
- **설명**: `tpep_pickup_datetime` 컬럼을 기준으로 날짜별 파티션을 생성하여 쿼리 성능을 최적화합니다.

---

#### 7.6 📊 파티션의 성능 비교
```sql
-- 비파티션 테이블: 1.6GB 데이터 스캔
SELECT DISTINCT(VendorID)
FROM taxi-rides-ny.nytaxi.yellow_tripdata_non_partitioned
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2019-06-30';

-- 파티션 테이블: 106MB 데이터 스캔
SELECT DISTINCT(VendorID)
FROM taxi-rides-ny.nytaxi.yellow_tripdata_partitioned
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2019-06-30';
```
- **설명**: 동일한 쿼리 조건에서 비파티션 테이블은 1.6GB를 스캔하지만, 파티션 테이블은 106MB만 스캔하여 비용과 성능이 크게 개선됩니다.

---

#### 7.7 🔍 파티션 정보 확인
```sql
-- 테이블의 파티션 정보 조회
SELECT table_name, partition_id, total_rows
FROM `nytaxi.INFORMATION_SCHEMA.PARTITIONS`
WHERE table_name = 'yellow_tripdata_partitioned'
ORDER BY total_rows DESC;
```
- **설명**: 테이블의 파티션별 데이터 분포를 확인하여 쿼리 최적화를 위한 인사이트를 얻습니다.

---

#### 7.8 🗃️ 파티션 + 클러스터 테이블 생성
```sql
-- 파티션 및 클러스터링 테이블 생성
CREATE OR REPLACE TABLE taxi-rides-ny.nytaxi.yellow_tripdata_partitioned_clustered
PARTITION BY DATE(tpep_pickup_datetime)
CLUSTER BY VendorID AS
SELECT * FROM taxi-rides-ny.nytaxi.external_yellow_tripdata;
```
- **설명**: 파티션과 클러스터링을 결합하여 쿼리 성능을 더욱 향상시킵니다.

---

#### 7.9 🧪 클러스터링 성능 비교
```sql
-- 파티션 테이블: 1.1GB 데이터 스캔
SELECT count(*) as trips
FROM taxi-rides-ny.nytaxi.yellow_tripdata_partitioned
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2020-12-31'
  AND VendorID=1;

-- 파티션+클러스터 테이블: 864.5MB 데이터 스캔
SELECT count(*) as trips
FROM taxi-rides-ny.nytaxi.yellow_tripdata_partitioned_clustered
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2020-12-31'
  AND VendorID=1;
```
- **설명**: 클러스터링을 추가하면 데이터 스캔량이 더 줄어들어 비용과 성능이 개선됩니다.

---

### 8. 🌟 주요 데이터 웨어하우스(DW) 4종 비교

아래는 Google BigQuery를 포함한 주요 데이터 웨어하우스 4종의 특징과 구조를 비교한 내용입니다. 

---

#### 8.1 **데이터 웨어하우스 4종 비교 요약**

| 구분 | **Google BigQuery** | **Snowflake** | **AWS Redshift** | **Azure Synapse** |
| --- | --- | --- | --- | --- |
| **운영 주체** | Google | 독립 기업 (Snowflake) | Amazon | Microsoft |
| **핵심 구조** | **완전 서버리스** (Shared-nothing) | **저장/계산 완전 분리** (Multi-cluster) | **노드 기반** (최근 서버리스 추가) | **SQL 풀 & 스파크 결합** |
| **관리 수준** | 매우 낮음 (Google이 다 해줌) | 낮음 (사양만 선택) | 보통 (노드 관리 필요) | 보통 (설정 다양함) |
| **확장성** | 실시간 자동 확장 | 즉각적인 수평 확장 | 수동 또는 시간 소요 | 수동/자동 선택 가능 |
| **과금 방식** | 데이터 스캔량 또는 슬롯 점유 | 컴퓨팅 시간(Credit) | 인스턴스 시간(Node) | 처리된 데이터량 또는 시간 |

---

#### 8.2 **서비스별 상세 특징 및 구조**

##### **① Google BigQuery (GCP)**

- **구조 (Serverless)**: 사용자가 인프라를 전혀 관리하지 않습니다. 구글의 거대한 컴퓨팅 자원(Dremel 엔진)을 필요한 만큼 빌려 쓰는 구조입니다.
- **저장 방식 (Capacitor)**: 독자적인 열 기반 저장 방식을 사용하여 분석 속도가 매우 빠릅니다.
- **특징**:
  - **SQL 기반 ML**: SQL만으로 머신러닝 모델을 만들 수 있는 'BigQuery ML' 기능이 강력합니다.
  - **강점**: 데이터가 갑자기 수만 배로 늘어나도 사용자가 아무런 설정을 할 필요가 없습니다.

##### **② Snowflake (독립형)**

- **구조 (Multi-cluster Shared Data)**: '데이터 저장소'는 하나지만, 그 위에 '계산기(Virtual Warehouse)'를 여러 개 붙일 수 있습니다.
  - *예: 마케팅팀 전용 계산기, 개발팀 전용 계산기를 따로 두어 서로 성능 간섭이 없게 함.*
- **특징**:
  - **멀티 클라우드**: AWS, Azure, GCP 어디서든 실행 가능하여 클라우드 종속성이 없습니다.
  - **타임 트래블**: 과거 특정 시점의 데이터로 즉시 되돌리는 기능이 매우 강력합니다.

##### **③ Amazon Redshift (AWS)**

- **구조 (Cluster-based)**: 리더 노드와 여러 개의 컴퓨팅 노드로 구성됩니다. 전통적인 DB와 비슷하게 사용자가 서버(노드)의 사양과 개수를 직접 정합니다.
- **특징**:
  - **RA3 노드**: 최근에는 빅쿼리처럼 저장과 계산을 분리한 RA3 타입을 통해 성능을 보완했습니다.
  - **강점**: 전 세계에서 가장 많이 쓰는 AWS 생태계(S3, Lambda 등)와 연동이 가장 매끄럽습니다.

##### **④ Azure Synapse Analytics (Microsoft)**

- **구조 (Unified Analytics)**: 과거의 SQL DW가 진화한 형태로, SQL 분석뿐만 아니라 Apache Spark, 데이터 통합(ETL)까지 한 곳에 모아둔 올인원 플랫폼입니다.
- **특징**:
  - **MS 생태계**: Power BI, Excel, Active Directory(보안) 등 MS 제품을 쓰는 기업에 최적입니다.
  - **하이브리드**: 서버리스 모델과 전용 자원 할당 모델을 섞어서 사용할 수 있습니다.

---

#### 8.3 **핵심 아키텍처 공통점 **

1. **Columnar Storage (열 기반 저장)**: 행(Row)이 아닌 열(Column) 단위로 데이터를 저장하여 필요한 데이터만 읽어 비용과 시간을 절약합니다.
2. **MPP (Massively Parallel Processing)**: 수천 대의 서버가 하나의 쿼리를 나누어 동시에 처리하는 병렬 분산 시스템입니다.
3. **Separation of Storage and Compute**: 데이터를 보관하는 곳과 계산하는 곳을 분리하여, 데이터가 늘어나도 컴퓨터 성능을 무리하게 올릴 필요가 없게 설계되었습니다.

---




