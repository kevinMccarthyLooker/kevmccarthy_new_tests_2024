view: users {
  sql_table_name: `kevmccarthy.thelook_with_orders_km.users` ;;
  drill_fields: [id]

  dimension: id {
    view_label: "System Keys"
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }
  dimension: age {
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: age_tier {
    type: tier
    tiers: [20,30,40]
    style: relational
    sql: ${age} ;;
  }


  dimension: age_difference_from_target_age {
    type: number
    sql: 30 - ${age} ;;
  }


  dimension: city {
    description: "the town"
    group_label: "User Location"
    type: string
    sql: ${TABLE}.city ;;
  }
  dimension: country {
    group_label: "User Location"
    hidden: yes
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
  }
  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year, day_of_year]
    sql: ${TABLE}.created_at ;;
  }
  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }
  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name ;;
  }
  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }
  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }
  dimension: latitude {
    group_label: "User Location"
    type: number
    sql: ${TABLE}.latitude ;;
  }
  dimension: longitude {
    group_label: "User Location"
    type: number
    sql: ${TABLE}.longitude ;;
  }
  dimension: postal_code {
    group_label: "User Location"
    type: string
    sql: ${TABLE}.postal_code ;;
  }
  dimension: state {
    group_label: "User Location"
    hidden: yes
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension: county_and_state {
    group_label: "User Location"
    type: string
    sql: concat(${country}, ' - ', ${state}) ;;
  }

  dimension: is_tri_state_area {
    group_label: "User Location"
    type: yesno
    sql: ${country} = 'United States' and ( ${state} = 'New Jersey' or ${state}='Connecticut' or ${state} = 'New York');;
  }


  dimension: street_address {
    group_label: "User Location"
    type: string
    sql: ${TABLE}.street_address ;;
  }
  dimension: traffic_source {
    type: string
    sql: ${TABLE}.traffic_source ;;
  }

  measure: count {
    type: count
    drill_fields: [id, last_name, first_name, order_items.count, orders.count]
  }

  measure: average_age {
    type: average
    sql: ${age} ;;
  }

  measure: distinct_user_emails {
    type: count_distinct
    sql: ${email} ;;
  }

  measure: users_with_duplicated_emails_count {
    type: number
    sql: ${count} - ${distinct_user_emails} ;;

  }



}
