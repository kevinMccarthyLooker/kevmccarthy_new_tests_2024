connection: "kevmccarthy_bq"

## Demo Original View.  Untouched for POP ##
view: order_items {
  sql_table_name: `kevmccarthy.thelook_with_orders_km.order_items` ;;

  dimension: pk {
    hidden: yes
    primary_key: yes
    sql:${id};;
  }
  dimension: id {
    view_label: "System Keys"
    type: string
    sql: cast(${TABLE}.id as string) ;;
  }

  dimension_group: created {
    type: time
    datatype: datetime
    convert_tz: no
    timeframes: [raw, time, minute15, date, week, month, quarter, year]
    sql:${TABLE}.created_at;;
  }

  dimension: sale_price {type:number}

  # measure: count {type: count}

  measure: total_value {
    type: sum
    sql: ${sale_price};;
  }

  #this found that counts are weird cause looker injects count(*) where it can without checking for null/missing
  #fabio has pointed out before the counts should really be modified to count where pk is not 0...
    #updating count to check
  measure: count {type:count filters: [pk: "-NULL"]}
  measure: test_complex_measure {
    type: number
    sql: ${total_value}/nullif(${count},0) ;;
  }
}

## Extension unions duplicated for each period, with dates offset accordingly ##
# We also duplicate columns, for respective periods. note reference to entire source table (not fields) wrapped in case when statements
## These produce the full set of columns, prefixed with the provided alias name
view: order_items_and_periods_cross_joined_and_wide {
  extends: [order_items]
  sql_table_name:
(
  select
  *,
  case
    when periods.timeframe = 'month' then
      date_add(${created_date},interval periods_ago month)
    when periods.timeframe = 'year' then
      date_add(${created_date},interval periods_ago year)
  end as pop_date,
  case when label='current' then order_items else null end as order_items_curr,
  case when label='prior month' then order_items else null end as order_items_prior_month,
  case when label='prior year' then order_items else null end as order_items_prior_year,
  from
    (
      select 0 as periods_ago, 'month' as timeframe, 'current' as label
      union all
      select 1 as periods_ago, 'month' as timeframe, 'prior month' as label
      union all
      select 1 as periods_ago, 'year' as timeframe, 'prior year' as label
    ) as periods
  cross join ${EXTENDED} as order_items
)
;;
  #hide the original date field.  using it will cause confusion. We'll use the manipulated date instead
  dimension_group: created {hidden:yes}
  dimension_group: pop_date {
    type: time
    timeframes: [raw,month]
    datatype: date
  }
  ##how to hide measures?!
  #tried this way: list all measures here, and then use fields to exclude extraneous fields we don't want to show
  set: measures {fields:[count,total_value,test_complex_measure]}
}

#We can then refer to the extra columns from the wide unioned table (as noted, they prefixed with a table name alias) with these sourceless views
# Looker qualifies fields from the sourec (i.e. ${TABLE} references) with the view name, so we align it to the special aliased columns in the main view
view: order_items_curr {
  extends: [order_items_and_periods_cross_joined_and_wide]
  ##hide dimensions! or hide all and unhide all measures...  did this with fields and the set called measures
}
view: order_items_prior_month {
  extends: [order_items_and_periods_cross_joined_and_wide]
  ##hide dimensions!
}
view: order_items_prior_year {
  extends: [order_items_and_periods_cross_joined_and_wide]
  ##hide dimensions!
}
explore: order_items_and_periods_cross_joined_and_wide {
  #hide extra (and confusing) fields.  Need to keep pk for the count(*) correction (filter to pk not null)
  fields: [
    order_items*, -order_items.measures*,
    order_items_curr.measures*,order_items_curr.pk,
    order_items_prior_month.measures*,order_items_prior_month.pk,
    order_items_prior_year.measures*,order_items_prior_year.pk
    ]
  from: order_items_and_periods_cross_joined_and_wide
  view_name: order_items
  join: order_items_curr {sql: ;; relationship:one_to_one}
  join: order_items_prior_month {sql: ;; relationship:one_to_one}
  join: order_items_prior_year {sql: ;; relationship:one_to_one}
}
