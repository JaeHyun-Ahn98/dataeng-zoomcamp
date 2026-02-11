데이터 엔지니어링 줌캠프(DE Zoomcamp)의 **모듈 4: dbt를 활용한 분석 엔지니어링** 숙제 내용이군요! 공부하신 내용을 바탕으로 문제를 풀 수 있도록 깔끔하게 한글로 번역해 드립니다.

---

# 모듈 4 숙제: dbt를 활용한 분석 엔지니어링 (Analytics Engineering)

이번 숙제에서는 `04-analytics-engineering/taxi_rides_ny/` 폴더에 있는 dbt 프로젝트를 사용하여 NYC 택시 데이터를 변환하고, 생성된 모델을 쿼리하여 질문에 답하게 됩니다.

## 설정 (Setup)

1. [설정 가이드](https://www.google.com/search?q=../../../04-analytics-engineering/setup/)에 따라 dbt 프로젝트를 설정하세요.
2. 2019~2020년도의 Green 및 Yellow 택시 데이터를 데이터 웨어하우스(BigQuery 등)에 로드하세요.
3. `dbt build --target prod` 명령어를 실행하여 모든 모델을 생성하고 테스트를 수행하세요.

> **참고:** dbt는 기본적으로 `dev` 타겟을 사용합니다. 아래 숙제 쿼리를 수행하려면 반드시 `--target prod`를 사용하여 프로덕션 데이터셋에 모델을 빌드해야 합니다.

성공적으로 빌드되면 웨어하우스에 `fct_trips`, `dim_zones`, `fct_monthly_zone_revenue`와 같은 모델들이 생성되어야 합니다.

---

### 질문 1. dbt 계보(Lineage)와 실행

다음과 같은 구조의 dbt 프로젝트가 있다고 가정해 봅시다:

```
models/
├── staging/
│   ├── stg_green_tripdata.sql
│   └── stg_yellow_tripdata.sql
└── intermediate/
    └── int_trips_unioned.sql (stg_green 및 stg_yellow에 의존함)

```

만약 `dbt run --select int_trips_unioned` 명령어를 실행하면, 어떤 모델이 빌드될까요?

* `stg_green_tripdata`, `stg_yellow_tripdata`, `int_trips_unioned` (상위 의존성 모델들 포함)
* `int_trips_unioned`의 모든 상위(Upstream) 및 하위(Downstream) 의존성 모델들
* **`int_trips_unioned` 만 빌드됨** ✅
* `int_trips_unioned`, `int_trips`, `fct_trips` (하위 의존성 모델들 포함)

---

### 질문 2. dbt 테스트 (dbt Tests)

`schema.yml`에 다음과 같이 공통 테스트(Generic test)를 설정했습니다:

```yaml
columns:
  - name: payment_type
    data_tests:
      - accepted_values:
          arguments:
            values: [1, 2, 3, 4, 5]
            quote: false

```

`fct_trips` 모델은 몇 달 동안 성공적으로 실행되어 왔습니다. 그런데 원천 데이터에 새로운 값인 `6`이 나타났습니다.

이때 `dbt test --select fct_trips`를 실행하면 어떤 일이 발생할까요?

* 모델이 변경되지 않았으므로 dbt가 테스트를 건너뛴다.
* **dbt가 테스트에 실패하고, 0이 아닌 종료 코드(non-zero exit code)를 반환한다.** ✅
* 새로운 값에 대한 경고(Warning)와 함께 테스트를 통과시킨다.
* dbt가 새 값을 포함하도록 설정을 자동으로 업데이트한다.

---

### 질문 3. `fct_monthly_zone_revenue` 레코드 수 확인

dbt 프로젝트를 실행한 후, `fct_monthly_zone_revenue` 모델을 쿼리하세요.

이 모델의 전체 레코드(행) 수는 얼마입니까?

* 12,998
* 14,120
* 12,184
* 15,421

---

### 질문 4. 2020년 Green 택시 수익 최고 지역

`fct_monthly_zone_revenue` 테이블을 사용하여, **2020년 Green 택시** 운행 중 **총 수익**(`revenue_monthly_total_amount`)이 가장 높은 승차 지역(Pickup Zone)을 찾으세요.

어느 지역의 수익이 가장 높았나요?

* East Harlem North
* Morningside Heights
* East Harlem South
* Washington Heights South

---

### 질문 5. 2019년 10월 Green 택시 총 운행 횟수

`fct_monthly_zone_revenue` 테이블을 사용하여, **2019년 10월** Green 택시의 **총 운행 횟수**(`total_monthly_trips`)는 얼마입니까?

* 500,234
* 350,891
* 384,624
* 421,509

---

### 질문 6. FHV 데이터를 위한 Staging 모델 구축

2019년 **FHV(For-Hire Vehicle, 우버/리프트 등)** 운행 데이터를 위한 스테이징 모델을 만드세요.

1. [2019년 FHV 데이터](https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/fhv)를 데이터 웨어하우스에 로드하세요.
2. 다음 요구사항에 따라 스테이징 모델 `stg_fhv_tripdata`를 생성하세요:
* `dispatching_base_num`이 `NULL`인 레코드는 제외합니다.
* 필드 이름을 프로젝트 명명 규칙에 맞게 변경합니다. (예: `PUlocationID` → `pickup_location_id`)



`stg_fhv_tripdata` 모델의 전체 레코드 수는 얼마입니까?

* 42,084,899
* 43,244,693
* 22,998,722
* 44,112,187

---

## 솔루션 제출 방법

* 제출 양식: [https://courses.datatalks.club/de-zoomcamp-2026/homework/hw4](https://courses.datatalks.club/de-zoomcamp-2026/homework/hw4)

---

**도움말:** * **질문 1**의 경우, 오늘 배우신 **플래그(Flags)** 중 `-s` 옵션이 모델 하나만 선택하는지, 아니면 연관된 것까지 다 선택하는지를 묻는 문제입니다. (힌트: `+` 기호가 있는지 보세요!)

* **질문 2**는 dbt **테스트**가 데이터 품질 위반을 발견했을 때 어떻게 반응하는지에 대한 내용입니다.

공부하신 내용으로 충분히 푸실 수 있을 거예요! 화이팅입니다! 🚀😃