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

# view: order_items {
#   sql_table_name: `kevmccarthy.thelook_with_orders_km.order_items` ;;
#   dimension_group: created {
#     type: time timeframes: [date, month, year]
#     datatype: timestamp
#     sql: ${TABLE}.created_at ;;
#   }
#   measure: order_item_count {
#     type: count
#   }


# }


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




view: dynamic_labels_test {
  derived_table: {sql:select 1 as id;;}
  parameter: test_parameter {
    allowed_value: {value:"choice_1"}
    allowed_value: {value:"choice_2"}
  }
  dimension: dynamic_field_name_using_label {
    label: "{% if _field._is_selected %}{{test_parameter._parameter_value | remove: \"'\"}} (can add custom message) {%else%}Shows in Field Picker{%endif%}"
    sql:  1;;
  }
  dimension: dynamic_field_name_using_label_from_parameter {
    label_from_parameter: test_parameter
    sql:  1;;
  }

}

explore: dynamic_labels_test {}




# view: test_create_process {
#   derived_table: {
#   #   create_process: {
#   #     sql_step: DECLARE heads BOOL; ;;
#   #     sql_step:   IF RAND()<0.5 THEN
#   #   SELECT 'Heads!' as result;
#   # --   SET heads_count = heads_count + 1;
#   # ELSE
#   #   SELECT 'Tails!' as result;
#   #   -- BREAK;
#   # END IF ;;

#   #   }

#     # persist_for: "1 seconds"
#     sql_create: select 1 as id ;; #${SQL_TABLE_NAME}
#   }
#   dimension: result {}


# }
# explore:  test_create_process {}

view: t {
  derived_table: {sql:select 1 as id;;}
  dimension: id {}
  measure: count {type:count}
}
explore: t {}
include: "/dash_tile_positions_for_extends.dashboard.lookml"



view: capture_final_sql {
  derived_table: {sql:select 1 as id
    union all select 2 as id
    union all select 3 as id

    ;;}
  dimension: id {}
  measure: row {type:number sql:row_number() over();;}
  # dimension: test {
  #   sql: results2.capture_final_sql_id ;;
  # }
}

explore: capture_final_sql {
  sql_preamble:
  --test preamble
with results as (
  --end test preamble
  ;;
#   sql_always_having:
#   --test having
#   1=1
#   )
# ) as results
  # ;;

  sql_always_where: 1=1 group by all) as results ;;
}


view: row_number_checker {
  derived_table: {
    sql:select 1 as id,'blue' as color
    union all select 2 as id,'blue' as color
    union all select 3 as id,'red' as color
    ;;}
  dimension: id {}
  dimension: color {}
  measure: sum_id {type:sum sql:${id};;}
  # measure: sum_id_prior_row {
  #   type: sum
  #   expression: offset(${row_number_checker.sum_id},-1);;
  # }
  # dimension:  sum_id_prior_row2{
  #   expression: offset(${row_number_checker.sum_id},-1);;
  # }

  measure: overall_row_number {
    # sql: row_number() over() ;;
    type: number

  }
}
explore: row_number_checker {}



view: median_at_a_different_grain__invoices {
  derived_table: {
    sql:select 1 as invoice_id,date('2024-01-01') as invoice_date
          union all select 2 as invoice_id,date('2024-01-01') as invoice_date
          ;;}
  dimension: invoice_id {}

}
view: median_at_a_different_grain__line_item {
  derived_table: {
    sql:select 1 as id,1 as invoice_id, 'blue' as color, 1 as amount
          union all select 2 as id,1 as invoice_id,'blue' as color, 2 as amount
          union all select 3 as id,1 as invoice_id,'red' as color, 4 as amount
          union all select 4 as id,2 as invoice_id,'red' as color, 5 as amount
          ;;}
  dimension: id {}
  dimension: invoice_id {}
  dimension: color {}
  dimension: amount {}
  measure: total_amount {type: sum sql: ${amount} ;;}
  measure: median_amount {type: median sql: ${amount} ;;}
}

explore: median_at_a_different_grain__invoices {
  join: median_at_a_different_grain__line_item {
    relationship: one_to_many
    sql_on: ${median_at_a_different_grain__invoices.invoice_id}=${median_at_a_different_grain__line_item.invoice_id};;
  }
}


view: suggestions_options_test {
  derived_table: {sql:select 1 as id, 'test full_suggestions_yes' as full_suggestions_yes, 'test full_suggestions_no' as full_suggestions_no;;}
  dimension: id {}
  dimension: full_suggestions_yes {
    type: string
    full_suggestions: yes
  }
  dimension: full_suggestions_no {
    type: string
    full_suggestions: no
  }
  measure: count {type:count}
}
explore: suggestions_options_test {
  sql_always_where: 1=0 ;;
}



#customer wants a 'total row' which actually adds
view: custom_totals_with_merge_results {
  derived_table: {
    sql:select 1 as id,1 as invoice_id, 'blue' as color, 1 as amount, 2 as denominator
          union all select 2 as id,1 as invoice_id,'blue' as color, 2 as amount, 2 as denominator
          union all select 3 as id,1 as invoice_id,'red' as color, 4 as amount, 2 as denominator
          union all select 4 as id,2 as invoice_id,'red' as color, 5 as amount, 2 as denominator
          ;;}
  dimension: id {}
  dimension: invoice_id {}
  dimension: color {}
  dimension: amount {}
  measure: total_amount {type: sum sql: ${amount} ;;}
  measure: median_amount {type: median sql: ${amount} ;;}
  measure: denominator {type:sum}
  measure: ratio {type:number sql:${total_amount} / ${denominator};;}
  measure: count {type:count}
}
explore: custom_totals_with_merge_results {}


view: matches_advanced_vs_range_filter {
  # derived_table: {
  #   sql:
  #   select 'today' as label,current_date as test_date
  #   union all
  #   select 'yesterday' as label,date_add(current_date, interval -1 day) as test_date
  #   ;;
  # }
  sql_table_name: kevmccarthy.thelook_with_orders_km.orders_partitioned ;;

  dimension_group: created_at {
    type: time
    timeframes: [raw,time,date]
  }
  dimension_group: created_at_based_on_date_not_timestampe{
    type: time
    timeframes: [raw,date]
    datatype: date
    sql: date(${TABLE}.created_at) ;;
  }
}
explore: matches_advanced_vs_range_filter {}


view: selected_field_list_idea {
  derived_table: {sql:select 1 as a, 2 as b;;}
  dimension: a {}
  dimension: b {}
  measure: count {type:count}
  dimension: dummy_drill {
    drill_fields: [dummy_drill]
    sql: 1 ;;
    # html: {{_field._link}} ;;
  }
  measure: a_field_to_show_dummy_drill_link {
    type: count
    # html:
    # {% assign drill_url = selected_field_list_idea.dummy_drill._link %}
    # {% assign field_list = drill_url | split: 'fields=' | last | split: '&' | first %}
    # field_list:{{field_list}}
    # ;;
    html:  {{ selected_field_list_idea.dummy_drill._link}} ;;
  }
  measure: another_dummy_drill {
    type: count
    drill_fields: [a]

  }
  measure: another_dummy_drills_link {
    type: count
    html:  link:{{ another_dummy_drill._link}} ;;
  }

  measure: row_value {
    type: count
    # html: {{ row[] }} ;;
    # html: val:{{row[]}};;
  }
  dimension: row_dim {
    sql: 1 ;;
    # html: {% assign x = row[] %} ;;#doesn't work as of 5/29/24
  }
}

explore: selected_field_list_idea {}


view: large_resultset_map_test {
  derived_table: {
    sql: select ids as id,rand() as random_value from unnest(generate_array(1, 10000)) ids ;;
  }
  dimension: id {}
  dimension: random_value {}
  measure: test_measure {
    type: sum
    sql: ${random_value} ;;
  }
  dimension: random_latitude {
    sql: rand() * 50 ;;
  }
  dimension: random_longitude {
    sql: rand() * 50 ;;
  }
  dimension: random_location {
    type: location
    sql_latitude: ${random_latitude} ;;
    sql_longitude: ${random_longitude} ;;
  }
}
explore: large_resultset_map_test {
  sql_always_where: 1=1
  offset 100  ;;
  sql_always_having: 1=1
  --always_having
  ;;
}


#5/30 email from  <ismail.tigrek@zealitconsultants.com>
# asked if we can show % of total on a pie chart
include: "/views/order_items.view.lkml"
view: tooltips_demo_order_items {
  extends: [order_items]

  measure: order_item_count {
    type:count
  }

  measure: percent_of_total {
    type: percent_of_total
    sql: ${order_item_count} ;;
  }

  measure: order_item_count_with_percent_of_total_tooltip {
    type:count
    html: {{rendered_value}} ({{percent_of_total._rendered_value}} of total) ;;
  }

measure: table_tooltip {
  type: count
#   html:
# <div class="tooltip">Hover over me
#   <span class="tooltiptext">Tooltip text</span>
# </div>
# ;;
  # html: <button title="ttttttt" class=tooltiptext>

  # {{rendered_value}}
  # </button> ;;

  html:<div class="vis"><div class="vis-single-value" style="background-color:#ffffff;"data-toggle="tooltip" data-placement="top" title="t {{value}}" >{{rendered_value }}</div></div>;;
}


}

explore: tooltips_demo_order_items {}

access_grant: user_is_people_analytics_or_hr_executive {
  user_attribute: email
  allowed_values: ["Kevin McCarthy","Kevin McCarthy2"]
}


view: bind_all_test_view_base {
  derived_table: {
    sql: select '1' as id, 'red' as color, 1 as value union all select '2' as id, 'red' as color, 102 as value;;
  }
  dimension: id {primary_key:yes }
  dimension: color {}
  dimension: value {type:number}
  measure: total_value {type:sum sql:${value};;}
  parameter: dummy_param {}
}
view: bind_all_test_ndt_with_bind_all {
  derived_table: {
    explore_source: bind_all_test {
      column: color {}
      column: total_value {}
      bind_all_filters: yes
    }
  }
  dimension: color {}
  dimension: total_value_for_color {sql:${TABLE}.total_value;;}
}
# view: steal_bind_all_sql {
#   extends: [bind_all_test_ndt_with_bind_all]
#   derived_table: {
#     # sql:  select * from ${bind_all_test_ndt_with_bind_all.SQL_TABLE_NAME};;
#     sql: select * from (${EXTENDED}) ;;
#   }
#   dimension: dummy {}
# }
#these overrides didn't work
view: bind_all_test_ndt_with_bind_all_plus {
  derived_table: {
    explore_source: bind_all_test {
      column: color {}
      column: total_value {}
      # bind_filters: {
      #   from_field: bind_all_test_view_base.color
      #   to_field: bind_all_test_view_base.id
      # }
      bind_all_filters: yes
      # filters: [bind_all_test_view_base.id: ""]
      expression_custom_filter:  ${bind_all_test_view_base.id} = "";;
    }
  }
  dimension: color {}
  dimension: total_value_for_color {sql:${TABLE}.total_value;;}
}

explore:bind_all_test {
  view_name: bind_all_test_view_base
  join: bind_all_test_ndt_with_bind_all {
    relationship: many_to_one
    sql_on: ${bind_all_test_view_base.color}=${bind_all_test_ndt_with_bind_all.color} ;;
  }
  # join: steal_bind_all_sql {type:cross relationship:one_to_one}
  join: bind_all_test_ndt_with_bind_all_plus {
    relationship: many_to_one
    sql_on: ${bind_all_test_view_base.color}=${bind_all_test_ndt_with_bind_all_plus.color} ;;
  }
}

view: test_dates {
  derived_table: {
    sql: select date('2024-01-01') as a_date, 'test string' as string_field ;;
  }
  dimension: a_date {
    type: date
  }
  dimension: string_field {}
  parameter: test_parameter {
    suggest_dimension: string_field
  }
}
explore: test_dates {}


view: order_items_avg_duration_formatting_question {
  extends: [order_items]
  dimension: avg_stage_duration_dim {
    type: duration_day
    sql_start: ${created_raw} ;;
    sql_end: date_add(${shipped_raw},interval 40 day) ;;
  }
  measure: avg_stage_duration {
    type: average
    sql: ${avg_stage_duration_dim} ;;

  }

}

explore: order_items_avg_duration_formatting_question {}

view: suggestions {
  derived_table: {
    sql:
SELECT
    products.name  AS products_name
FROM `kevmccarthy.thelook_with_orders_km.products`  AS products
    ;;
  }
  dimension: products_name {}
}
explore: suggestions {}

include: "/views/products.view.lkml"
view: +products {
  dimension: name2 {
    suggest_explore: suggestions
    suggest_dimension: suggestions.products_name
  }
  dimension: name {

  }
}
explore: products {}


view: order_items_dymnamic_references {
  extends: [order_items]
  dimension: dynamic_ref_dim {
    sql:
    case
      when {% condition order_items_dymnamic_references.status %}'Complete'{%endcondition%} then 2
      when {% condition order_items_dymnamic_references.status %}'Cancelled'{%endcondition%} then 1
      else 0
    end
    ;;
  }
  measure: dynamic_ref_measure {
    type: number
    sql:
    max(
      case
        when {% condition order_items_dymnamic_references.status %}'Complete'{%endcondition%} then 2000
        when {% condition order_items_dymnamic_references.status %}'Cancelled'{%endcondition%} then 1000
        else 0
      end
    )
    ;;

  }
}

explore: order_items_dymnamic_references {}
