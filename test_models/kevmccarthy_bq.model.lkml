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
