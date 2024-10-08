connection: "kevmccarthy_bq"

view: drill_test {
  derived_table: {
    sql: select 1 as id, 'a' as letter, 'blue' as color, 101 as value;;
  }
  dimension: id {drill_fields:[letter,color,value,total_value]}
  dimension: letter {}
  dimension: color {}
  dimension: value {}
  measure: total_value {
    type: sum
    sql: ${value} ;;
  }
  measure: total_value2 {
    type: sum
    sql: ${value} ;;
  }
}
explore: drill_test {}
