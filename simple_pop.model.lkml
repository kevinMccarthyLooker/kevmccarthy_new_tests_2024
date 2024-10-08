connection: "kevmccarthy_bq"

view: order_items {
  # sql_table_name: `kevmccarthy.thelook_with_orders_km.order_items` ;;
  derived_table: {
    sql:
    select 'current' as period, date(created_at) as the_date, * from `kevmccarthy.thelook_with_orders_km.order_items`
    union all
    select 'prior year' as period, date_add(date(created_at), interval 1 year) as the_date, * from `kevmccarthy.thelook_with_orders_km.order_items`
    union all
    select 'prior quarter' as period, date_add(date(created_at), interval 1 quarter) as the_date, * from `kevmccarthy.thelook_with_orders_km.order_items`
    union all
    select 'prior month' as period, date_add(date(created_at), interval 1 month) as the_date, * from `kevmccarthy.thelook_with_orders_km.order_items`
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


  #testing more named periods
  measure: prior_year_count {
    type: count
    filters: [period: "prior year"]
  }
  measure: prior_quarter_count {
    type: count
    filters: [period: "prior quarter"]
  }
  measure: prior_month_count {
    type: count
    filters: [period: "prior month"]
  }

}

explore: order_items {}
