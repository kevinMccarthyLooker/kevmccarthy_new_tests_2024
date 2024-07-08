connection: "thelook"

view: test_pdt {
  derived_table: {
    sql: select '{{ "now" | date: "%Y-%m-%d %H:%M" }}' as id ;;
    # sql_trigger_value: select current_timestamp() ;;
    # indexes: ["id"]
  }
  dimension: id {}
}
explore: test_pdt {}
