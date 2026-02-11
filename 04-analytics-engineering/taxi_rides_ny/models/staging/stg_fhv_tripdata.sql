select 
    -- identifiers
    CAST(dispatching_base_num as string) as dispatching_base_num,
    CAST(pickup_datetime as timestamp) as pickup_datetime,
    CAST(dropOff_datetime as timestamp) as dropoff_datetime,
    CAST(PUlocationID as integer) as pickup_location_id,
    CAST(DOlocationID as integer) as dropoff_location_id,
    CAST(SR_Flag as string) as sr_flag,
    CAST(Affiliated_base_number as string) as affiliated_base_number

from {{ source('raw_data', 'stg_fhv_tripdata_ext') }}
where dispatching_base_num IS NOT NULL