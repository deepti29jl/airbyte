{{ config(
    indexes = [{'columns':['_airbyte_emitted_at'],'type':'hash'}],
    unique_key = '_airbyte_ab_id',
    schema = "_airbyte_test_normalization",
    tags = [ "top-level-intermediate" ]
) }}
-- SQL model to parse JSON blob stored in a single column and extract into separated field columns as described by the JSON Schema
select
    {{ json_extract_scalar('_airbyte_data', ['id'], ['id']) }} as {{ adapter.quote('id') }},
    {{ json_extract_scalar('_airbyte_data', ['currency'], ['currency']) }} as currency,
    {{ json_extract_scalar('_airbyte_data', ['date'], ['date']) }} as {{ adapter.quote('date') }},
    {{ json_extract_scalar('_airbyte_data', ['timestamp_col'], ['timestamp_col']) }} as timestamp_col,
    {{ json_extract_scalar('_airbyte_data', ['HKD@spéçiäl & characters'], ['HKD@spéçiäl & characters']) }} as {{ adapter.quote('HKD@spéçiäl & characters') }},
    {{ json_extract_scalar('_airbyte_data', ['HKD_special___characters'], ['HKD_special___characters']) }} as hkd_special___characters,
    {{ json_extract_scalar('_airbyte_data', ['NZD'], ['NZD']) }} as nzd,
    {{ json_extract_scalar('_airbyte_data', ['USD'], ['USD']) }} as usd,
    _airbyte_ab_id,
    _airbyte_emitted_at,
    {{ current_timestamp() }} as _airbyte_normalized_at
from {{ source('test_normalization', '_airbyte_raw_dedup_exchange_rate') }} as table_alias
-- dedup_exchange_rate
where 1 = 1
{{ incremental_clause('_airbyte_emitted_at') }}

