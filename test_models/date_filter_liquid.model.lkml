connection: "kevmccarthy_bq"

view: test_date_filters {
  derived_table: {
    sql: select cast('2023-01-01'as date) as test_date  ;;
  }
  dimension: test_date {
    type: date
    datatype: date
  }
  dimension: complete_months {
    type: number
    sql:
  date_diff({% date_start test_date %}, {% date_end test_date %},month)
    ;;
  }
}

explore: test_date_filters {}
