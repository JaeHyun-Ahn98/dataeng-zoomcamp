# Module 3 Homework

**주의사항:** 제출 양식의 마지막에는 GitHub 저장소 또는 기타 공개 코드 호스팅 사이트에 대한 링크를 포함해야 합니다. 이 저장소에는 과제를 해결하기 위한 코드가 포함되어야 합니다. 파일 형식이 아닌 코드(SQL 쿼리 또는 셸 명령 등)가 포함된 경우 저장소의 README 파일에 직접 포함하세요.

---

## 중요 사항:

이번 과제에서는 2024년 1월부터 6월까지의 Yellow Taxi Trip Records 데이터를 사용합니다. 뉴욕시 택시 데이터 페이지(https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page)에서 제공되는 전체 연도 데이터가 아닌 Parquet 파일을 사용해야 합니다.

오케스트레이션 도구(Kestra, Mage, Airflow, Prefect 등)를 사용하는 경우 데이터를 BigQuery에 로드하지 마세요. 파일을 GCS 버킷에 로드하는 것으로 멈추세요.

### 로드 스크립트:
Parquet 파일을 수동으로 다운로드하여 GCS 버킷에 업로드하거나, 아래 링크된 스크립트를 사용할 수 있습니다:
- GCS Admin 권한이 있는 서비스 계정을 생성하거나 Google SDK로 인증을 완료한 후 스크립트에서 버킷 이름을 자신의 버킷 이름으로 업데이트하세요.
- 모든 6개의 파일이 GCS 버킷에 있는지 확인하세요.

**참고:** 외부 테이블을 생성할 때는 PARQUET 옵션 파일을 사용해야 합니다.

---

## BigQuery 설정:

1. Yellow Taxi Trip Records를 사용하여 외부 테이블을 생성하세요.
2. Yellow Taxi Trip Records를 사용하여 (정규/머티리얼라이즈드) 테이블을 생성하세요. (이 테이블은 파티셔닝 또는 클러스터링하지 마세요.)

---

## 질문과 답변

### 질문 1:
2024년 Yellow Taxi 데이터의 레코드 수는 얼마입니까?
- 65,623
- 840,402
- 20,332,093 ✅
- 85,431,289

```sql
SELECT COUNT(*)
FROM zoomcamp.external_yellow_tripdata_2024;
```

### 질문 2:
두 테이블에서 전체 데이터셋에 대해 PULocationID의 고유 개수를 세는 쿼리를 작성하세요. 이 쿼리를 외부 테이블과 정규 테이블에서 실행했을 때 읽히는 데이터의 예상 크기는 얼마입니까?
- 외부 테이블: 18.82 MB, 정규 테이블: 47.60 MB
- 외부 테이블: 0 MB, 정규 테이블: 155.12 MB ✅
- 외부 테이블: 2.14 GB, 정규 테이블: 0 MB
- 외부 테이블: 0 MB, 정규 테이블: 0 MB

```sql
SELECT COUNT(DISTINCT PULocationID) FROM `kestra-sandbox-485208.zoomcamp.external_yellow_tripdata_2024`;

SELECT COUNT(DISTINCT PULocationID) FROM `kestra-sandbox-485208.zoomcamp.yellow_tripdata_partitioned_clustered`;
```

### 질문 3:
BigQuery 테이블(외부 테이블 아님)에서 PULocationID를 검색하는 쿼리를 작성하세요. 그런 다음 동일한 테이블에서 PULocationID와 DOLocationID를 검색하는 쿼리를 작성하세요. 두 쿼리의 예상 바이트 수가 다른 이유는 무엇입니까?
- BigQuery는 열 지향 데이터베이스로, 쿼리에서 요청된 특정 열만 스캔합니다. 따라서 두 열(PULocationID, DOLocationID)을 쿼리하면 한 열(PULocationID)만 쿼리할 때보다 더 많은 데이터를 읽어야 하므로 예상 바이트 수가 증가합니다. ✅
- BigQuery는 데이터를 여러 스토리지 파티션에 중복 저장하므로 두 열을 선택하면 테이블을 두 번 스캔해야 하며, 예상 바이트 수가 두 배로 증가합니다.
- BigQuery는 첫 번째 쿼리된 열을 자동으로 캐시하므로 두 번째 열을 추가하면 처리 시간이 증가하지만 예상 바이트 수에는 영향을 미치지 않습니다.
- 여러 열을 선택하면 BigQuery가 암묵적으로 열 간 조인 작업을 수행하므로 예상 바이트 수가 증가합니다.

### 질문 4:
fare_amount가 0인 레코드는 몇 개입니까?
- 128,210
- 546,578
- 20,188,016
- 8,333 ✅

```sql
SELECT COUNT(*) FROM `kestra-sandbox-485208.zoomcamp.yellow_tripdata_non_partitioned`
WHERE fare_amount = 0;
```

### 질문 5:
쿼리가 항상 tpep_dropoff_datetime을 기준으로 필터링되고 결과를 VendorID로 정렬하는 경우 BigQuery에서 최적화된 테이블을 만드는 가장 좋은 전략은 무엇입니까?
- tpep_dropoff_datetime으로 파티셔닝하고 VendorID로 클러스터링합니다. ✅
- tpep_dropoff_datetime으로 클러스터링하고 VendorID로 클러스터링합니다.
- tpep_dropoff_datetime으로 클러스터링하고 VendorID로 파티셔닝합니다.
- tpep_dropoff_datetime으로 파티셔닝하고 VendorID로 파티셔닝합니다.

### 질문 6:
2024-03-01부터 2024-03-15(포함)까지 tpep_dropoff_datetime 사이의 고유 VendorID를 검색하는 쿼리를 작성하세요.

머티리얼라이즈드 테이블을 사용하여 쿼리를 실행하고 예상 바이트를 기록하세요. 그런 다음 질문 5에서 생성한 파티셔닝된 테이블을 사용하여 쿼리를 실행하고 예상 바이트를 기록하세요. 예상 값은 무엇입니까?
- 비파티셔닝 테이블: 12.47 MB, 파티셔닝 테이블: 326.42 MB
- 비파티셔닝 테이블: 310.24 MB, 파티셔닝 테이블: 26.84 MB ✅
- 비파티셔닝 테이블: 5.87 MB, 파티셔닝 테이블: 0 MB
- 비파티셔닝 테이블: 310.31 MB, 파티셔닝 테이블: 285.64 MB

```sql
SELECT DISTINCT(VendorID)
FROM kestra-sandbox-485208.zoomcamp.yellow_tripdata_partitioned_clustered
WHERE tpep_dropoff_datetime BETWEEN '2024-03-01' AND '2024-03-15';

SELECT DISTINCT(VendorID)
FROM kestra-sandbox-485208.zoomcamp.yellow_tripdata_non_partitioned
WHERE tpep_dropoff_datetime BETWEEN '2024-03-01' AND '2024-03-15';
```

### 질문 7:
생성한 외부 테이블의 데이터는 어디에 저장됩니까?
- BigQuery
- Container Registry
- GCP Bucket ✅
- Big Table

### 질문 8:
BigQuery에서 데이터를 항상 클러스터링하는 것이 최선의 방법입니까?
- True
- False ✅

### (보너스) 질문 9:
머티리얼라이즈드 테이블에서 `SELECT count(*)` 쿼리를 작성하세요. 읽히는 바이트 수는 얼마로 예상됩니까? 이유는 무엇입니까?

```sql
SELECT COUNT(*)
FROM kestra-sandbox-485208.zoomcamp.yellow_tripdata_non_partitioned;
```

BigQuery는 테이블에 데이터가 들어올 때마다 "이 테이블의 총 행(Row) 수는 몇 개다"라는 정보를 별도의 '메타데이터 저장소'에 자동으로 기록해두기 때문에 데이터 스캔이 불필요하다. 그로 인해 0바이트라는 예상치가 나온다.

---

## 제출 방법:
제출 양식: https://courses.datatalks.club/de-zoomcamp-2026/homework/hw3

---

## 학습 공유하기:

### LinkedIn 예시 게시물:
🚀 Data Engineering Zoomcamp 3주차 완료! @DataTalksClub

Module 3 - BigQuery와 데이터 웨어하우징을 학습했습니다:

✅ GCS 버킷 데이터로 외부 테이블 생성
✅ BigQuery에서 머티리얼라이즈드 테이블 생성
✅ 성능을 위한 테이블 파티셔닝 및 클러스터링
✅ 열 지향 스토리지 및 쿼리 최적화 이해
✅ NYC 택시 데이터를 대규모로 분석

20M+ 레코드를 다루며 파티셔닝이 쿼리 비용을 줄이는 방법을 배웠습니다!

제 과제 솔루션: <링크>

이 놀라운 무료 강의를 따라가고 있습니다. 데이터 엔지니어링을 배우는 다른 분들도 있나요?

강의 등록: https://github.com/DataTalksClub/data-engineering-zoomcamp/

### Twitter/X 예시 게시물:
📊 Data Engineering Zoomcamp 3주차 완료!

- BigQuery & GCS
- 외부 vs 머티리얼라이즈드 테이블
- 파티셔닝 & 클러스터링
- 쿼리 최적화

제 솔루션: <링크>

무료 강의: @DataTalksClub https://github.com/DataTalksClub/data-engineering-zoomcamp/