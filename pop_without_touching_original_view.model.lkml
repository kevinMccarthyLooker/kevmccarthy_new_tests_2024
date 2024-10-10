connection: "kevmccarthy_bq"
connection: "kevmccarthy_bq"

view: order_items {
  sql_table_name: `kevmccarthy.thelook_with_orders_km.order_items` ;;

  dimension: id {
    view_label: "System Keys"
    primary_key: yes
    # type: number
    type: string
    sql: cast(${TABLE}.id as string) ;;
  }

  dimension_group: created {
    type: time
    datatype: datetime
    convert_tz: no
    timeframes: [raw, time, minute15, date, week, month, quarter, year]
    sql:${TABLE}.created_at;;
  }

  dimension: sale_price {type:number}

  measure: count_2 {
    hidden: no
    type: count
  }
  measure: total_value {
    hidden: no
    type: sum
    sql: ${sale_price};;
  }
}

# hide fields that we are going to be exposing special versions of
view: order_items_for_pop {
  extends: [order_items]
  dimension_group: created {hidden:yes}
  measure: count_2 {hidden:yes}
  measure: total_value {hidden:yes}
}

view: cross_join_periods {
  derived_table: {
    sql:
    select 'current month' as period, 0 as periods_ago
    union all
    select 'prior month' as period, 1 as periods_ago
    ;;
  }
  dimension: period {}
  dimension: periods_ago {}

  dimension_group: the {
    type: time
    datatype: date
    timeframes: [raw,date,month]
    sql: date_add(cast(${order_items.created_raw} as date),interval ${periods_ago} month) ;;
  }
}

#what are we losing by doing this?  Drill fields from inherited filtered measures?
view: current_order_items {
  extends: [order_items]
  dimension: which_period {sql:'current month';;}
  #for counts, need to inject condition inside COUNT(.
  #noticed that the special COUNT(*) would be different than COUNT([something else]). perhaps handle both explicitly
  measure: count_2 {
    type: number
    sql:{{ order_items.count_2._sql | replace: "COUNT(*)", "COUNT( 1 )" | replace: "COUNT(" , "COUNT(case when ${which_period}=${cross_join_periods.period} then 1 else null end *" }};;
  }
  measure: total_value {
    type: number
    sql:{{ order_items.total_value._sql | replace: "SUM(" , "SUM(case when ${which_period}=${cross_join_periods.period} then 1 else null end * " }};;
  }
}

view: prior_month_order_items {
  extends: [current_order_items]
  dimension: which_period {sql:'prior month';;}
}
# view: prior_quarter_order_items {
#   extends: [order_items_fields]
#   dimension: which_period_override_me_in_extension {sql:'prior quarter';;}
# }
# view: prior_year_order_items {
#   extends: [order_items_fields]
#   dimension: which_period_override_me_in_extension {sql:'prior year';;}
# }

explore: order_items {
  from: order_items_for_pop
  view_name: order_items
  # join: order_items_fields  {sql:;;relationship:one_to_one}
  join: current_order_items {sql:;;relationship:one_to_one}
  join: cross_join_periods { type:cross relationship:one_to_one}
  join: prior_month_order_items {sql:;;relationship:one_to_one}
  # join: prior_quarter_order_items {sql:;;relationship:one_to_one}
  # join: prior_year_order_items {sql:;;relationship:one_to_one}
}
