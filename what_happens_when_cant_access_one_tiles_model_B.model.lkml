connection: "kevmccarthy_bq"

view: b {
  derived_table: {sql: select 101 as identifier;;}
  dimension: identifier {}
}
explore: b {}
