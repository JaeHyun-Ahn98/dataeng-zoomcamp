select 
    -- identifiers
    CAST(vendorid as integer) as vendor_id,
    CAST(ratecodeid as integer) as rate_code_id,
    CAST(pulocationid as integer) as pickup_location_id,
    CAST(dolocationid as integer) as dropoff_location_id,

    -- timestamps
    CAST(lpep_pickup_datetime as timestamp) as pickup_datetime,
    CAST(lpep_dropoff_datetime as timestamp) as dropoff_datetime,

    -- trip info
    CAST(store_and_fwd_flag as string) as store_and_fwd_flag, -- 7번째: 타입 고정
    CAST(passenger_count as integer) as passenger_count,
    CAST(trip_distance as numeric) as trip_distance,
    CAST(trip_type as integer) as trip_type,

    -- payment info
    CAST(fare_amount as numeric) as fare_amount,
    CAST(extra as numeric) as extra,
    CAST(mta_tax as numeric) as mta_tax,
    CAST(tip_amount as numeric) as tip_amount,
    CAST(tolls_amount as numeric) as tolls_amount,
    CAST(ehail_fee as numeric) as ehail_fee,
    CAST(improvement_surcharge as numeric) as improvement_surcharge,
    CAST(total_amount as numeric) as total_amount,
    CAST(payment_type as integer) as payment_type

from {{ source('raw_data', 'green_tripdata') }}
where vendorid is not null