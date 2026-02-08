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

select distinct pickup_location_id from trips_unioned