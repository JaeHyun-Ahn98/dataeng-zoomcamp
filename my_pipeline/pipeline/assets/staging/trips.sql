/* @bruin
name: staging.trips
type: bq.sql
depends:
  - ingestion.trips
@bruin */

SELECT * FROM {{ ref('ingestion.trips') }}