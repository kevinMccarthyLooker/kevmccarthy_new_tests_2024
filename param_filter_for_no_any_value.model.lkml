connection: "kevmccarthy_bq"

view: param_filter_for_no_any_value {
  derived_table: {
    sql: select 1 as id, 'red' as color,101 as value union all
    select 2 as id, 'red' as color, 201 as value union all
    select 3 as id, 'blue' as color, 301 as value ;;
  }
  dimension: id {}
  dimension: color {}
  dimension: value {}
  measure: count {type:count}
  measure: total_value {type:sum sql:${value};;}

  parameter: param_ui_test {
    type: string
    suggest_dimension: color
  }
}

explore: param_filter_for_no_any_value {
  sql_always_where: {% condition param_ui_test %}${param_filter_for_no_any_value.color}{% endcondition %} ;;
}
