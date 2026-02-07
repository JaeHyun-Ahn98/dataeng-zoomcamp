select 
    -- identifiers
    CAST(vendorid as integer) as vendor_id,
    CAST(ratecodeid as integer) as rate_code_id,
    CAST(pulocationid as integer) as pickup_location_id,
    CAST(dolocationid as integer) as dropoff_location_id,

    -- timestamps
    CAST(tpep_pickup_datetime as timestamp) as pickup_datetime,
    CAST(tpep_dropoff_datetime as timestamp) as dropoff_datetime,

    -- trip info
    CAST(store_and_fwd_flag as string) as store_and_fwd_flag, -- 7번째: 타입 고정
    CAST(passenger_count as integer) as passenger_count,
    CAST(trip_distance as numeric) as trip_distance,
    1 as trip_type,  -- yello taxis can only be street-hail (trip_type = 1)

    -- payment info
    CAST(fare_amount as numeric) as fare_amount,
    CAST(extra as numeric) as extra,
    CAST(mta_tax as numeric) as mta_tax,
    CAST(tip_amount as numeric) as tip_amount,
    CAST(tolls_amount as numeric) as tolls_amount,
    CAST(improvement_surcharge as numeric) as improvement_surcharge,
    0 as ehail_fee, -- yellow taxis do not have ehail fees
    CAST(total_amount as numeric) as total_amount,
    CAST(payment_type as integer) as payment_type

from {{ source('raw_data', 'yellow_tripdata_partitioned') }}
where vendorid is not null