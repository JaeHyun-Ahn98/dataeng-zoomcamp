with trips_unioned as (
    select * from {{ ref('int_trips_unioned') }}
), 
taxi_zone_lookup as (
    select * from {{ ref('taxi_zone_lookup') }}
)
select 
    -- 1. 직접 만든 PK
    to_hex(md5(cast(concat(coalesce(cast(t.vendor_id as string), ''), '-', coalesce(cast(t.pickup_datetime as string), '')) as string))) as tripid,
    
    -- 2. 매크로 적용
    {{ get_payment_type_description('t.payment_type') }} as payment_type_description,
    
    -- 3. 장소 정보 (JOIN 결과)
    pickup_zone.borough as pickup_borough, 
    pickup_zone.zone as pickup_zone, 
    dropoff_zone.borough as dropoff_borough, 
    dropoff_zone.zone as dropoff_zone,
    
    -- 4. 나머지 필요한 컬럼들
    t.pickup_datetime,
    t.dropoff_datetime,
    t.fare_amount,
    t.total_amount

from trips_unioned t
-- 승차지 정보 합치기
inner join taxi_zone_lookup as pickup_zone
    on t.pickup_location_id = pickup_zone.locationid
-- 하차지 정보 합치기
inner join taxi_zone_lookup as dropoff_zone
    on t.dropoff_location_id = dropoff_zone.locationid