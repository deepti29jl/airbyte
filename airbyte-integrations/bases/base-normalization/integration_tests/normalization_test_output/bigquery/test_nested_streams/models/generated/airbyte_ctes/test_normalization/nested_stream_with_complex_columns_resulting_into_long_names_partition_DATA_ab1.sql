{{ config(
    cluster_by = "_airbyte_emitted_at",
    partition_by = {"field": "_airbyte_emitted_at", "data_type": "timestamp", "granularity": "day"},
    schema = "_airbyte_test_normalization",
    tags = [ "nested-intermediate" ]
) }}
-- SQL model to parse JSON blob stored in a single column and extract into separated field columns as described by the JSON Schema
{{ unnest_cte('nested_stream_with_complex_columns_resulting_into_long_names_partition', 'partition', 'DATA') }}
select
    _airbyte_partition_hashid,
    {{ json_extract_scalar(unnested_column_value('DATA'), ['currency'], ['currency']) }} as currency,
    _airbyte_ab_id,
    _airbyte_emitted_at,
    {{ current_timestamp() }} as _airbyte_normalized_at
from {{ ref('nested_stream_with_complex_columns_resulting_into_long_names_partition') }} as table_alias
-- DATA at nested_stream_with_complex_columns_resulting_into_long_names/partition/DATA
{{ cross_join_unnest('partition', 'DATA') }}
where 1 = 1
and DATA is not null
{{ incremental_clause('_airbyte_emitted_at') }}

