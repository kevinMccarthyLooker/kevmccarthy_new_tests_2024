connection: "kevmccarthy_bq"

include: "/views/order_items.view.lkml"
# explore: order_items {}

# view: order_items {
#   sql_table_name: `kevmccarthy.thelook_with_orders_km.order_items` ;;
#   dimension_group: created {
#     type: time timeframes: [date, month, year]
#     datatype: timestamp
#     sql: ${TABLE}.created_at ;;
#   }
#   # measure: order_item_count {
#   #   type: count
#   # }


# }

view: +order_items {
  dimension: created_date_minute15 {
    type: date_minute15
    sql: ${created_raw} ;;
  }
}

explore: order_items {}

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
    select 1 as id, 'a' as letter, 'apple' as fruit , 'blue' as color
    union all
    select 2 as id, 'a' as letter, 'banana' as fruit , 'blue' as color
    union all
    select 2 as id, 'a' as letter, 'banana' as fruit , 'blue' as color
    ;;
  }
  dimension: id {type:number}
  dimension: letter {
    link: {
      label: "test"
      url: "{{letter._link}}"
      }
    link: {
      label: "abc"
      url: "abc"
    }
    drill_fields: [color,letter]
  }
  dimension: fruit {type:string}
  dimension: color {type:string}
}
explore: dimensions_drill_test {}

####
view: test_suggestions {
  derived_table: {
    sql:
    select 1 as a_number, 'a' as a_string, PARSE_DATE('%Y-%m-%d','2024-01-01') as a_date
    union all
    select 2 as a_number, 'b' as a_string, PARSE_DATE('%Y-%m-%d','2024-01-02')  as a_date
    ;;
  }
  dimension: a_number {type:number}
  dimension: a_string {}
  dimension: a_date {
    type: date
    datatype: date
  }
  filter: date_filter_field {
    type: date
    default_value: "2024-01-01"
    convert_tz: no
  }
}
explore: test_suggestions {
  always_filter: {filters:[test_suggestions.date_filter_field: "2024-01-01"]}
  # sql_always_where: ${test_suggestions.a_date}=PARSE_DATE('%Y-%m-%d','2024-01-02')  ;;
  sql_always_where: {% condition test_suggestions.date_filter_field %}timestamp(${test_suggestions.a_date}){%endcondition%}
  and ${test_suggestions.a_date}=PARSE_DATE('%Y-%m-%d','2024-01-02')
  ;;
}
####

view: pivot_order_test {
 derived_table: {
    sql: select 'first' as field, 'square' as shape
    union all select 'second', 'square' as shape
    union all select 'third', 'square' as shape
    union all select 'fourth', 'square' as shape
    union all
    select 'first' as field, 'cirlce' as shape
    union all select 'second', 'cirlce' as shape
    union all select 'third', 'cirlce' as shape
    union all select 'fourth', 'cirlce' as shape
    ;;
  }
  dimension: field {
    order_by_field:field_order
  }
  dimension: field_order {
    sql: case ${field}
          when 'first' then 1
          when 'second' then 2
          when 'third' then 3
          when 'fourth' then 4
          else 5
         end
    ;;
  }
  dimension: shape {}
  measure: count {type:count}

}
explore: pivot_order_test {}

view: date_filter_ui_options {
  derived_table: {
    sql:  select cast(null as date) as test_date , 'a' as test_string;;
  }
  dimension: test_date {
    label: "different label test"
    datatype: date
    type: date
  }
  parameter: start_date {
    type: date
  }
  parameter: end_date {
    type: date
  }
  dimension: test_string {}
  parameter: string_param {
    suggest_dimension: test_string
  }

}



explore: date_filter_ui_options {}

#html_in_field_value didn't work
view: html_in_field_value {
  derived_table: {
    sql: select '<a href="https://www.w3schools.com">Visit W3Schools</a>' as field_with_html ;;
  }
  dimension: field_with_html {
    # html:<a href="https://www.w3schools.com">Visit W3Schools</a> ;;
    html: {{value}} ;;
  }
}

explore: html_in_field_value {

}

view: suggestions_issue_when_always_filtering {
  extends: [order_items]
  dimension: status {
    suggest_persist_for: "1 seconds"
  }
}

explore: suggestions_issue_when_always_filtering {
  always_filter: {
    filters:[suggestions_issue_when_always_filtering.created_date: "7 days"]
  }
  #want this to do nothing when filter is set on suggestions_issue_when_always_filtering.created_date
  #but if not (e.g. in suggestions, want to put in a default
  # sql_always_where:
  # {%condition suggestions_issue_when_always_filtering.created_date%}test{%endcondition%}
  # and
  # 1=1
  # ;;
  sql_always_where:
  is filtered: {{suggestions_issue_when_always_filtering.created_date._is_filtered}}
  and
  1=1
  ;;
}

# view: +order_items: {
#   dimension: test_constant_injection {
#     type: yesno
#     # expression: NOT matches_filter(${order_items.created_date}, `6 months`) OR matches_filter(${products.brand}, `Levi's`);;
#     # expression: NOT matches_filter({{order_items.created_date._sql}}, `6 months`) OR matches_filter(${products.brand}, `Levi's`);;
#     expression: @{test_constant};;
#     # type: date
#     # datatype: date
#     # sql:  @{test_constant}  ;;
#   }


#   # measure: count_users_with_date_filter {
#   #   type: count
#   #   filters: [order_items.created_date: "after 2024/03/24"]
#   # }


# }
include: "/views/products.view.lkml"
explore: +order_items {
  join:  products{
    sql_on: ${order_items.product_id}=${products.id};;
    relationship: many_to_one
  }

  # sql_always_where: date_add(order_items.created_at, interval 365 day) ) >= ((TIMESTAMP(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY, 'America/Chicago'), MONTH, 'America/Chicago'), 'America/Chicago'), INTERVAL -1 MONTH), 'America/Chicago'))) ;;

}

view: t {
  derived_table: {
    sql_create:  ;;
  }
}
#Amy southwood question 3/13/24
view: +order_items {
  # label: "{{_model._name}}: Premium Analytics"
  label: "{{created_date._sql}}: Premium Analytics"
}
explore: +order_items {
  # label: "{{_model._name}}: Premium Analytics"
  # label: "{{created_date._sql}}: Premium Analytics"
}

label: "{{_model._name}}:model label"
