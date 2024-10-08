#from this community forum question
# https://www.googlecloudcommunity.com/gc/Modeling/Injecting-extended-view-dimension-in-derived-table-sql-doesn-t/m-p/789108#M6045
connection: "kevmccarthy_bq"

view: a {
  derived_table: {
    sql:
select * from `kevmccarthy.thelook_with_orders_km.order_items`
where {{a.sql_always_where_inject._sql}}
    ;;
  }
  dimension: id {sql:t;;}
  dimension: sql_always_where_inject {
    sql: 1=1 ;;
  }
  dimension: t2 {sql:${id};;}
}
explore: a {}
