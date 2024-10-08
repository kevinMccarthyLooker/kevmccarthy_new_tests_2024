connection: "kevmccarthy_bq"

#####
# File Purpose create 'function' example: safe divide.  Below:
# 1) Example view, showing the need for the function
# 2) Template definition
# 3) Implement template
# 4) Implement demo explore including use of the template
#####

### 1) Example view, showing the need for the function
view: tiny_templates_example20240807 {
  view_label: "Safe Divide Example"
  derived_table: {
    sql:  select 1 as order_id,  0 as number_of_line_items,   0 as order_value, 0 as recipients --example recodr that would cause divide by zero error,
union all select 2 as order_id, 10 as number_of_line_items, 100 as order_value, 2 as recipients;;
  }

  dimension: id {}
  dimension: number_of_line_items {}
  dimension: order_value {}
  dimension: recipients {}

  #example of the problem to be addressed with the template
  dimension: avg_item_value {
    type: number
    sql: ${order_value}/${number_of_line_items} ;;
  }

  dimension: avg_item_value_per_recipient {
    type: number
    sql: ${avg_item_value}/${recipients} ;;
  }
}

### 2) Definition of the Template
view: safe_divide_temaplate {
  dimension: numerator {sql: OVERRIDE ME ;; hidden:yes}
  dimension: denominator {sql: OVERRIDE ME ;;hidden:yes}

  ## 'Function' Output
  dimension: safe_divide {
    label: "{{_view._name | replace: 'safe_divide_',''| replace: '_',' '}}" #we'll use this logic to set output field name based on view name of the template implementation. View name should start with 'safe_divide_' to use this
    type: number
    sql: ${numerator}/NULLIF(${denominator},0) ;;
  }
}

### 3) Implement the template for one case:
view: safe_divide_avg_item_value {
  extends: [safe_divide_temaplate]
  #set the parameters for this instance of the template
  dimension: numerator {sql: ${tiny_templates_example20240807.order_value} ;;}
  dimension: denominator {sql:  ${tiny_templates_example20240807.number_of_line_items} ;;}

  ### Output/function applied autoamtically via extensions ###
  ### dimension: safe_divide {} ###
}

### 4) Demo Explore Definition
explore: tiny_templates_example20240807 {
  #'join' in the templated outputs
  join: safe_divide_avg_item_value {sql: ;; relationship:one_to_one view_label: "Safe Divide Example"}
}

## TODO: Impletement template for avg item value PER RECIPIENT
