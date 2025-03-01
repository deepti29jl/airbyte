{{ config(
    sort = "_airbyte_emitted_at",
    schema = "test_normalization",
    tags = [ "nested" ]
) }}
-- Final base SQL model
select
    _airbyte_partition_hashid,
    id,
    _airbyte_ab_id,
    _airbyte_emitted_at,
    {{ current_timestamp() }} as _airbyte_normalized_at,
    _airbyte_double_array_data_hashid
from {{ ref('nested_stream_with_complex_columns_resulting_into_long_names_partition_double_array_data_ab3') }}
-- double_array_data at nested_stream_with_complex_columns_resulting_into_long_names/partition/double_array_data from {{ ref('nested_stream_with_complex_columns_resulting_into_long_names_partition') }}
where 1 = 1
{{ incremental_clause('_airbyte_emitted_at') }}

