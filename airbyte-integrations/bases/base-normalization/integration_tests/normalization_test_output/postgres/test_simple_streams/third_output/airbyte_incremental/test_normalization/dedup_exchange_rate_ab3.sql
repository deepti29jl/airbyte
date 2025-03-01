
      

  create  table "postgres"._airbyte_test_normalization."dedup_exchange_rate_ab3"
  as (
    
with __dbt__cte__dedup_exchange_rate_ab1 as (

-- SQL model to parse JSON blob stored in a single column and extract into separated field columns as described by the JSON Schema
select
    jsonb_extract_path_text(_airbyte_data, 'id') as "id",
    jsonb_extract_path_text(_airbyte_data, 'currency') as currency,
    jsonb_extract_path_text(_airbyte_data, 'new_column') as new_column,
    jsonb_extract_path_text(_airbyte_data, 'date') as "date",
    jsonb_extract_path_text(_airbyte_data, 'timestamp_col') as timestamp_col,
    jsonb_extract_path_text(_airbyte_data, 'HKD@spéçiäl & characters') as "HKD@spéçiäl & characters",
    jsonb_extract_path_text(_airbyte_data, 'NZD') as nzd,
    jsonb_extract_path_text(_airbyte_data, 'USD') as usd,
    _airbyte_ab_id,
    _airbyte_emitted_at,
    now() as _airbyte_normalized_at
from "postgres".test_normalization._airbyte_raw_dedup_exchange_rate as table_alias
-- dedup_exchange_rate
where 1 = 1

),  __dbt__cte__dedup_exchange_rate_ab2 as (

-- SQL model to cast each column to its adequate SQL type converted from the JSON schema type
select
    cast("id" as 
    float
) as "id",
    cast(currency as 
    varchar
) as currency,
    cast(new_column as 
    float
) as new_column,
    cast(nullif("date", '') as 
    date
) as "date",
    cast(nullif(timestamp_col, '') as 
    timestamp with time zone
) as timestamp_col,
    cast("HKD@spéçiäl & characters" as 
    float
) as "HKD@spéçiäl & characters",
    cast(nzd as 
    float
) as nzd,
    cast(usd as 
    bigint
) as usd,
    _airbyte_ab_id,
    _airbyte_emitted_at,
    now() as _airbyte_normalized_at
from __dbt__cte__dedup_exchange_rate_ab1
-- dedup_exchange_rate
where 1 = 1

)-- SQL model to build a hash column based on the values of this record
select
    md5(cast(coalesce(cast("id" as 
    varchar
), '') || '-' || coalesce(cast(currency as 
    varchar
), '') || '-' || coalesce(cast(new_column as 
    varchar
), '') || '-' || coalesce(cast("date" as 
    varchar
), '') || '-' || coalesce(cast(timestamp_col as 
    varchar
), '') || '-' || coalesce(cast("HKD@spéçiäl & characters" as 
    varchar
), '') || '-' || coalesce(cast(nzd as 
    varchar
), '') || '-' || coalesce(cast(usd as 
    varchar
), '') as 
    varchar
)) as _airbyte_dedup_exchange_rate_hashid,
    tmp.*
from __dbt__cte__dedup_exchange_rate_ab2 tmp
-- dedup_exchange_rate
where 1 = 1

  );
  