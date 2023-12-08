view: order_items {
  sql_table_name: `kevmccarthy.thelook_with_orders_km.order_items` ;;
  drill_fields: [id]

  dimension: id {
    view_label: "System Keys"
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }
  dimension_group: created {
    # group_label: "NO DATE"
    # group_item_label: "datetest"

    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: date_add(${TABLE}.created_at, interval 365 day) ;;
  }
  parameter: filter_to_last_day_of_prior_month {
    type: yesno
  }
  # dimension: selected_param_value {
  #   sql: {% parameter filter_to_last_day_of_prior_month %} ;;
  # }
  dimension: date_to_target {
    sql: date_add(date_trunc(current_date(),month),interval -1 day) ;;
  }
  dimension: meets_filter_to_last_day_of_prior_month_criteria {
    type: yesno
    sql:
    {% if filter_to_last_day_of_prior_month._parameter_value == 'true' %}
        case when ${created_date} = date_add(date_trunc(current_date(),month),interval -1 day) then true else false end
    {% else %} true
    {% endif %}
    ;;


  }

  dimension: for_filtering__created_plus_one {
    type: date
    sql: date_add(${created_raw},interval 1 day) ;;
  }
  dimension_group: delivered {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.delivered_at ;;
  }
  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }
  dimension: order_id {
    view_label: "System Keys"
    type: number
    # hidden: yes
    sql: ${TABLE}.order_id ;;
  }

  measure: distinct_orders {
    type: count_distinct
    sql: ${order_id} ;;
  }
  dimension: product_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.product_id ;;
  }
  dimension_group: returned {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.returned_at ;;
  }
  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
    value_format_name: usd
  }
  dimension_group: shipped {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.shipped_at ;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }
  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.user_id ;;
  }
  measure: count {
    type: count
  }
####
  measure: distinct_users {
    type: count_distinct
    sql: ${user_id} ;;
  }
  measure: distinct_daily_users {
    type: count_distinct
    sql: concat(${user_id},${created_date}) ;;
  }
  measure: distinct_weekly_users {
    type: count_distinct
    sql: concat(${user_id},${created_week}) ;;
  }

  measure: distinct_days {
    type: count_distinct
    sql: ${created_date};;
  }


}
