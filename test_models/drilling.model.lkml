connection: "kevmccarthy_bq"

view: drill_test {
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
  measure: drill_test {
    type: count
    drill_fields: [color]
    # https://gcpl2318.cloud.looker.com/explore/drilling/drill_test?fields=drill_test.date_with_drill_date,drill_test.count&f[drill_test.date_with_drill_year]=2024&limit=500&column_limit=50&query_timezone=America%2FChicago

    html:
    {% assign field_to_skip = 'drill_test.date_with_drill_year'%}
    {% assign filter_spec_to_search_for = '&f[' | append: field_to_skip | append: ']' %}
    {% assign link_before_filter_begin = link | split: filter_spec_to_search_for | first %}
    {% assign link_filter_text = link | split: filter_spec_to_search_for | last | split: '&' | first | prepend: filter_spec_to_search_for %}
    <a href='{{link_before_filter_begin | replace: link_filter_text, ''}}'>test link</a>;;
  }
}


explore: drill_test {}
