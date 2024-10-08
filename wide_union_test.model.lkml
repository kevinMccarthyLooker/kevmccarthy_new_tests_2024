connection: "kevmccarthy_bq"

include: "/views/events.view.lkml"
include: "/views/order_items.view.lkml"

view: wide_union_test {
  extends: [events,order_items]
  derived_table: {
    sql:
--First Table's data, with left join on false to add second table column placeholders
with events_for_wide_union_part as
(
  select *,
  --Handle common/duplicate fields by adding new columns that coalesce
  coalesce(events_for_wide_union.created_at,order_items_for_wide_union.created_at) as created_at_combined
  from      ${events.SQL_TABLE_NAME} events_for_wide_union
  left join ${order_items.SQL_TABLE_NAME} order_items_for_wide_union
    on false
)
,
--Second tables data - see right join on false, to include first table column placeholders
order_items_for_wide_union as
(
  select *,
  coalesce(events_for_wide_union.created_at,order_items_for_wide_union.created_at) as created_at_combined
  from ${events.SQL_TABLE_NAME} events_for_wide_union
  right join ${order_items.SQL_TABLE_NAME} order_items_for_wide_union
    on false
)
--Union data from both sources
          select 'events' as source       ,* from events_for_wide_union_part
union all select 'order_items' as source  ,* from order_items_for_wide_union
    ;;
  }
  dimension_group: created {sql:${TABLE}.created_at_combined;;}
  dimension: source {}
  measure: count {label:"Record Count"}
}

##### EXPLORE DEFINITION ####
explore: test {
  view_name: wide_union_test
  #include these so looker can generate the source table sql, but these aren't used directly (hence fields:[])
  join: events {sql:  ;; relationship:one_to_one fields:[]}
  join: order_items {sql:  ;; relationship:one_to_one fields:[]}

}
