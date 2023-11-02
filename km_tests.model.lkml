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
}
explore: test_measure_default_behavior {}

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
