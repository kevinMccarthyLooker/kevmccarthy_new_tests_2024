connection: "kevmccarthy_bq"


view: order_items_sql {
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
}

view: order_items_fields {
  sql_table_name: ${order_items_sql.SQL_TABLE_NAME} ;;
  fields_hidden_by_default: yes
  dimension: which_period_override_me_in_extension {sql:'override me';;}
  dimension: table_name_override {sql:order_items;;}

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

  dimension: period_is_this_period {
    type: yesno
    sql: order_items.period=${which_period_override_me_in_extension} ;;
  }
  measure: count_filtered_to_this_period {
    label: "Count({{which_period_override_me_in_extension._sql}})"
    hidden: no
    type: sum
    sql: case when order_items.id is not null then 1 else null end;;
    filters: [period_is_this_period: "Yes"]
  }
}

view: current_order_items {
  extends: [order_items_fields]
  dimension_group: the {hidden: no}
  dimension: which_period_override_me_in_extension {sql:'current';;}
}

view: prior_month_order_items {
  extends: [order_items_fields]
  dimension: which_period_override_me_in_extension {sql:'prior month';;}
}
view: prior_quarter_order_items {
  extends: [order_items_fields]
  dimension: which_period_override_me_in_extension {sql:'prior quarter';;}
}
view: prior_year_order_items {
  extends: [order_items_fields]
  dimension: which_period_override_me_in_extension {sql:'prior year';;}
}

explore: order_items {
  from: current_order_items
  view_name: order_items
  join: prior_month_order_items {sql:;;relationship:one_to_one}
  join: prior_quarter_order_items {sql:;;relationship:one_to_one}
  join: prior_year_order_items {sql:;;relationship:one_to_one}
}
