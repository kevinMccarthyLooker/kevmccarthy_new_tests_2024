connection: "kevmccarthy_bq"

include: "/views/order_items.view.lkml"
include: "/views/users.view.lkml"
include: "/views/products.view.lkml"

explore: users {}

explore: order_items {
  join: users {
    relationship: many_to_one
    sql_on: ${order_items.user_id}=${users.id} ;;
  }
  join: products {
    relationship: many_to_one
    sql_on: ${order_items.product_id}=${products.id} ;;
  }
}
