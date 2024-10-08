connection: "kevmccarthy_bq"

view: constant_as_html_function {
  derived_table: {
    sql:
    select 1 as id, 'blue' as color, 101 as value, 1001 as other_value
    union all
    select 2 as id, 'red' as color, 201 as value, 2001 as other_value
    ;;
  }
  dimension: id {}
  dimension: color {}
  dimension: value {}
  measure: total_value {
    type: sum
    sql: ${value} ;;
  }
  dimension: other_value {}
  measure: total_other_value {
    type: sum
    sql: ${other_value} ;;
    html:
    {% assign function_input = total_other_value._value %}
    @{constant_as_html_function}
    <br>
    {% assign function_input = total_value._value %}
    @{constant_as_html_function}
    ;;
  }

  dimension: date_with_formatting {
    type: date
    convert_tz: no
    sql: '2020-01-01' ;;
    html: @{date_format} ;;
  }

}
explore: constant_as_html_function {}
