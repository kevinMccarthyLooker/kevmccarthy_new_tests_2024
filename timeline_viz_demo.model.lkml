connection: "kevmccarthy_bq"



view: timeline_viz_demo {
  derived_table: {
    sql:
select 1 as id, 'a' as letter_group, datetime('2024-01-01 00:00:01') as start_time, datetime('2024-01-01 00:01:01') as end_time
union all
select 2 as id, 'a' as letter_group, datetime('2024-01-01 00:01:02') as start_time, datetime('2024-01-01 00:02:01') as end_time
    ;;
  }
  dimension: id {primary_key:yes}
  dimension: letter_group{}
  dimension: start_time {type:date_time datatype:datetime}
  dimension: end_time {type:date_time datatype:datetime}
  measure: record_count {type:count}
}
explore: timeline_viz_demo {

}


view: timeline_viz_demo_with_numbers {
  derived_table: {
    sql:
    select row_number() over() as id, 'a' as letter_group, rand()*200-100 as value from unnest(GENERATE_ARRAY(1, 5)) as records
    --union all
    ---select 2 as id, 'a' as letter_group, -10 as value
        ;;
  }
  dimension: id {primary_key:yes}
  dimension: letter_group{}
  dimension: value {}

  measure: record_count {type:count}
  measure: total_value {type:sum sql:${value};;}
  measure: measure_cardinality {}
  measure: running_total {type:running_total sql:${total_value};;}
}

explore: timeline_viz_demo_with_numbers {}
