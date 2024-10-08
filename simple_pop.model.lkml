connection: "kevmccarthy_bq"

view: order_items {
  # sql_table_name: `kevmccarthy.thelook_with_orders_km.order_items` ;;
  derived_table: {
    sql:
    select 'current' as period, date(created_at) as the_date, * from `kevmccarthy.thelook_with_orders_km.order_items`
    union all
    select 'prior' as period, date_add(date(created_at), interval 1 year) as the_date, * from `kevmccarthy.thelook_with_orders_km.order_items`
    ;;
  }

  dimension: id {
    view_label: "System Keys"
    primary_key: yes
    # type: number
    type: string
    sql: cast(${TABLE}.id as string) ;;
  }
  dimension_group: created {
    type: time
    timeframes: [raw, time, minute15, date, week, month, quarter, year]
    sql:${TABLE}.created_at;;
  }

  #the date, aligns prior data against the corresponding current date
  dimension_group: the {#the_date
    type: time
    datatype: date
    timeframes: [raw,date,month]
    sql: ${TABLE}.the_date ;;
  }

  dimension: period {}
  measure: count__current_and_prior {description:"do not use without pivotting on period" type:count}
  measure: current_count {
    type: count
    filters: [period: "current"]
  }
  measure: prior_count {
    type: count
    filters: [period: "prior"]
  }

}

explore: order_items {}
