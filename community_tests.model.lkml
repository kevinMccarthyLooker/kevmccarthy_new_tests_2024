connection: "kevmccarthy_bq"

include: "/views/order_items.view"


view: order_items_with_day_of_month {

  extends: [order_items]

  dimension: created_day_of_month {
    type: date_day_of_month
    sql: ${TABLE}.created_at ;;
  }
  dimension: current_day_of_month {
    hidden: yes
    datatype: date
    type: date_day_of_month
    sql: current_date() ;;
  }
  dimension: created_day_of_month_less_than_current_day_of_month {
    type: yesno
    sql: ${created_day_of_month}<${current_day_of_month} ;;
  }

}

explore: order_items {

  from: order_items_with_day_of_month
}

include: "/views/users.*"
explore: users {}
