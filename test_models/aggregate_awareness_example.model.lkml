connection: "thelook"

include: "/views/events.view"
include: "/views/users.view"
include: "/datagroups/orders_datagroup.lkml"

explore: events {
  join: users {
    sql_on:${events.user_id}=${users.id} ;;
    type: left_outer
    relationship: many_to_one
  }

  aggregate_table: monthly_orders {
    materialization: {
      datagroup_trigger:orders_datagroup
    }
    query: {
      dimensions: [users.created_month]
      measures: [events.count]
      filters: [users.created_month: "1 year"]
    }
  }
}
