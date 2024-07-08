connection: "kevmccarthy_bq"

view: pivot_download_test {
  derived_table: {
    sql:
    select 1 as id, 'red' as color, date('2023-01-01') as date,101 as value
    union all
    select 2 as id, 'red' as color, date('2024-01-01') as date, 201 as value
    union all
    select 3 as id, 'blue' as color, date('2024-01-01') as date, 301 as value
    ;;
  }
  dimension: id {}
  dimension: color {}
  # dimension_group: date_with_drill {
  #   type: time
  #   datatype: date
  #   timeframes: [raw,date,year]
  #   sql: ${TABLE}.date ;;
  # }
  #declare them manually
  dimension: date_with_drill_date {
    type: date
    datatype: date
    sql: ${TABLE}.date ;;
    # drill_fields: []
  }
  dimension: date_with_drill_year {
    type: date_year
    datatype: date
    sql: ${TABLE}.date ;;
    # drill_fields: []
  }

# https://gcpl2318.cloud.looker.com/explore/drilling/drill_test?fields=drill_test.date_with_drill_date,drill_test.count&f[drill_test.date_with_drill_year]=2024&limit=500&column_limit=50&query_timezone=America%2FChicago


  dimension: value {

  }
  measure: count {type:count}
  measure: total_value {type:sum sql:${value};;}

}

view: +pivot_download_test {
  dimension: order_by_example {
    sql:
    case  when ${color}='red' then 1
          when ${color}='blue' then 2
    else 3
    end
    ;;
  }
  dimension: color {
    order_by_field: order_by_example
  }
}


explore: pivot_download_test {

}
