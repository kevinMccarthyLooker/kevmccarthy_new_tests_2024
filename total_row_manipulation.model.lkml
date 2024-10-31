connection: "kevmccarthy_bq"

include: "*/order_items.view*"

view: total_row_manipulatopm {
  extends: [order_items]
  measure: total_rows_in_query {
    type: number
    sql: count(*) over() ;;
  }
  measure: total_sale_price {
    type: number
    sql:
    case when ${total_rows_in_query} = 1
    then avg(${sale_price})
    else sum(${sale_price})
    end
    ;;
    value_format_name: usd_0
    html:
    {%if total_rows_in_query._value == 1 %} Total - Avg: {%endif%}
    {{rendered_value}}
    ;;
  }
}
explore: total_row_manipulatopm {}
