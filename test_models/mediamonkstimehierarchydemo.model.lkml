connection: "kevmccarthy_bq"
#stand-in for your physical table.  doesn't necessary have to be a fully modelled view
view: time_hierarchy {
  derived_table: {
    sql:
select 'WTD LY' as TimeHierarchy, '2023-01-16' as StartDate,  '2023-01-16' as EndDate union all
select 'WTD TY' as TimeHierarchy, '2024-01-15' as StartDate,  '2024-01-15' as EndDate union all
select 'Yesterday' as TimeHierarchy, '2024-01-15' as StartDate,  '2024-01-15' as EndDate
    ;;
  }
  dimension: TimeHierarchy {}
}

explore: time_hierarchy {hidden:yes}
#may need to make your view be a derived table to support this... could be select * from table that is currently in sql_table_name
view: order_items {
  derived_table: {
    sql:
--just making a table of all dates available to support testing
SELECT created_at FROM UNNEST(GENERATE_DATE_ARRAY(DATE('2015-06-01'), CURRENT_DATE(), INTERVAL 1 DAY)) AS created_at

--you will apply your special filtration here.  _filters can only be used in sql if it's in derived table sql, hence this solution requires a derived table
where
--parse the selected filter values into a liquid array
    {% assign selected_times = _filters['order_items.time_selector'] | sql_quote | replace:"'","" | split: ','%}
--loop through each selection and apply the desired filtration for that one specific selection
    {% for selected_time in selected_times %}
    ( date(created_at) between
          (select date(StartDate) from ${time_hierarchy.SQL_TABLE_NAME} where TimeHierarchy = '{{selected_time}}')
      and (select date(EndDate)   from ${time_hierarchy.SQL_TABLE_NAME} where TimeHierarchy = '{{selected_time}}')
    )
      --add 'or' between generated code for each selection
      {% unless forloop.last %} or {% endunless -%}
    {% endfor %}
    ;;
  }
  dimension: created_date {
    type: date
    datatype: date
    sql: ${TABLE}.created_at ;;
  }
  filter: time_selector {
    suggest_explore: time_hierarchy
    suggest_dimension: time_hierarchy.TimeHierarchy
  }
}

explore: order_items {
  # always_join: [time_hierarchy]
  join:time_hierarchy  {sql:  ;; relationship: one_to_one} #fake join to ensure the CTE is available for my demo, but don't want to 'join' it in the traditional sense, so using blank sql (aka 'Bare Join'). I believe you can still join to time hierarchy normally if desired (e.g. to output the hierarchy names in result set)
}
