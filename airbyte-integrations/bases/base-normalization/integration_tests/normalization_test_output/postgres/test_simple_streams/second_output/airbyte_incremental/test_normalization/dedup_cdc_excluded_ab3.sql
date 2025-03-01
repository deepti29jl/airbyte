
      

  create  table "postgres"._airbyte_test_normalization."dedup_cdc_excluded_ab3"
  as (
    
with __dbt__cte__dedup_cdc_excluded_ab1 as (

-- SQL model to parse JSON blob stored in a single column and extract into separated field columns as described by the JSON Schema
select
    jsonb_extract_path_text(_airbyte_data, 'id') as "id",
    jsonb_extract_path_text(_airbyte_data, 'name') as "name",
    jsonb_extract_path_text(_airbyte_data, '_ab_cdc_lsn') as _ab_cdc_lsn,
    jsonb_extract_path_text(_airbyte_data, '_ab_cdc_updated_at') as _ab_cdc_updated_at,
    jsonb_extract_path_text(_airbyte_data, '_ab_cdc_deleted_at') as _ab_cdc_deleted_at,
    _airbyte_ab_id,
    _airbyte_emitted_at,
    now() as _airbyte_normalized_at
from "postgres".test_normalization._airbyte_raw_dedup_cdc_excluded as table_alias
-- dedup_cdc_excluded
where 1 = 1

),  __dbt__cte__dedup_cdc_excluded_ab2 as (

-- SQL model to cast each column to its adequate SQL type converted from the JSON schema type
select
    cast("id" as 
    bigint
) as "id",
    cast("name" as 
    varchar
) as "name",
    cast(_ab_cdc_lsn as 
    float
) as _ab_cdc_lsn,
    cast(_ab_cdc_updated_at as 
    float
) as _ab_cdc_updated_at,
    cast(_ab_cdc_deleted_at as 
    float
) as _ab_cdc_deleted_at,
    _airbyte_ab_id,
    _airbyte_emitted_at,
    now() as _airbyte_normalized_at
from __dbt__cte__dedup_cdc_excluded_ab1
-- dedup_cdc_excluded
where 1 = 1

)-- SQL model to build a hash column based on the values of this record
select
    md5(cast(coalesce(cast("id" as 
    varchar
), '') || '-' || coalesce(cast("name" as 
    varchar
), '') || '-' || coalesce(cast(_ab_cdc_lsn as 
    varchar
), '') || '-' || coalesce(cast(_ab_cdc_updated_at as 
    varchar
), '') || '-' || coalesce(cast(_ab_cdc_deleted_at as 
    varchar
), '') as 
    varchar
)) as _airbyte_dedup_cdc_excluded_hashid,
    tmp.*
from __dbt__cte__dedup_cdc_excluded_ab2 tmp
-- dedup_cdc_excluded
where 1 = 1

  );
  