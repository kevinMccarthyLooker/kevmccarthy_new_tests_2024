connection: "kevmccarthy_bq"

# include: "/views/order_items.view.lkml"
include: "/views/order_items__source_view_name_replace_table.view.lkml"
include: "/views/products.view.lkml"

####
#Demonstrate that we are working on top of an existing explore
####
# Original view (could be multiple, just as with any explore
view: MELI_calcs_testing_base {
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
# Original explore
explore: MELI_calcs_testing_base  {}

####
#Period over period helpers
####
#POP table used to help generate the 'prior period' data
# - cross join against this 2 row table gives to copies of data to work with
# - in the second copy, we'll offset the data by 1 period
view: pop {
  derived_table: {sql:select 0 as periods_ago union all select 1;;}
  dimension: periods_ago {type:number}
}

#this is a standard template view we use to set up period over period. doesn't need to be adjusted for different use cases (rather, we'll extend it in different ways)
view: pop_template {
  #this field is a placeholder upon which special date logic will be applied
  #for different explores, we could use different base date for the pop logic to be applied on
  dimension: date_for_pop {
    type: date
    sql:  '2099-12-31';;#override me
  }
  #user can specify at run time what type of period to use
  parameter: period_size_selector {
    type: unquoted
    allowed_value: {label:"Week" value:"WEEK"}
    allowed_value: {label:"Day" value:"DAY"}
  }
  #offsets the base date according to the user's period size choice
  dimension_group: date_with_pop {
    datatype: date
    type: time
    timeframes: [raw,date,week]
    sql: date_add(${date_for_pop},INTERVAL ${pop.periods_ago} {{ period_size_selector._parameter_value }}) ;;
  }
}

#To enable Period over Period on a given explore, need to specify which date field should be used for POP
#We would potentially have multiple of these - one per explore
view: apply_template_for_explore_x {
  extends: [pop_template]
  dimension: date_for_pop {
    sql: ${MELI_calcs_testing_base.created_date} ;;
  }
}
####
#Mix calculation input fields template
####
#input Numerator metric and denominator metric, get current and prior and ratio of each, grand totals, and final ctc calcs
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


#This view holds logic for the different rate metrics.
#We will extend this view for each period to give us lookml-referenceable fiels for current and prior
view: measures_output_template {
  fields_hidden_by_default: yes

  #represents the user's KPI selector
  #based on the user's selection, we'll need to specify what are the numerator and denominator fields to use
  #this mapping of KPI's numerator and denominator will need to be coded for each KPI we want to support
  parameter: select_measure {
    allowed_value: {value:"Percent Complete"}
    allowed_value: {value:"Percent Processed"}
  }


  #demonstrates that KPI used for the calculations and shown on the visualization can be set by user (using parameter above)
  measure: input_numerator_field {
    sql:
    {% if select_measure._parameter_value == "'Percent Complete'" %} ${MELI_calcs_testing_base.total_sale_price_complete}
    {% else %}${MELI_calcs_testing_base.total_sale_price_in_process}
    {% endif %};;
  }

  #denominator also be set dynamically in full implementation
  measure: input_denominator_field {sql:${MELI_calcs_testing_base.total_sale_price};;}

  #a placeholder for a piece of logic that will be injected into other calculations, to create current and prior versions of each metric

  # problem: data gets grouped by timeframe
  # dimension: timeframe_specification {sql: (case when ${pop.periods_ago}=0 then 1 else 0 end);;}

  #problem: measure comes out unaggregated
  # measure: timeframe_specification {
  #   type: number
  #   sql: (case when ${pop.periods_ago}=0 then 1 else 0 end);;
  # }

  #set logic for timeframe in label.  we do it in label so that we can reference this logic without grouping by or selecting the field
  #could likely also do this automatically based on name of the view having 'prior' and following proper naming convention
  measure: timeframe_specification {
    type: number
    sql: max(0);;
    view_label: ""
    label: "(case when ${pop.periods_ago}=0 then 1 else 0 end)"
  }


  #FURTHER INVESTIGATION: Input field of type sum and works with this.  But what other measure types can be supported?  What if it's 'write your own sum' type measure, etc.
  #FURTHER INVESTIGATION: Should it be 'replace:' function, or 'replace_first:'?
  #FURTHER INVESTIGATION: Best way to set format?
  #extends the numerator field set above with special logic to make it specific to current vs prior
  measure: numerator_in_timeframe{
    type:number
    required_fields: [timeframe_specification,input_numerator_field] #need to require the fields so their sql is referenceable
    sql:
    {% assign timeframe_specification = 'SUM(' | append:timeframe_specification._label | append: ' * ' %}
    {% assign input_sql = input_numerator_field._sql %}
    {% assign final_sql = input_sql | replace: 'SUM(', timeframe_specification %}
    {{final_sql}}
    ;;
    value_format_name: decimal_2
  }
  measure: denominator_in_timeframe{
    type:number
    required_fields: [timeframe_specification,input_denominator_field]
    sql:
    {% assign timeframe_specification = 'SUM(' | append: timeframe_specification._label | append: ' * ' %}
    {% assign input_sql = input_denominator_field._sql %}
    {% assign final_sql = input_sql | replace: 'SUM(', timeframe_specification %}
    {{final_sql}}
    ;;
    value_format_name: decimal_2
  }

  #represents the key rate field
  measure: output_percent {
    type: number
    sql: ${numerator_in_timeframe}/nullif(${denominator_in_timeframe},0) ;;
    value_format_name: percent_2
  }

  #special measures to get grand totals - sum(x) over() effectively gives us the grand total, available in each row for calculations
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

#implements the measures including grand totals and such, but only for 'current' (using the default timeframe specification)
view: measures_output_current {
  fields_hidden_by_default: no
  extends: [measures_output_template]
}
#implements measures but adjusts the timeframe specification so data is limited to prior only
view: measures_output_prior {
  fields_hidden_by_default: no
  extends: [measures_output_template]
  # dimension: timeframe_specification {sql: (case when ${pop.periods_ago}=1 then 1 else 0 end);;}
  # measure: timeframe_specification {sql: (case when ${pop.periods_ago}=1 then 1 else 0 end);;}
  measure: timeframe_specification {
    label: "(case when ${pop.periods_ago}=0 then 1 else 0 end)"
  }

}

#do the reqiured math comparing current measures to prior
view: wow_comparison_measures {
  measure: numerator_change_wow {
    type: number
    value_format_name: decimal_2
    sql: ${measures_output_current.numerator_in_timeframe}-${measures_output_prior.numerator_in_timeframe} ;;
  }
  measure: percent_change_wow {
    description: "like Delta PPM%"
    value_format_name: percent_0
    sql: ${measures_output_current.output_percent}-${measures_output_prior.output_percent} ;;
  }
  measure: impact_of_percent_change {
    description: "equivalent to Variaciones - %.  Impact of this groups wow % change on $Complete (based on current sales)"
    value_format_name: decimal_2
    sql: ${percent_change_wow}*${measures_output_current.denominator_in_timeframe} ;;
  }
  measure: denominator_change_wow {
    label: "(intermediate) denominator change"
    description: "intermediate helper calculation"
    type: number
    value_format_name: decimal_2
    sql: ${measures_output_current.denominator_in_timeframe}-${measures_output_prior.denominator_in_timeframe} ;;
  }
  measure: impact_of_denominator_change {
    description: "like Vol in example calculations. this describes what counterfactual would be if rate (complete %/ppm%) had stayed static, assumes prior week overall ppm %"
    type: number
    value_format_name: decimal_2
    sql: ${denominator_change_wow}*${measures_output_prior.grand_total_output_percent} ;;
  }

  # #mix...
  # #kev figures (based on the 'check' logic, that mix could be calculated as PPM(curr) - PPM(P) - impact_of_percent_change - impact_of_volume_change
  measure: impact_of_mix {
    type: number
    value_format_name: decimal_2
    sql: ${denominator_change_wow}*(${measures_output_prior.output_percent} - ${measures_output_prior.grand_total_output_percent} ) ;;
  }

  measure: ctc__rate__so_called {
    description: "same as 'Rate' in mockup, but needs a different label?  Impact_of_percent_change as a percent of overall"
    type: number
    value_format_name: percent_0
    sql: 1.0*${impact_of_percent_change}/nullif(${measures_output_current.grand_total_denominator},0) ;;
  }
  # #QUESTION IN MOCKUP WHETHER TO USE REVENUE (total_sale_price) OR PPM(..._complete) in denominator
  measure: ctc__mix {
    description: "same as 'Mix' in CTC section of mockup mockup, but needs a different label?  impact_of_mix as a percent of overall"
    type: number
    value_format_name: percent_0
    sql: 1.0*${impact_of_mix}/nullif(${measures_output_current.grand_total_denominator},0) ;;
  }
  measure: ctc__s_efecto_vol {
    label: "S/ Efecto Vol"
    type: number
    value_format_name: percent_0
    sql: ${ctc__rate__so_called} + ${ctc__mix} ;;
  }

  measure: subtotal_for_check {
    type: number
    sql: ${impact_of_percent_change}+${impact_of_denominator_change}+${impact_of_mix} ;;
  }
  measure: check {
    description: "impact of % change, numerator change, and mix together should equal wow numerator change"
    type: string
    sql: concat( 'wow numerator change:', cast(round(${numerator_change_wow},2) as string),' should = ',cast(round(${subtotal_for_check},2) as string)) ;;
  }

}



####
#Final explore with special features joined in
####
explore: MELI_calcs_testing_base_extended {
  extends: [MELI_calcs_testing_base]
  view_name: MELI_calcs_testing_base
  join: pop {type: cross relationship: one_to_one}
  join: apply_template_for_explore_x { sql:  ;; relationship: one_to_one }
  join: measures_output_current { sql:  ;; relationship: one_to_one }
  join: measures_output_prior { sql:  ;; relationship: one_to_one }
  join: wow_comparison_measures { sql:  ;; relationship: one_to_one }
}
