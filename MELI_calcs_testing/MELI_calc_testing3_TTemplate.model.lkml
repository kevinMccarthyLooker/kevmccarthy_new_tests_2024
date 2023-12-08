connection: "kevmccarthy_bq"

# include: "/views/order_items.view.lkml"
include: "/views/order_items__source_view_name_replace_table.view.lkml"
include: "/views/products.view.lkml"

view: MELI_calcs_testing_base {
  label: "W"
  extends: [order_items__source_view_name_replace_table]

  dimension: sale_price_tier {
    type: tier
    tiers: [10,100]
    style: relational
    sql: ${sale_price} ;;
  }

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

  measure: total_sale_price_in_process {
    description: "like PPM in MELI calc"
    filters: [status: "Complete, Processing, Shipped"]
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


}
view: pop {
  derived_table: {sql:select 0 as periods_ago union all select 1;;}
  dimension: periods_ago {type:number}
}

view: pop_template {
  dimension: date_for_pop {
    type: date
    sql:  '2099-12-31';;#override me
  }
  dimension_group: date_with_pop {
    datatype: date
    type: time
    timeframes: [raw,date,week]
    sql: date_add(${date_for_pop},INTERVAL ${pop.periods_ago} WEEK) ;;
  }
}

#input Numerator metri and denominator metric, get current and prior and ratio of each, grand totals, and final ctc calcs
view: measures_template {
  measure: input_numerator_field {
    type: number
    sql: 0 ;; #override me
  }
  measure: input_denominator_field {
    type: number
    sql: 0 ;; #override me
  }
}


view: apply_measures_template {

  # measure: input_numerator_field {sql:${MELI_calcs_testing_base.total_sale_price_complete};;}
  #12/8 - testing with a dyname input
  parameter: select_measure {
    allowed_value: {value:"Percent Complete"}
    allowed_value: {value:"Percent Processed"}
  }
  measure: input_numerator_field {
    sql:
    {% if apply_measures_template.select_measure._parameter_value == "'Percent Complete'" %} ${MELI_calcs_testing_base.total_sale_price_complete}
    {% else %}${MELI_calcs_testing_base.total_sale_price_in_process}
    {% endif %};;
  }


  measure: input_denominator_field {sql:${MELI_calcs_testing_base.total_sale_price};;}
}

view: measures_output_template {
  fields_hidden_by_default: yes
  extends: [apply_measures_template]
  dimension: timeframe_specification {sql: (case when ${pop.periods_ago}=0 then 1 else 0 end);;}

  ### Functions on top of the inputs
  # measure: numerator_in_timeframe {type:number sql:(${timeframe_specification}*1.0*${apply_measures_template.input_numerator_field});;}
  # measure: numerator_in_timeframe {type:number sql:(case when ${pop.periods_ago}=0 then ${apply_measures_template.input_numerator_field} else null end);;}
  # measure: numerator_in_timeframe {type:number sql:sum(${apply_measures_template.input_numerator_field});;}

  #The input could be type sum and would work with this.  What other measure types can be supported?  What if it's 'write your own sum' type measure, etc.
  #Should it be 'replace:' function, or 'replace_first:'?
  measure: numerator_in_timeframe{
    type:number
    sql: {{input_numerator_field._sql | replace: 'SUM(','SUM( ${timeframe_specification} * '}} ;;
    value_format_name: decimal_2
  }
  measure: denominator_in_timeframe{
    type:number
    sql: {{input_denominator_field._sql | replace: 'SUM(','SUM( ${timeframe_specification} * '}} ;;
    value_format_name: decimal_2
  }
  measure: output_percent {
    type: number
    sql: ${numerator_in_timeframe}/nullif(${denominator_in_timeframe},0) ;;
    value_format_name: percent_2
  }

  measure: grand_total_numerator {
    hidden: no
    type: number
    sql: sum(${numerator_in_timeframe}) over() ;;
    value_format_name: usd_0
  }
  measure: grand_total_denominator {
    hidden: no
    type: number
    sql: sum(${denominator_in_timeframe}) over() ;;
    value_format_name: usd_0
  }
  measure: grand_total_output_percent {
    hidden: no
    type: number
    sql: 1.0*${grand_total_numerator}/nullif(${grand_total_denominator},0) ;;
    value_format_name: percent_2
  }
}

view: measures_output_current {
  fields_hidden_by_default: no
  extends: [measures_output_template]
}
view: measures_output_prior {
  fields_hidden_by_default: no
  extends: [measures_output_template]
  dimension: timeframe_specification {sql: (case when ${pop.periods_ago}=1 then 1 else 0 end);;}
}


view: apply_template {
  extends: [pop_template]
  dimension: date_for_pop {
    sql: ${MELI_calcs_testing_base.created_date} ;;
  }
}

view: wow_comparison_measures {
  measure: percent_change_wow {
    description: "like Delta PPM%"
    sql: ${measures_output_current.output_percent}-${measures_output_prior.output_percent} ;;
    value_format_name: percent_0
  }
  measure: impact_of_percent_change {
    description: "equivalent to Variaciones - %.  Impact of this groups wow % change on $Complete (based on current sales)"
    sql: ${percent_change_wow}*${measures_output_current.numerator_in_timeframe} ;;
    value_format_name: decimal_2
  }
  measure: numerator_change_wow {
    label: "(intermediate) numerator change"
    description: "intermediate helper calculation"
    type: number
    sql: ${measures_output_current.numerator_in_timeframe}-${measures_output_prior.numerator_in_timeframe} ;;
    value_format_name: decimal_2
  }
  measure: impact_of_numerator_change {
    description: "like Vol in example calculations. this describes what counterfactual would be if rate (complete %/ppm%) had stayed static, assumes prior week overall ppm %"
    type: number
    sql: ${numerator_change_wow}*${measures_output_prior.grand_total_output_percent} ;;
    value_format_name: decimal_2
  }

  # #mix...
  # #kev figures (based on the 'check' logic, that mix could be calculated as PPM(curr) - PPM(P) - impact_of_percent_change - impact_of_volume_change
  measure: impact_of_mix {
    type: number
    sql: ${numerator_change_wow}*(${measures_output_prior.output_percent} - ${measures_output_prior.grand_total_output_percent} ) ;;
    value_format_name: decimal_2
  }

  # #QUESTION IN MOCKUP WHETHER TO USE REVENUE (total_sale_price) OR PPM(..._complete) in denominator
  measure: ctc__rate__so_called {
    description: "same as 'Rate' in mockup, but needs a different label?  Impact_of_percent_change as a percent of overall"
    type: number
    sql: 1.0*${impact_of_percent_change}/nullif(${measures_output_current.grand_total_numerator},0) ;;
    value_format_name: percent_0
  }
  # #QUESTION IN MOCKUP WHETHER TO USE REVENUE (total_sale_price) OR PPM(..._complete) in denominator
  measure: ctc__mix {
    description: "same as 'Mix' in CTC section of mockup mockup, but needs a different label?  impact_of_mix as a percent of overall"
    type: number
    sql: 1.0*${impact_of_mix}/nullif(${measures_output_current.grand_total_numerator},0) ;;
    value_format_name: percent_0
  }
  measure: ctc__s_efecto_vol {
    label: "S/ Efecto Vol"
    type: number
    sql: ${ctc__rate__so_called} + ${ctc__mix} ;;
    value_format_name: percent_0
  }

}

explore: MELI_calcs_testing_base  {}

explore: MELI_calcs_testing_base_extended {
  extends: [MELI_calcs_testing_base]
  view_name: MELI_calcs_testing_base
  join: pop {type: cross relationship: one_to_one}
  join: apply_template { sql:  ;; relationship: one_to_one }
  join: measures_template { sql:  ;; relationship: one_to_one }
  join: apply_measures_template { sql:  ;; relationship: one_to_one }
  join: measures_output_current { sql:  ;; relationship: one_to_one }
  join: measures_output_prior { sql:  ;; relationship: one_to_one }
  join: wow_comparison_measures { sql:  ;; relationship: one_to_one }
}

#

# view: MELI_calcs_testing_base_w_pop {
#   label: "W"
#   extends: [MELI_calcs_testing_base]

#   dimension_group: created_date_with_pop {
#     datatype: date
#     type: time
#     timeframes: [raw,date,week]
#     sql: date_add(${created_date},INTERVAL ${pop.periods_ago} WEEK) ;;
#   }
# }

# view: prior_measures {
#   fields_hidden_by_default: yes
#   #adjust this view to actually use base view
#   dimension: view_name {sql:MELI_calcs_testing_base_w_pop;;}
#   label: "prior measures"
#   extends: [MELI_calcs_testing_base_w_pop]
#   measure: total_sale_price {
#     hidden: no
#     filters: [pop.periods_ago: "1"]
#   }
#   measure: total_sale_price_complete {
#     hidden: no
#     filters: [pop.periods_ago: "1"]
#   }
#   measure: complete_percent {
#     hidden: no
#   }

#   measure: grand_total_sale_price {
#     label: "(intermediate) grand_total_sale_price"
#     hidden: no
#     type: number
#     sql: sum(${total_sale_price}) over() ;;
#     value_format_name: usd_0
#   }
#   measure: grand_total_sale_price_complete {
#     label: "(intermediate) grand_total_sale_price_complete"
#     hidden: no
#     type: number
#     sql: sum(${total_sale_price_complete}) over() ;;
#     value_format_name: usd_0
#   }
#   measure: grand_total_percent_complete {
#     description: "like total row PPM%"
#     hidden: no
#     type: number
#     sql: 1.0*${grand_total_sale_price_complete}/nullif(${grand_total_sale_price},0) ;;
#     value_format_name: percent_0
#   }
# }
# view: current_measures {
#   fields_hidden_by_default: yes
#   #adjust this view to actually use base view
#   dimension: view_name {sql:MELI_calcs_testing_base_w_pop;;}
#   label: "current measures"
#   extends: [MELI_calcs_testing_base_w_pop]
#   measure: total_sale_price {
#     hidden: no
#     filters: [pop.periods_ago: "0"]
#   }
#   measure: total_sale_price_complete {
#     hidden: no
#     filters: [pop.periods_ago: "0"]
#   }
#   measure: complete_percent {
#     hidden: no
#   }
#   measure: grand_total_sale_price_complete {
#     label: "(intermediate) grand_total_sale_price_complete"
#     hidden: no
#     type: number
#     sql: sum(${total_sale_price_complete}) over() ;;
#     value_format_name: usd_0
#   }
# }

# view: wow_comparison_measures {
#   measure: percent_change_wow {
#     description: "like Delta PPM%"
#     sql: ${current_measures.complete_percent}-${prior_measures.complete_percent} ;;
#     value_format_name: percent_0
#   }
#   measure: impact_of_percent_change {
#     description: "equivalent to Variaciones - %.  Impact of this groups wow % change on $Complete (based on current sales)"
#     sql: ${percent_change_wow}*${current_measures.total_sale_price} ;;
#     value_format_name: usd_0
#   }

#   measure: sale_price_change_wow {
#     label: "(intermediate) sale_price_change_wow"
#     description: "intermediate helper calculation"
#     type: number
#     sql: ${current_measures.total_sale_price}-${prior_measures.total_sale_price} ;;
#     value_format_name: usd_0
#   }

#   measure: impact_of_volume_change {
#     description: "like Vol in example calculations. this describes what counterfactual would be if rate (complete %/ppm%) had stayed static, assumes prior week overall ppm %"
#     type: number
#     sql: ${sale_price_change_wow}*${prior_measures.grand_total_percent_complete} ;;
#     value_format_name: usd_0
#   }

#   #mix...
#   #kev figures (based on the 'check' logic, that mix could be calculated as PPM(curr) - PPM(P) - impact_of_percent_change - impact_of_volume_change
#   measure: impact_of_mix {
#     type: number
#     sql: ${sale_price_change_wow}*(${prior_measures.complete_percent} - ${prior_measures.grand_total_percent_complete} ) ;;
#     value_format_name: usd_0
#   }

#   #QUESTION IN MOCKUP WHETHER TO USE REVENUE (total_sale_price) OR PPM(..._complete) in denominator
#   measure: ctc__rate__so_called {
#     description: "same as 'Rate' in mockup, but needs a different label?  Impact_of_percent_change as a percent of overall"
#     type: number
#     sql: 1.0*${impact_of_percent_change}/nullif(${current_measures.grand_total_sale_price_complete},0) ;;
#     value_format_name: percent_0
#   }
#   #QUESTION IN MOCKUP WHETHER TO USE REVENUE (total_sale_price) OR PPM(..._complete) in denominator
#   measure: ctc__mix {
#     description: "same as 'Mix' in CTC section of mockup mockup, but needs a different label?  impact_of_mix as a percent of overall"
#     type: number
#     sql: 1.0*${impact_of_mix}/nullif(${current_measures.grand_total_sale_price_complete},0) ;;
#     value_format_name: percent_0
#   }
#   measure: ctc__s_efecto_vol {
#     label: "S/ Efecto Vol"
#     type: number
#     sql: ${ctc__rate__so_called} + ${ctc__mix} ;;
#     value_format_name: percent_0
#   }

# }

# explore: MELI_calcs_testing_base_w_pop {
#   join: products {
#     sql_on: ${MELI_calcs_testing_base_w_pop.product_id}=${products.id} ;;
#     relationship: many_to_one
#     type: left_outer
#   }
#   join: pop {
#     type: cross
#     relationship: one_to_one
  # }
#   join: prior_measures { sql:  ;; relationship: one_to_one }
# join: current_measures { sql:  ;; relationship: one_to_one }
# join: wow_comparison_measures { sql:  ;; relationship: one_to_one }
# }
