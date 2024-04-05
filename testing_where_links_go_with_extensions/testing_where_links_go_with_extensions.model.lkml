connection: "kevmccarthy_bq"

view: t1 {
  derived_table: {
    sql: select 1 as id ;;
  }
  dimension: id {}
}

#refinement
view: +t1 {
  dimension: id {label:"refined"}
}
view: t2 {
  extends: [t1]
  dimension: id {label:"extended"}
}
view: +t1 {
}
explore: t1 {
  join: t2 {type:cross relationship:many_to_one}
}


#results:
#link from explore goes to line 7 (both refined and extended)
#link from explore goes to line 12 and 16 respectively
