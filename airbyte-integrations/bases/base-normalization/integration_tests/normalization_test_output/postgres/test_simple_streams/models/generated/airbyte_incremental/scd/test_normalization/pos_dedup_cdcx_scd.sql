{{ config(
    indexes = [{'columns':['_airbyte_active_row','_airbyte_unique_key_scd','_airbyte_emitted_at'],'type': 'btree'}],
    unique_key = "_airbyte_unique_key_scd",
    schema = "test_normalization",
    post_hook = ['drop table if exists _airbyte_test_normalization.pos_dedup_cdcx_ab3'],
    tags = [ "top-level" ]
) }}
with
{% if is_incremental() %}
new_data as (
    -- retrieve incremental "new" data
    select
        *
    from {{ ref('pos_dedup_cdcx_ab3')  }}
    -- pos_dedup_cdcx from {{ source('test_normalization', '_airbyte_raw_pos_dedup_cdcx') }}
    where 1 = 1
    {{ incremental_clause('_airbyte_emitted_at') }}
),
new_data_ids as (
    -- build a subset of _airbyte_unique_key from rows that are new
    select distinct
        {{ dbt_utils.surrogate_key([
            adapter.quote('id'),
        ]) }} as _airbyte_unique_key
    from new_data
),
previous_active_scd_data as (
    -- retrieve "incomplete old" data that needs to be updated with an end date because of new changes
    select
        {{ star_intersect(ref('pos_dedup_cdcx_ab3'), this, from_alias='inc_data', intersect_alias='this_data') }}
    from {{ this }} as this_data
    -- make a join with new_data using primary key to filter active data that need to be updated only
    join new_data_ids on this_data._airbyte_unique_key = new_data_ids._airbyte_unique_key
    -- force left join to NULL values (we just need to transfer column types only for the star_intersect macro)
    left join {{ ref('pos_dedup_cdcx_ab3')  }} as inc_data on 1 = 0
    where _airbyte_active_row = 1
),
input_data as (
    select {{ dbt_utils.star(ref('pos_dedup_cdcx_ab3')) }} from new_data
    union all
    select {{ dbt_utils.star(ref('pos_dedup_cdcx_ab3')) }} from previous_active_scd_data
),
{% else %}
input_data as (
    select *
    from {{ ref('pos_dedup_cdcx_ab3')  }}
    -- pos_dedup_cdcx from {{ source('test_normalization', '_airbyte_raw_pos_dedup_cdcx') }}
),
{% endif %}
scd_data as (
    -- SQL model to build a Type 2 Slowly Changing Dimension (SCD) table for each record identified by their primary key
    select
      {{ dbt_utils.surrogate_key([
            adapter.quote('id'),
      ]) }} as _airbyte_unique_key,
        {{ adapter.quote('id') }},
        {{ adapter.quote('name') }},
        _ab_cdc_lsn,
        _ab_cdc_updated_at,
        _ab_cdc_deleted_at,
        _ab_cdc_log_pos,
      _airbyte_emitted_at as _airbyte_start_at,
      lag(_airbyte_emitted_at) over (
        partition by {{ adapter.quote('id') }}
        order by
            _airbyte_emitted_at is null asc,
            _airbyte_emitted_at desc,
            _airbyte_emitted_at desc, _ab_cdc_updated_at desc, _ab_cdc_log_pos desc
      ) as _airbyte_end_at,
      case when row_number() over (
        partition by {{ adapter.quote('id') }}
        order by
            _airbyte_emitted_at is null asc,
            _airbyte_emitted_at desc,
            _airbyte_emitted_at desc, _ab_cdc_updated_at desc, _ab_cdc_log_pos desc
      ) = 1 and _ab_cdc_deleted_at is null then 1 else 0 end as _airbyte_active_row,
      _airbyte_ab_id,
      _airbyte_emitted_at,
      _airbyte_pos_dedup_cdcx_hashid
    from input_data
),
dedup_data as (
    select
        -- we need to ensure de-duplicated rows for merge/update queries
        -- additionally, we generate a unique key for the scd table
        row_number() over (
            partition by _airbyte_unique_key, _airbyte_start_at, _airbyte_emitted_at, cast(_ab_cdc_deleted_at as {{ dbt_utils.type_string() }}), cast(_ab_cdc_updated_at as {{ dbt_utils.type_string() }}), cast(_ab_cdc_log_pos as {{ dbt_utils.type_string() }})
            order by _airbyte_ab_id
        ) as _airbyte_row_num,
        {{ dbt_utils.surrogate_key([
          '_airbyte_unique_key',
          '_airbyte_start_at',
          '_airbyte_emitted_at', '_ab_cdc_deleted_at', '_ab_cdc_updated_at', '_ab_cdc_log_pos'
        ]) }} as _airbyte_unique_key_scd,
        scd_data.*
    from scd_data
)
select
    _airbyte_unique_key,
    _airbyte_unique_key_scd,
        {{ adapter.quote('id') }},
        {{ adapter.quote('name') }},
        _ab_cdc_lsn,
        _ab_cdc_updated_at,
        _ab_cdc_deleted_at,
        _ab_cdc_log_pos,
    _airbyte_start_at,
    _airbyte_end_at,
    _airbyte_active_row,
    _airbyte_ab_id,
    _airbyte_emitted_at,
    {{ current_timestamp() }} as _airbyte_normalized_at,
    _airbyte_pos_dedup_cdcx_hashid
from dedup_data where _airbyte_row_num = 1

