connection: "kevmccarthy_bq"

include: "/views/order_items.view.lkml"


view: MELI_calcs_testing_base {
  label: "W"
  extends: [order_items]

  measure: total_sale_price {
    description: "like Revenue in MELI calc"
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd_0
  }

  measure: total_sale_price_complete {
    description: "like PPM in MELI calc"
    filters: [status: "Complete"]
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd_0
  }

  measure: complete_percent {
    description: "like PPM% in MELI calc"
    type: number
    sql: 1.0*${total_sale_price_complete}/nullif(${total_sale_price},0) ;;
    value_format_name: percent_0
  }

  measure: grand_total_sale_price {
    type: number
    sql: sum(sum(${sale_price})) over() ;;
  }

}

view: MELI_calcs_testing_prior {
  label: "W-1"
  extends: [MELI_calcs_testing_base]
  dimension_group: created_date_with_pop {
    type: time
    timeframes: [raw,date,week]
    sql: date_add(${created_date},INTERVAL ${two_row_for_pop.periods_ago} WEEK) ;;
  }

}
view: two_row_for_pop {
  derived_table: {sql: select 0 as periods_ago union all select 1 ;;}
  dimension: periods_ago {type:number}

}
view: MELI_coalesced_dates {
  dimension_group: created_date_with_pop {
    datatype: date
    type: time
    timeframes: [raw,date,week]
    sql: coalesce(${MELI_calcs_testing_prior.created_date_with_pop_date},${MELI_calcs_testing_base.created_date}) ;;
  }

  dimension: product_id {
    sql: coalesce(${MELI_calcs_testing_prior.product_id},${MELI_calcs_testing_base.product_id}) ;;
  }
  measure: percent_change_wow {
    description: "intermediate helper calculation"
    sql: ${MELI_calcs_testing_base.complete_percent}-${MELI_calcs_testing_prior.complete_percent} ;;
    value_format_name: percent_0
  }
  measure: impact_of_percent_change {
    description: "equivalent to Variaciones - %.  Impact of this groups wow % change on $Complete (based on current sales)"
    sql: ${percent_change_wow}*${MELI_calcs_testing_base.total_sale_price} ;;
    value_format_name: usd_0
  }

  measure: revenue_change_wow {
    description: "intermediate helper calculation"
    type: number
    sql: ${MELI_calcs_testing_base.total_sale_price}-${MELI_calcs_testing_prior.total_sale_price} ;;
    value_format_name: usd_0
  }


}
explore: two_row_for_pop {
  join: MELI_calcs_testing_base {
    type: full_outer
    relationship: one_to_one #intentional fannout
    sql_on: ${two_row_for_pop.periods_ago}=0 ;;
  }
  join: MELI_calcs_testing_prior {
    type: full_outer
    relationship: one_to_one #intentional fannout
    sql_on: ${two_row_for_pop.periods_ago}=1 ;;
  }
  join: MELI_coalesced_dates {
    sql:  ;;
    relationship: one_to_one
  }
}
