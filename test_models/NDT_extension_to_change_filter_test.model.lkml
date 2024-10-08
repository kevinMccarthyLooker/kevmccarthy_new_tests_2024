connection: "kevmccarthy_bq"
view: base {
  sql_table_name: `kevmccarthy.thelook_with_orders_km.users` ;;
  dimension: id {}
  dimension: created_at {type:date}
  dimension: gender {}
  measure: count {type:count}
}
explore: NDT_extension_to_change_filter_test__base {
  from: base
  view_name: base
}
view: ndt_1 {
  derived_table: {
    explore_source: NDT_extension_to_change_filter_test__base {
      column: count {}
      filters: [base.created_at: "2 years",base.gender: "Male"]
      # filters: []
    }
  }
  dimension: count {}
}
explore: ndt_1 {}

view: ndt_2 {
  extends: [ndt_1]
  derived_table: {
    explore_source: NDT_extension_to_change_filter_test__base {
      filters: [base.created_at: "3 years"] #overrides filter on same field
      #Gender: Male was inhereited
    }
  }
}

explore: ndt_2 {}
