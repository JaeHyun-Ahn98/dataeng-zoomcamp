/* @bruin
name: staging.trips
type: bq.sql

depends:
  - ingestion.trips
  - ingestion.payment_lookup

materialization:
  type: table

columns:
  - name: pickup_datetime
    type: timestamp
    description: "Timestamp when the meter was engaged"
    primary_key: true
    checks:
      - name: not_null
  - name: dropoff_datetime
    type: timestamp
    description: "Timestamp when the meter was disengaged"
    primary_key: true
  - name: pickup_location_id
    type: integer
    description: "TLC Taxi Zone where the meter was engaged"
    primary_key: true
  - name: dropoff_location_id
    type: integer
    description: "TLC Taxi Zone where the meter was disengaged"
    primary_key: true
  - name: fare_amount
    type: double
    description: "The time-and-distance fare calculated by the meter"
    primary_key: true
    checks:
      - name: non_negative
  - name: taxi_type
    type: string
    checks:
      - name: not_null
      - name: accepted_values
        value: ['yellow', 'green']
  - name: payment_type_name
    type: string
    description: "Payment method name from lookup"
  - name: passenger_count
    type: integer
    description: "Number of passengers in the vehicle"
  - name: trip_distance
    type: double
    description: "Trip distance in miles"
    checks:
      - name: non_negative
  - name: total_amount
    type: double
    description: "Total amount charged to passengers"
    checks:
      - name: non_negative

custom_checks:
  - name: row_count_positive
    description: "Ensures the table is not empty"
    query: "SELECT COUNT(*) > 0 FROM staging.trips"
    value: 1
@bruin */

-- 3. 소스 데이터 정리 CTE (이미지 3 참고)
-- 1. 소스 데이터 및 기본 필터링 (영상 이미지의 테이블 직접 참조 방식)
WITH source_data AS (
    SELECT
        tpep_pickup_datetime AS pickup_datetime,
        tpep_dropoff_datetime AS dropoff_datetime,
        pu_location_id AS pickup_location_id,
        do_location_id AS dropoff_location_id,
        taxi_type,
        passenger_count,
        trip_distance,
        payment_type,
        fare_amount,
        extra,
        mta_tax,
        tip_amount,
        tolls_amount,
        improvement_surcharge,
        total_amount,
        extracted_at
    -- ref를 쓰지 않고 직접 테이블 이름을 명시
    FROM ingestion.trips
    WHERE 1=1
      AND tpep_pickup_datetime IS NOT NULL
      AND fare_amount >= 0
      AND total_amount >= 0
),

-- 2. 복합 키를 이용한 중복 제거
deduplicated AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY 
                pickup_datetime, 
                dropoff_datetime, 
                pickup_location_id, 
                dropoff_location_id, 
-- [수정] FLOAT64인 fare_amount를 STRING으로 변환하여 PARTITION BY 허용
                CAST(fare_amount AS STRING)
            ORDER BY extracted_at DESC
        ) AS row_num
    FROM source_data
)

-- 3. 최종 선택 및 결제 정보 조인
SELECT
    d.pickup_datetime,
    d.dropoff_datetime,
    d.pickup_location_id,
    d.dropoff_location_id,
    d.taxi_type,
    d.passenger_count,
    d.trip_distance,
    d.payment_type,
    COALESCE(p.payment_type_name, 'unknown') AS payment_type_name,
    d.fare_amount,
    d.extra,
    d.mta_tax,
    d.tip_amount,
    d.tolls_amount,
    d.improvement_surcharge,
    d.total_amount,
    d.extracted_at
FROM deduplicated d
-- ref를 쓰지 않고 직접 테이블 이름을 명시
LEFT JOIN ingestion.payment_lookup p 
    ON d.payment_type = p.payment_type_id
WHERE d.row_num = 1