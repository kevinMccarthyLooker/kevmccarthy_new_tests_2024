view: order_items__source_view_name_replace_table {
  #in extensions we'll override this
  dimension: view_name {sql:${TABLE};;}

  sql_table_name: `kevmccarthy.thelook_with_orders_km.order_items` ;;
  drill_fields: [id]

  dimension: id {
    view_label: "System Keys"
    primary_key: yes
    type: number
    sql: ${view_name}.id ;;
  }
  dimension_group: created {
    # group_label: "NO DATE"
    # group_item_label: "datetest"

    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: date_add(${view_name}.created_at, interval 365 day) ;;
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
    sql: ${view_name}.delivered_at ;;
  }
  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${view_name}.inventory_item_id ;;
  }
  dimension: order_id {
    view_label: "System Keys"
    type: number
    # hidden: yes
    sql: ${view_name}.order_id ;;
  }

  measure: distinct_orders {
    type: count_distinct
    sql: ${order_id} ;;
  }
  dimension: product_id {
    type: number
    # hidden: yes
    sql: ${view_name}.product_id ;;
  }
  dimension_group: returned {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${view_name}.returned_at ;;
  }
  dimension: sale_price {
    type: number
    sql: ${view_name}.sale_price ;;
    value_format_name: usd
  }
  dimension_group: shipped {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${view_name}.shipped_at ;;
  }
  dimension: status {
    type: string
    sql: ${view_name}.status ;;
  }
  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${view_name}.user_id ;;
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
