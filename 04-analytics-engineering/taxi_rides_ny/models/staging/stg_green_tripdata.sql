select 
    -- identifiers
    CAST(vendorid as int) as vendor_id,
    CAST(ratecodeid as int) as rate_code_id,
    CAST(pulocationid as int) as pickup_location_id,
    CAST(dolocationid as int) as dropoff_location_id,

    -- timestamps
    CAST(lpep_pickup_datetime as timestamp) as pickup_datetime,
    CAST(lpep_dropoff_datetime as timestamp) as dropoff_datetime,

    -- trip info
    store_and_fwd_flag,
    CAST(passenger_count as int) as passenger_count,
    CAST(trip_distance as float64) as trip_distance,
    CAST(trip_type as int) as trip_type,

    -- payment info
    CAST(fare_amount as numeric) as fare_amount,
    CAST(extra as numeric) as extra,
    CAST(mta_tax as numeric) as mta_tax,
    CAST(tip_amount as numeric) as tip_amount,
    CAST(tolls_amount as numeric) as tolls_amount,
    CAST(improvement_surcharge as numeric) as improvement_surcharge,
    CAST(total_amount as numeric) as total_amount,
    CAST(payment_type as int) as payment_type

from {{ source('raw_data', 'green_tripdata') }}
where vendorid is not null