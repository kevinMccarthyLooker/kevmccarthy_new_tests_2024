view: products {
  sql_table_name: `kevmccarthy.thelook_with_orders_km.products` ;;
  drill_fields: [id]

  dimension: id {
    view_label: "System Keys"
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }
  dimension: brand {
    type: string
    sql: ${TABLE}.brand ;;
    drill_fields: [name]

  }
  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }
  dimension: cost {
    type: number
    sql: ${TABLE}.cost ;;
  }
  dimension: department {
    type: string
    sql: ${TABLE}.department ;;
  }
  dimension: distribution_center_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.distribution_center_id ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }
  dimension: retail_price {
    type: number
    sql: ${TABLE}.retail_price ;;
  }
  dimension: sku {
    type: string
    sql: ${TABLE}.sku ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
  id,
  name,
  order_items.count,
  ]
  }

}
