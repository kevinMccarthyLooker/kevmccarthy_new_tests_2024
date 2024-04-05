connection: "kevmccarthy_bq"

view: test_measure_default_behavior {
  derived_table: {
    sql:
    select 1 as id, 101 as value
    union all select 2 as id, 1001 as value;;
  }
  dimension: id {}
  measure: value {
    sql: sum(${TABLE}.value) ;;
  }

  dimension: now_dimension {
    sql: current_timestamp() ;;
  }
}
explore: test_measure_default_behavior {
  persist_for: "15 seconds"
}

view: test_pivot_merge {
  derived_table: {
    sql:
    select 1 as id, 'a' as a_group, 101 as value
    union all
    select 2 as id, 'a' as a_group, 201 as value
    union all
    select 3 as id, 'b' as a_group, 1001 as value
    union all
    select 4 as id, 'b' as a_group, 2001 as value
    ;;
  }
  dimension: id {

  }
  dimension: a_group {}
  dimension: value {
    type: number
  }
  measure: total_value {
    type: sum
    sql: ${value} ;;
  }

  dimension: test {
    type: yesno
    expression: ${test_pivot_merge.value}>1 OR ${test_pivot_merge.value}<1;;
  }
}
explore: test_pivot_merge {}


view: test_grouping_sets {
  derived_table: {
    sql:
    with dataset as (
SELECT status, cast(round(sale_price/100,0) as int64) as sale_price_hundreds,
FROM `kevmccarthy.thelook_with_orders_km.order_items`
)
,final_dataset as (
select
concat(
  case when grouping(status) = 0 then 'status,' else '' end,
  case when grouping(sale_price_hundreds) = 0 then 'sale_price_hundreds,' else '' end
)
as broken_down_by_list,
status,
sale_price_hundreds,
-- case when grouping(status)

-- end as status_grouping_level,

count(*) as row_count
FROM dataset

group by CUBE (2,3)
)
select * from final_dataset
    ;;
  }
  dimension: broken_down_by_list {}
  dimension: status {}
  dimension: sale_price_hundreds {}
  measure: row_count {
    type: count
  }
}
explore: test_grouping_sets {}




view: timeline_viz {
  derived_table: {

  sql:
select 1 as id, 'b' as dim__a_b_c, 'blue' as dim_red_green_blue, 81 as value union all
select 2 as id, 'c' as dim__a_b_c, 'blue' as dim_red_green_blue, 56 as value union all
select 3 as id, 'b' as dim__a_b_c, 'green' as dim_red_green_blue, 83 as value union all
select 4 as id, 'b' as dim__a_b_c, 'green' as dim_red_green_blue, 70 as value union all
select 5 as id, 'c' as dim__a_b_c, 'green' as dim_red_green_blue, 87 as value union all
select 6 as id, 'c' as dim__a_b_c, 'green' as dim_red_green_blue, 97 as value union all
select 7 as id, 'b' as dim__a_b_c, 'blue' as dim_red_green_blue, 40 as value union all
select 8 as id, 'b' as dim__a_b_c, 'blue' as dim_red_green_blue, 87 as value union all
select 9 as id, 'a' as dim__a_b_c, 'red' as dim_red_green_blue, 93 as value union all
select 10 as id, 'a' as dim__a_b_c, 'red' as dim_red_green_blue, 69 as value union all
select 11 as id, 'a' as dim__a_b_c, 'red' as dim_red_green_blue, 63 as value union all
select 12 as id, 'a' as dim__a_b_c, 'blue' as dim_red_green_blue, 67 as value union all
select 13 as id, 'a' as dim__a_b_c, 'red' as dim_red_green_blue, 19 as value union all
select 14 as id, 'c' as dim__a_b_c, 'green' as dim_red_green_blue, 29 as value union all
select 15 as id, 'a' as dim__a_b_c, 'blue' as dim_red_green_blue, 9 as value union all
select 16 as id, 'a' as dim__a_b_c, 'red' as dim_red_green_blue, 72 as value union all
select 17 as id, 'b' as dim__a_b_c, 'red' as dim_red_green_blue, 63 as value union all
select 18 as id, 'b' as dim__a_b_c, 'green' as dim_red_green_blue, 66 as value union all
select 19 as id, 'b' as dim__a_b_c, 'red' as dim_red_green_blue, 7 as value union all
select 20 as id, 'b' as dim__a_b_c, 'blue' as dim_red_green_blue, 11 as value union all
select 21 as id, 'a' as dim__a_b_c, 'green' as dim_red_green_blue, 22 as value union all
select 22 as id, 'a' as dim__a_b_c, 'blue' as dim_red_green_blue, 59 as value union all
select 23 as id, 'c' as dim__a_b_c, 'red' as dim_red_green_blue, 81 as value union all
select 24 as id, 'b' as dim__a_b_c, 'red' as dim_red_green_blue, 83 as value union all
select 25 as id, 'a' as dim__a_b_c, 'blue' as dim_red_green_blue, 65 as value union all
select 26 as id, 'c' as dim__a_b_c, 'red' as dim_red_green_blue, 91 as value union all
select 27 as id, 'a' as dim__a_b_c, 'green' as dim_red_green_blue, 22 as value union all
select 28 as id, 'b' as dim__a_b_c, 'blue' as dim_red_green_blue, 100 as value union all
select 29 as id, 'c' as dim__a_b_c, 'red' as dim_red_green_blue, 4 as value union all
select 30 as id, 'a' as dim__a_b_c, 'green' as dim_red_green_blue, 76 as value union all
select 31 as id, 'a' as dim__a_b_c, 'red' as dim_red_green_blue, 79 as value union all
select 32 as id, 'c' as dim__a_b_c, 'green' as dim_red_green_blue, 21 as value union all
select 33 as id, 'b' as dim__a_b_c, 'blue' as dim_red_green_blue, 88 as value union all
select 34 as id, 'b' as dim__a_b_c, 'green' as dim_red_green_blue, 52 as value union all
select 35 as id, 'b' as dim__a_b_c, 'green' as dim_red_green_blue, 1 as value union all
select 36 as id, 'b' as dim__a_b_c, 'blue' as dim_red_green_blue, 81 as value union all
select 37 as id, 'b' as dim__a_b_c, 'red' as dim_red_green_blue, 25 as value union all
select 38 as id, 'c' as dim__a_b_c, 'red' as dim_red_green_blue, 82 as value union all
select 39 as id, 'b' as dim__a_b_c, 'blue' as dim_red_green_blue, 98 as value union all
select 40 as id, 'b' as dim__a_b_c, 'red' as dim_red_green_blue, 23 as value union all
select 41 as id, 'a' as dim__a_b_c, 'red' as dim_red_green_blue, 47 as value union all
select 42 as id, 'a' as dim__a_b_c, 'red' as dim_red_green_blue, 100 as value union all
select 43 as id, 'c' as dim__a_b_c, 'green' as dim_red_green_blue, 42 as value union all
select 44 as id, 'c' as dim__a_b_c, 'red' as dim_red_green_blue, 69 as value union all
select 45 as id, 'c' as dim__a_b_c, 'red' as dim_red_green_blue, 59 as value union all
select 46 as id, 'c' as dim__a_b_c, 'blue' as dim_red_green_blue, 62 as value union all
select 47 as id, 'a' as dim__a_b_c, 'red' as dim_red_green_blue, 40 as value union all
select 48 as id, 'a' as dim__a_b_c, 'blue' as dim_red_green_blue, 91 as value union all
select 49 as id, 'c' as dim__a_b_c, 'green' as dim_red_green_blue, 14 as value union all
select 50 as id, 'a' as dim__a_b_c, 'green' as dim_red_green_blue, 11 as value union all
select 51 as id, 'c' as dim__a_b_c, 'green' as dim_red_green_blue, 43 as value union all
select 52 as id, 'a' as dim__a_b_c, 'red' as dim_red_green_blue, 24 as value union all
select 53 as id, 'b' as dim__a_b_c, 'blue' as dim_red_green_blue, 80 as value union all
select 54 as id, 'b' as dim__a_b_c, 'blue' as dim_red_green_blue, 79 as value union all
select 55 as id, 'a' as dim__a_b_c, 'red' as dim_red_green_blue, 40 as value union all
select 56 as id, 'a' as dim__a_b_c, 'green' as dim_red_green_blue, 8 as value union all
select 57 as id, 'c' as dim__a_b_c, 'red' as dim_red_green_blue, 15 as value union all
select 58 as id, 'b' as dim__a_b_c, 'blue' as dim_red_green_blue, 85 as value union all
select 59 as id, 'b' as dim__a_b_c, 'green' as dim_red_green_blue, 24 as value union all
select 60 as id, 'b' as dim__a_b_c, 'blue' as dim_red_green_blue, 47 as value union all
select 61 as id, 'b' as dim__a_b_c, 'blue' as dim_red_green_blue, 97 as value union all
select 62 as id, 'c' as dim__a_b_c, 'green' as dim_red_green_blue, 70 as value union all
select 63 as id, 'b' as dim__a_b_c, 'green' as dim_red_green_blue, 59 as value union all
select 64 as id, 'a' as dim__a_b_c, 'blue' as dim_red_green_blue, 84 as value union all
select 65 as id, 'b' as dim__a_b_c, 'green' as dim_red_green_blue, 79 as value union all
select 66 as id, 'a' as dim__a_b_c, 'red' as dim_red_green_blue, 27 as value union all
select 67 as id, 'b' as dim__a_b_c, 'red' as dim_red_green_blue, 5 as value union all
select 68 as id, 'c' as dim__a_b_c, 'blue' as dim_red_green_blue, 80 as value union all
select 69 as id, 'a' as dim__a_b_c, 'blue' as dim_red_green_blue, 58 as value union all
select 70 as id, 'a' as dim__a_b_c, 'red' as dim_red_green_blue, 76 as value union all
select 71 as id, 'b' as dim__a_b_c, 'green' as dim_red_green_blue, 80 as value union all
select 72 as id, 'b' as dim__a_b_c, 'blue' as dim_red_green_blue, 63 as value union all
select 73 as id, 'b' as dim__a_b_c, 'red' as dim_red_green_blue, 26 as value union all
select 74 as id, 'b' as dim__a_b_c, 'red' as dim_red_green_blue, 78 as value union all
select 75 as id, 'c' as dim__a_b_c, 'blue' as dim_red_green_blue, 48 as value union all
select 76 as id, 'b' as dim__a_b_c, 'green' as dim_red_green_blue, 16 as value union all
select 77 as id, 'b' as dim__a_b_c, 'green' as dim_red_green_blue, 6 as value union all
select 78 as id, 'b' as dim__a_b_c, 'green' as dim_red_green_blue, 28 as value union all
select 79 as id, 'a' as dim__a_b_c, 'blue' as dim_red_green_blue, 34 as value union all
select 80 as id, 'c' as dim__a_b_c, 'green' as dim_red_green_blue, 73 as value union all
select 81 as id, 'a' as dim__a_b_c, 'blue' as dim_red_green_blue, 19 as value union all
select 82 as id, 'c' as dim__a_b_c, 'blue' as dim_red_green_blue, 4 as value union all
select 83 as id, 'c' as dim__a_b_c, 'green' as dim_red_green_blue, 38 as value union all
select 84 as id, 'b' as dim__a_b_c, 'green' as dim_red_green_blue, 56 as value union all
select 85 as id, 'a' as dim__a_b_c, 'red' as dim_red_green_blue, 43 as value union all
select 86 as id, 'b' as dim__a_b_c, 'blue' as dim_red_green_blue, 69 as value union all
select 87 as id, 'c' as dim__a_b_c, 'blue' as dim_red_green_blue, 32 as value union all
select 88 as id, 'b' as dim__a_b_c, 'green' as dim_red_green_blue, 95 as value union all
select 89 as id, 'a' as dim__a_b_c, 'green' as dim_red_green_blue, 40 as value union all
select 90 as id, 'b' as dim__a_b_c, 'red' as dim_red_green_blue, 64 as value union all
select 91 as id, 'a' as dim__a_b_c, 'green' as dim_red_green_blue, 64 as value union all
select 92 as id, 'a' as dim__a_b_c, 'green' as dim_red_green_blue, 61 as value union all
select 93 as id, 'b' as dim__a_b_c, 'red' as dim_red_green_blue, 52 as value union all
select 94 as id, 'a' as dim__a_b_c, 'blue' as dim_red_green_blue, 84 as value union all
select 95 as id, 'a' as dim__a_b_c, 'green' as dim_red_green_blue, 99 as value union all
select 96 as id, 'b' as dim__a_b_c, 'blue' as dim_red_green_blue, 3 as value union all
select 97 as id, 'a' as dim__a_b_c, 'red' as dim_red_green_blue, 45 as value union all
select 98 as id, 'c' as dim__a_b_c, 'green' as dim_red_green_blue, 12 as value

  ;;
  }
  dimension: id {}
  dimension: dim__a_b_c {}
  dimension: dim_red_green_blue {}
  dimension: value {}
  measure: sum_value {
    type: sum
    sql: ${value} ;;
  }
}
explore:  timeline_viz {}

include: "/tdash.dashboard.lookml"
include: "/t_extended_to_hide.dashboard.lookml"
include: "/test_user_attributes.dashboard.lookml"
# connection: "kevmccarthy_bq"

explore: order_items {}

view: order_items {
  sql_table_name: `kevmccarthy.thelook_with_orders_km.order_items` ;;
  dimension_group: created {
    type: time timeframes: [date, month, year]
    datatype: timestamp
    sql: ${TABLE}.created_at ;;
  }
  measure: order_item_count {
    type: count
  }


}


view: suggestion_order_test {
  derived_table: {
    sql:  select 'm' as gender
          union all select 'f'
          union all select 'males'
          ;;
  }
  dimension: gender {
    suggest_persist_for: "0 seconds"
    order_by_field: gender_sort
  }
  dimension: gender_sort {
    case: {
      when: {sql: ${gender}='males' ;; label: "1"}
      when: {sql: ${gender}='m' ;; label: "2"}
      when: {sql: ${gender}='f' ;; label: "3"}
    }
  }
}
explore: suggestion_order_test {}

view: scatter {
  derived_table: {
    sql:  select 1 as id,1 as class, 1 as x_value, 1 as y_value
          union all select 2 as id,2 as class, 1.5 as x_value, 1 as y_value
          union all select 3 as id, 2 as class, 1 as x_value, 1.5 as y_value
          ;;
  }
  dimension: id {primary_key:yes}
  dimension: class {}
  dimension: x_value {type:number}
  dimension: y_value {}
  measure: count {type:count}
  measure: avg_y {
    type: average
    sql: ${y_value} ;;
  }
  measure: avg_x {
    type: average
    sql: ${x_value} ;;
  }
}
explore: scatter {}



view: dimensions_drill_test {
  derived_table: {
    sql:
    select 1 as id, 'a' as letter, 'apple' as fruit
    union all
    select 2 as id, 'a' as letter, 'banana' as fruit
    ;;
  }
  dimension: id {type:number}
  dimension: letter {
    drill_fields: [fruit]
  }
  dimension: fruit {}
}
# explore: dimensions_drill_test {}



view: tick_density_test {
  derived_table: {
    sql: select 1 as value, 'one' as name union all select 2, 'two' union all select rand(), 'rand' ;;
  }
  dimension: value {}
  measure: total_value {
    type: sum
    sql: ${value} ;;
  }
  dimension: name {}
}
explore: tick_density_test {}

view: test_user_group_mapping {
  derived_table: {sql:select 1 as id;;}
  dimension: id {}
dimension: my_name {sql: {{_user_attributes['name']}} ;;}
  dimension: my_group {
    sql:
{% if _user_attributes['name'] == 'Kevin McCarthy'%}group_1
{% elsif _user_attributes['name'] == 'John Smith'%}group_1
{% elsif _user_attributes['name'] == 'Jane Does'%}group_2
{%else %}unnassigned
{%endif%}
    ;;
  }
  dimension: my_group_value_attribute_1 {
    sql:
{%assign my_group = test_user_group_mapping.my_group._sql | strip %}
{% if my_group == 'group_1'%}some_attribute_value_appropriate_for_group_1
{% elsif my_group == 'group_2'%}some_other_value
{%else %}unnassigned
{%endif%}
        ;;
  }


}
explore: test_user_group_mapping {}
