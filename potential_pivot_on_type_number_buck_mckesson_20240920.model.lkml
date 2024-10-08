connection: "kevmccarthy_bq"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#
# explore: order_items {
#   join: orders {
#     relationship: many_to_one
#     sql_on: ${orders.id} = ${order_items.order_id} ;;
#   }
#
#   join: users {
#     relationship: many_to_one
#     sql_on: ${users.id} = ${orders.user_id} ;;
#   }
# }

view: potential_pivot_on_type_number_buck_mckesson_20240920 {
  derived_table: {
    sql:
    select '' as velocity_indicator, 1 as zip,1 as value
union all select 'A' as velocity_indicator, 1 as zip,1 as value
union all select 'B' as velocity_indicator, 1 as zip,1 as value
union all select 'A' as velocity_indicator, 1 as zip,1 as value
union all select 'B' as velocity_indicator, 1 as zip,1 as value

    ;;
  }
  dimension: velocity_indicator {}
  dimension: zip {}
  dimension: value {}
  measure: total_value {
    type: sum
    sql: ${value} ;;
  }
  measure: total_value_as_type_number {
    type: number
    sql: sum(${value});;
  }
}
explore: potential_pivot_on_type_number_buck_mckesson_20240920 {}
