connection: "kevmccarthy_bq"

view: liquid_magic {
  derived_table: {
    sql: select 1 as id ;;
  }
  dimension: id {}

  dimension: test_sql {
    sql: sql_1 ;;
  }

  dimension: test_fetch_sql_as_ref{
    sql: ${test_sql}  ;;
  }
  dimension: test_fetch_sql_as_liquid {
    sql: {{test_sql._sql | strip}} ;;
  }
  dimension: test_fetch_sql_as_liquid2 {
    sql:
    {% assign fetched_sql = test_sql._sql | strip%}
    {% assign updated_sql = fetched_sql | replace: 'sql_','replaced_'%}
    {{updated_sql | strip}}
    ;;
  }

}
explore: liquid_magic {}
